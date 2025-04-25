import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_attendance/colors.dart';

import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../widgets/theme_mode_button.dart';
import '../services/authentication_service.dart';

class StudentAttendanceInfo extends StatefulWidget {
  const StudentAttendanceInfo({
    Key? key,
    required this.student,
    required this.subjectModel,
  }) : super(key: key);

  static const String id = 'student_attendance_info';
  final UserModel student;
  final SubjectModel subjectModel;

  @override
  State<StudentAttendanceInfo> createState() => _StudentAttendanceInfoState();
}

class _StudentAttendanceInfoState extends State<StudentAttendanceInfo> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _attendanceHistory = [];
  int _presentCount = 0;
  int _absentCount = 0;
  double _attendancePercentage = 0.0;
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

      // Get the subject document to access the studentAttendance field
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

      // Get the attendance dates from the subject document
      List<String> attendanceDates = [];
      if (subjectData.containsKey('attendanceDates') &&
          subjectData['attendanceDates'] != null) {
        attendanceDates = List<String>.from(subjectData['attendanceDates']);
      }

      // Process attendance history
      final List<Map<String, dynamic>> history = [];
      final Set<String> presentDates = {};
      _presentCount = 0; // Reset counter

      // Find this student's attendance record
      for (var student in studentAttendance) {
        if (student.containsKey(widget.student.email)) {
          List<dynamic> dates = student[widget.student.email];

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
                }
              } catch (e) {
                print("Error converting date format: $e");
              }
            }

            // Only add the date if we haven't seen it before
            if (uniqueDates.add(standardDate)) {
              // Add to present dates
              presentDates.add(standardDate);

              // Add to history
              history.add({
                'date': standardDate,
                'status': 'Present',
              });
            }
          }
        }
      }

      // Sort attendance dates
      attendanceDates.sort((a, b) => b.compareTo(a)); // Most recent first

      // Add absent dates to history
      for (var date in attendanceDates) {
        String standardDate = date;

        // Convert date from DD/MM/YYYY to YYYY-MM-DD if needed
        if (standardDate.contains('/')) {
          try {
            final parts = standardDate.split('/');
            if (parts.length == 3) {
              final day = parts[0].padLeft(2, '0');
              final month = parts[1].padLeft(2, '0');
              final year = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
              standardDate = "$year-$month-$day";
            }
          } catch (e) {
            print("Error converting date format: $e");
          }
        }

        // If the student wasn't present on this date, add as absent
        if (!presentDates.contains(standardDate)) {
          history.add({
            'date': standardDate,
            'status': 'Absent',
          });
        }
      }

      // Sort history by date (most recent first)
      history.sort((a, b) => b['date'].compareTo(a['date']));

      // Update counts
      _presentCount = presentDates.length;
      _absentCount = attendanceDates.length - _presentCount;

      // Calculate attendance percentage
      _attendancePercentage = attendanceDates.isEmpty
          ? 0
          : (_presentCount / attendanceDates.length) * 100;

      // Calculate student degree based on attendance
      // Get the total lectures mark from the subject model
      double lecturesMark =
          double.tryParse(widget.subjectModel.lecturesMark) ?? 0;

      // Get the total number of lectures from the subject model
      int totalLectures = int.tryParse(widget.subjectModel.totalLectures) ?? 0;

      // Calculate the mark per lecture
      double markPerLecture =
          totalLectures > 0 ? lecturesMark / totalLectures : 0;

      // Calculate the student's degree based on the number of present days
      _studentDegree = lecturesMark - _absentCount * markPerLecture;

      // Make sure the degree doesn't exceed the maximum lectures mark
      _studentDegree =
          _studentDegree > lecturesMark ? lecturesMark : _studentDegree;

      setState(() {
        _attendanceHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading attendance data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentInfoCard(),
          SizedBox(height: 16.h),
          _buildAttendanceSummary(),
          SizedBox(height: 16.h),
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
            Text(
              'Student Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: kSecondaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Name', widget.student.name),
            _buildInfoRow('Email', widget.student.email),
            _buildInfoRow('Section', widget.student.sectionNumber ?? 'N/A'),
            _buildInfoRow('Subject', widget.subjectModel.subjectName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
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
                  '${_attendancePercentage.toStringAsFixed(1)}%',
                  Colors.blue,
                  Icons.percent,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Degree:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      Text(
                        '${_studentDegree.toStringAsFixed(2)} / ${widget.subjectModel.lecturesMark}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
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
