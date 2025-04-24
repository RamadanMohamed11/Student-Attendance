import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../services/authentication_service.dart';

class TotalStudentsTableWidget extends StatefulWidget {
  const TotalStudentsTableWidget({super.key, required this.subjectModel});
  final SubjectModel subjectModel;

  @override
  State<TotalStudentsTableWidget> createState() =>
      _TotalStudentsTableWidgetState();
}

class _TotalStudentsTableWidgetState extends State<TotalStudentsTableWidget> {
  List<Map<String, String>> studentAttendance = [];
  List<UserModel> users = [];
  Future<List<UserModel>> _fetchUsers() async {
    List<UserModel> users = [];
    for (String email in widget.subjectModel.studentList) {
      UserModel user = UserModel.fromSnapshot(
          await AuthenticationService().getUserDataUsingEmil(email));
      users.add(user);
    }
    return users;
  }

  Future<List<Map<String, String>>> attendanceToday() async {
    List<Map<String, String>> attendanceList = [];
    for (UserModel user in users) {
      bool isPresent = await AuthenticationService()
          .isStudentAttended(widget.subjectModel.subjectCode!, user.email);
      attendanceList.add({user.email: isPresent ? "Present" : "Absent"});
    }
    return attendanceList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child:
                  Text('No students found', style: TextStyle(fontSize: 24.sp)));
        } else {
          users = snapshot.data!;
          return FutureBuilder<List<Map<String, String>>>(
              future: attendanceToday(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No students found',
                          style: TextStyle(fontSize: 24.sp)));
                } else {
                  studentAttendance = snapshot.data!;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23.sp))),
                          DataColumn(
                              label: Text('Section',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23.sp))),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23.sp))),
                        ],
                        rows: users.map((user) {
                          String status = "Absent";
                          for (var attendance in studentAttendance) {
                            if (attendance.containsKey(user.email)) {
                              status = attendance[user.email]!;
                              break;
                            }
                          }
                          return _buildRow(
                              user.name,
                              user.sectionNumber!,
                              status,
                              status == "Present"
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              status == "Present" ? Colors.green : Colors.red);
                        }).toList(),
                      ),
                    ),
                  );
                }
              });
        }
      },
    );
  }

  DataRow _buildRow(String name, String studentClass, String status,
      Color bgColor, Color textColor) {
    return DataRow(cells: [
      DataCell(
          Text(name, style: TextStyle(fontSize: 20.sp, color: Colors.blue))),
      DataCell(Text(
        studentClass,
        style: TextStyle(fontSize: 20.sp),
      )),
      DataCell(Text(status,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 20.sp))),
    ]);
  }
}
