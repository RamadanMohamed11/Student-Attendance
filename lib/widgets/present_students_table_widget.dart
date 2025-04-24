import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/student_details_page.dart';
import 'package:student_attendance/services/authentication_service.dart';

class PresentStudentsTableWidget extends StatefulWidget {
  const PresentStudentsTableWidget({
    super.key,
    required this.subjectModel,
    required this.selectedDate,
  });
  final SubjectModel subjectModel;
  final String selectedDate;

  @override
  State<PresentStudentsTableWidget> createState() =>
      _PresentStudentsTableWidgetState();
}

class _PresentStudentsTableWidgetState
    extends State<PresentStudentsTableWidget> {
  List<String> presentStudent = [];
  List<UserModel> users = [];
  bool _isLoading = false;
  Future<List<UserModel>> _fetchUsers() async {
    List<UserModel> users = [];
    print(
        "Present Students - Student list length: ${widget.subjectModel.studentList.length}");
    print(
        "Present Students - Student list emails: ${widget.subjectModel.studentList}");

    for (String email in widget.subjectModel.studentList) {
      try {
        DocumentSnapshot doc =
            await AuthenticationService().getUserDataUsingEmil(email);
        print(
            "Present Students - Fetching user data for email: $email, exists: ${doc.exists}");

        if (doc.exists) {
          UserModel user = UserModel.fromSnapshot(doc);
          users.add(user);
          print("Present Students - Added user: ${user.name}, ${user.email}");
        } else {
          print("Present Students - Document doesn't exist for email: $email");
        }
      } catch (e) {
        print("Present Students - Error fetching user data for $email: $e");
      }
    }
    return users;
  }

  Future<List<String>> presentOnSelectedDate() async {
    List<String> attendanceList = [];
    for (UserModel user in users) {
      bool isPresent = await AuthenticationService().isStudentAttended(
          widget.subjectModel.subjectCode!, user.email, widget.selectedDate);
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
                child: Text('No students found',
                    style: TextStyle(fontSize: 24.sp)));
          } else {
            users = snapshot.data!;
            return FutureBuilder<List<String>>(
                future: presentOnSelectedDate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No present students found for this date',
                            style: TextStyle(fontSize: 24.sp)));
                  } else {
                    presentStudent = snapshot.data!;
                    _isLoading = false;
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
                              return DataRow(
                                onSelectChanged: (selected) {
                                  if (selected == true) {
                                    // Navigate to student details page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StudentDetailsPage(
                                          student: user,
                                          subjectModel: widget.subjectModel,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                cells: [
                                  DataCell(Text(user.name,
                                      style: TextStyle(
                                          fontSize: 20.sp,
                                          color: Colors.green))),
                                  DataCell(Text(
                                    user.sectionNumber!,
                                    style: TextStyle(fontSize: 20.sp),
                                  )),
                                ],
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
}
