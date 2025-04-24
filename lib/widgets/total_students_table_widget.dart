import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../services/authentication_service.dart';
import '../pages/student_details_page.dart';

class TotalStudentsTableWidget extends StatefulWidget {
  const TotalStudentsTableWidget({
    super.key,
    required this.subjectModel,
    required this.selectedDate,
  });
  final SubjectModel subjectModel;
  final String selectedDate;

  @override
  State<TotalStudentsTableWidget> createState() =>
      _TotalStudentsTableWidgetState();
}

class _TotalStudentsTableWidgetState extends State<TotalStudentsTableWidget> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<UserModel> _students = [];
  Map<String, String> _attendanceStatus = {}; // email -> status

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print("DIRECT DEBUG - Subject code: ${widget.subjectModel.subjectCode}");

      // NEW APPROACH: Directly query the Users collection for students who have this subject in their userSubjects array
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userSubjects', arrayContains: widget.subjectModel.subjectCode)
          .where('userType', isEqualTo: 'Student')
          .get();

      print(
          "DIRECT DEBUG - Found ${querySnapshot.docs.length} students in Users collection");

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _students = [];
        });
        return;
      }

      // Process the students
      final List<UserModel> students = [];
      for (final doc in querySnapshot.docs) {
        try {
          final userData = doc.data();
          print("DIRECT DEBUG - Found student: ${userData['email']}");
          students.add(UserModel.fromJson(userData));
        } catch (e) {
          print("DIRECT DEBUG - Error processing student document: $e");
        }
      }

      // Check attendance status for each student
      final Map<String, String> attendanceStatus = {};
      for (final student in students) {
        try {
          final isPresent = await AuthenticationService().isStudentAttended(
              widget.subjectModel.subjectCode!,
              student.email,
              widget.selectedDate);
          attendanceStatus[student.email] = isPresent ? 'Present' : 'Absent';
          print(
              "DIRECT DEBUG - Attendance for ${student.email}: ${isPresent ? 'Present' : 'Absent'}");
        } catch (e) {
          attendanceStatus[student.email] = 'Absent';
          print(
              "DIRECT DEBUG - Error checking attendance for ${student.email}: $e");
        }
      }

      setState(() {
        _students = students;
        _attendanceStatus = attendanceStatus;
        _isLoading = false;
      });

      print(
          "DIRECT DEBUG - Loaded ${_students.length} students with attendance data");
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      print("DIRECT DEBUG - Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: TextStyle(fontSize: 24.sp)),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No students enrolled in this subject',
                style: TextStyle(fontSize: 24.sp)),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowHeight: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white10,
        ),
        columns: [
          DataColumn(
              label: Text('Name',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 23.sp))),
          DataColumn(
              label: Text('Section',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 23.sp))),
          DataColumn(
              label: Text('Status',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 23.sp))),
        ],
        rows: _students.map((student) {
          final status = _attendanceStatus[student.email] ?? 'Absent';
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                // Navigate to student details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsPage(
                      student: student,
                      subjectModel: widget.subjectModel,
                    ),
                  ),
                );
              }
            },
            cells: [
              DataCell(Text(student.name, style: TextStyle(fontSize: 20.sp))),
              DataCell(Text(student.sectionNumber.toString(),
                  style: TextStyle(fontSize: 20.sp))),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: status == 'Present'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: status == 'Present' ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Present' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
