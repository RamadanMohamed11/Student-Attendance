import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_attendance/colors.dart';

import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../widgets/theme_mode_button.dart';

class StudentDetailsPage extends StatefulWidget {
  const StudentDetailsPage({
    Key? key,
    required this.student,
    required this.subjectModel,
  }) : super(key: key);

  static const String id = 'student_details_page';
  final UserModel student;
  final SubjectModel subjectModel;

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _attendanceHistory = [];
  int _presentCount = 0;
  int _absentCount = 0;
  double _studentDegree = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print("\n==== DETAILED DEBUGGING ====");
      print("Student email: ${widget.student.email}");
      print("Subject code: ${widget.subjectModel.subjectCode}");

      // First, get the subject document to access the studentAttendance field
      final subjectDoc = await FirebaseFirestore.instance
          .collection('Subjects')
          .doc(widget.subjectModel.subjectCode)
          .get();

      if (!subjectDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Subject not found';
        });
        return;
      }

      // Get the subject data
      final subjectData = subjectDoc.data() as Map<String, dynamic>;

      // Get the student attendance directly from the subject document
      List<dynamic> studentAttendance = subjectData['studentAttendance'] ?? [];
      print("Found ${studentAttendance.length} student attendance records");

      // Get the attendance dates from the subject document
      List<String> attendanceDates = [];
      if (subjectData.containsKey('attendanceDates') &&
          subjectData['attendanceDates'] != null) {
        attendanceDates = List<String>.from(subjectData['attendanceDates']);
      }
      print(
          "Found ${attendanceDates.length} attendance dates for subject: $attendanceDates");

      // Process attendance history
      final List<Map<String, dynamic>> history = [];
      final Set<String> presentDates = {};
      _presentCount = 0; // Reset counter

      // Find this student's attendance record
      for (var student in studentAttendance) {
        if (student.containsKey(widget.student.email)) {
          List<dynamic> dates = student[widget.student.email];
          print("Found attendance dates for student: $dates");

          // Use a Set to track unique dates to prevent duplicates
          Set<String> uniqueDates = {};

          // Process each date the student was present
          for (var date in dates) {
            String standardDate = date.toString();

            // Convert date from DD/MM/YYYY to YYYY-MM-DD if needed
            if (standardDate.contains('/')) {
              try {
                final parts = standardDate.split('/');
                if (parts.length == 3) {
                  final day = parts[0].padLeft(2, '0');
                  final month = parts[1].padLeft(2, '0');
                  final year =
                      parts[2].length == 2 ? '20${parts[2]}' : parts[2];
                  standardDate = "$year-$month-$day";
                  print("Converted date format from $date to $standardDate");
                }
              } catch (e) {
                print("Error converting date format: $e");
              }
            }

            // Only add the date if we haven't seen it before
            if (uniqueDates.add(standardDate)) {
              // Add to present dates
              presentDates.add(standardDate);
              history.add({
                'date': standardDate,
                'status': 'Present',
              });
              _presentCount++;
              print("Added present date: $standardDate");
            } else {
              print("Skipped duplicate date: $standardDate");
            }
          }

          break; // Found the student, no need to continue
        }
      }

      print("\nPresent dates: $presentDates");
      print("Present count: $_presentCount");

      // Add absent dates (lectures where student didn't mark attendance)
      _absentCount = 0; // Reset counter
      print("\nChecking for absent dates...");

      for (String date in attendanceDates) {
        print("\nChecking lecture date: $date");
        // Standardize the date format for comparison
        String standardDate = date;

        if (date.contains('/')) {
          try {
            final parts = date.split('/');
            if (parts.length == 3) {
              final day = parts[0].padLeft(2, '0');
              final month = parts[1].padLeft(2, '0');
              final year = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
              standardDate = "$year-$month-$day";
              print("Converted lecture date from $date to $standardDate");
            }
          } catch (e) {
            print("Error standardizing date format: $e");
          }
        }

        print("Checking if present dates contains: $standardDate");
        print("Contains: ${presentDates.contains(standardDate)}");

        if (!presentDates.contains(standardDate)) {
          history.add({
            'date': standardDate,
            'status': 'Absent',
          });
          _absentCount++;
          print("Added absent date: $standardDate");
        } else {
          print("Student was present on $standardDate");
        }
      }

      print("\nAbsent count: $_absentCount");
      print("==== END DEBUGGING ====");

      // Sort history by date (newest first)
      history.sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a['date']);
          final dateB = DateFormat('yyyy-MM-dd').parse(b['date']);
          return dateB.compareTo(dateA);
        } catch (e) {
          print("Error sorting dates: $e");
          return 0;
        }
      });

      print("Sorted ${history.length} attendance records");

      // Calculate student degree based on attendance
      double totalLectures =
          double.tryParse(widget.subjectModel.totalLectures) ?? 10.0;
      double totalMarks =
          double.tryParse(widget.subjectModel.lecturesMark) ?? 5.0;
      double markPerLecture = totalMarks / totalLectures;

      // Calculate degree based on absences
      _studentDegree = totalMarks - (_absentCount * markPerLecture);
      // Ensure degree doesn't go below 0
      _studentDegree = _studentDegree < 0 ? 0 : _studentDegree;

      print(
          "Student degree calculation: Total marks: $totalMarks, Mark per lecture: $markPerLecture");
      print("Absent count: $_absentCount, Calculated degree: $_studentDegree");

      setState(() {
        _attendanceHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading attendance data: $e';
      });
      print('Error loading attendance data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        title: Text('Student Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
        actions: const [ThemeModeButton()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage, style: TextStyle(fontSize: 18.sp)))
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.withOpacity(0.65),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Card
          _buildStudentInfoCard(),
          SizedBox(height: 20.h),

          // Attendance Summary
          _buildAttendanceSummary(),
          SizedBox(height: 20.h),

          // Attendance History
          _buildAttendanceHistory(),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: kPrimaryColor,
                child: Icon(Icons.person, size: 50.sp, color: Colors.white),
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Name', widget.student.name),
            _buildInfoRow('Email', widget.student.email),
            _buildInfoRow('Section', widget.student.sectionNumber.toString()),
            _buildInfoRow('Subject', widget.subjectModel.subjectName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final totalLectures = _presentCount + _absentCount;
    final attendanceRate = totalLectures > 0
        ? (_presentCount / totalLectures * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: kSecondaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceStatCard(
                  'Present',
                  _presentCount.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildAttendanceStatCard(
                  'Absent',
                  _absentCount.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
                _buildAttendanceStatCard(
                  'Rate',
                  '$attendanceRate%',
                  Colors.blue,
                  Icons.percent,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Add degree container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kSecondaryColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Student Degree',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: kSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${_studentDegree.toStringAsFixed(1)} / ${widget.subjectModel.lecturesMark}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: kSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Based on ${widget.subjectModel.totalLectures} total lectures',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance History',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: kSecondaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _attendanceHistory.isEmpty
                ? Center(
                    child: Text(
                      'No attendance records found',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceHistory.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceHistory[index];
                      final isPresent = record['status'] == 'Present';

                      // Format date
                      String formattedDate = record['date'];
                      try {
                        final date =
                            DateFormat('yyyy-MM-dd').parse(record['date']);
                        formattedDate =
                            DateFormat('EEEE, MMMM d, yyyy').format(date);
                      } catch (e) {
                        // Use original date if parsing fails
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isPresent ? Colors.green : Colors.red,
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            color: isPresent ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
