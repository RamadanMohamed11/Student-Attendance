import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/services/authentication_service.dart';

class PresentStudentsTableWidget extends StatefulWidget {
  const PresentStudentsTableWidget({super.key, required this.subjectModel});
  final SubjectModel subjectModel;

  @override
  State<PresentStudentsTableWidget> createState() =>
      _PresentStudentsTableWidgetState();
}

class _PresentStudentsTableWidgetState
    extends State<PresentStudentsTableWidget> {
  List<String> presentStudent = [];
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

  Future<List<String>> presentToday() async {
    List<String> attendanceList = [];
    for (UserModel user in users) {
      bool isPresent = await AuthenticationService()
          .isStudentAttended(widget.subjectModel.subjectCode!, user.email);
      if (isPresent) {
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
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('1No students found',
                    style: TextStyle(fontSize: 24.sp)));
          } else {
            users = snapshot.data!;
            return FutureBuilder<List<String>>(
                future: presentToday(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('2No students found',
                            style: TextStyle(fontSize: 24.sp)));
                  } else {
                    presentStudent = snapshot.data!;
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
                                  label: Text('Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23.sp))),
                              DataColumn(
                                  label: Text('Section',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23.sp))),
                            ],
                            rows: users
                                .where((user) =>
                                    presentStudent.contains(user.email))
                                .map((user) {
                              return _buildRow(
                                user.name,
                                user.sectionNumber!,
                                Colors.green.shade100,
                                Colors.red.shade100,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }
                });
          }
        });
  }

  DataRow _buildRow(
      String name, String studentClass, Color bgColor, Color textColor) {
    return DataRow(cells: [
      DataCell(
          Text(name, style: TextStyle(fontSize: 20.sp, color: Colors.green))),
      DataCell(Text(
        studentClass,
        style: TextStyle(fontSize: 20.sp),
      )),
      // DataCell(Container(
      //   padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      //   decoration: BoxDecoration(
      //     color: bgColor,
      //     borderRadius: BorderRadius.circular(10.r),
      //   ),
      //   child:
      //       Text(status, style: TextStyle(color: textColor, fontSize: 20.sp)),
      // )),
    ]);
  }
}
