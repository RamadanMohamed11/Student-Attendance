import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/student_details_page.dart';
import 'package:student_attendance/services/authentication_service.dart';

class AbsentStudentsTableWidget extends StatefulWidget {
  const AbsentStudentsTableWidget({
    super.key,
    required this.subjectModel,
    required this.selectedDate,
  });
  final SubjectModel subjectModel;
  final String selectedDate;

  @override
  State<AbsentStudentsTableWidget> createState() =>
      _AbsentStudentsTableWidgetState();
}

class _AbsentStudentsTableWidgetState extends State<AbsentStudentsTableWidget> {
  List<String> absentStudent = [];
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

  Future<List<String>> absentOnSelectedDate() async {
    List<String> attendanceList = [];
    for (UserModel user in users) {
      bool isPresent = await AuthenticationService().isStudentAttended(
          widget.subjectModel.subjectCode!, user.email, widget.selectedDate);
      if (!isPresent) {
        attendanceList.add(user.email);
      }
    }
    return attendanceList;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
          return FutureBuilder<List<String>>(
            future: absentOnSelectedDate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                absentStudent = snapshot.data!;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: screenSize.width,
                      child: DataTable(
                        dataRowHeight: 50.h,
                        columnSpacing: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.white10,
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23.sp,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Section',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23.sp,
                              ),
                            ),
                          ),
                        ],
                        rows: users
                            .where((user) => absentStudent.contains(user.email))
                            .map((user) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                // Navigate to student details page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailsPage(
                                      student: user,
                                      subjectModel: widget.subjectModel,
                                    ),
                                  ),
                                );
                              }
                            },
                            cells: [
                              DataCell(
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.sectionNumber!,
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  DataRow _buildRow(
      String name, String studentClass, Color bgColor, Color textColor) {
    return DataRow(cells: [
      DataCell(
          Text(name, style: TextStyle(fontSize: 20.sp, color: Colors.red))),
      DataCell(Text(
        studentClass,
        style: TextStyle(fontSize: 20.sp),
      )),
    ]);
  }
}
