import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/main.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/prof_mark_attendance_page.dart';
import 'package:student_attendance/pages/settings_page.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'package:student_attendance/widgets/oval_right_border_clipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../models/subject_model.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/theme_mode_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.subjectModel});
  static const String id = 'dashboard_page';

  final SubjectModel subjectModel;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime dateSelected = DateTime.now();
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  List<dynamic> pages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [
      DashboardContent(subjectModel: widget.subjectModel),
      ProfMarkAttendancePage(
        subjectModel: widget.subjectModel,
      ),
      SettingsPage(subjectModel: widget.subjectModel),
    ];
  }

  @override
  Widget build(BuildContext context) {
    void dataPickerDialog() {
      showDatePicker(
        context: context,
        initialDate: dateSelected,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      ).then((DateTime? value) {
        if (value != null) {
          dateSelected = value;
          print(dateSelected);
        }
      });
    }

    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      // bottomNavigationBar: CurvedNavigationBar(
      //   key: _bottomNavigationKey,
      //   index: 0,
      //   items: <Widget>[
      //     Icon(
      //       Icons.add,
      //       size: 30.sp,
      //       color: kPrimaryColor,
      //     ),
      //     Icon(
      //       Icons.checklist,
      //       size: 30.sp,
      //       color: kPrimaryColor,
      //     ),
      //     Icon(
      //       Icons.settings,
      //       size: 30.sp,
      //       color: kPrimaryColor,
      //     ),
      //   ],
      //   color: kSecondaryColor,
      //   buttonBackgroundColor: kSecondaryColor,
      //   backgroundColor: kPrimaryColor,
      //   animationCurve: Curves.easeInOut,
      //   animationDuration: const Duration(milliseconds: 400),
      //   onTap: (index) {
      //     setState(() {
      //       _page = index;
      //     });
      //   },
      //   letIndexChange: (index) => true,
      // ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        title: Text(
          'Attendance Track',
          style: TextStyle(
              color: kTextColor, fontWeight: FontWeight.w700, fontSize: 22.sp),
        ),
        actions: const [ThemeModeButton()],
      ),
      // drawer: const Drawer(
      //   child: SidebarMenu(),
      // ),
      drawer: ClipPath(
        clipper: OvalRightBorderClipper(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 74, 78, 101), width: 3.w)),
          child: Drawer(
            width: screenSize.width / 1.3,
            // backgroundColor: CustomColor.scaffoldColor,
            child: const SidebarMenu(),
          ),
        ),
      ),

      body: pages[_page],
      floatingActionButton: _page == 0
          ? FloatingActionButton(
              backgroundColor: Colors.blue.withOpacity(0.65),
              foregroundColor: Colors.white,
              onPressed: dataPickerDialog,
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 35,
              ),
            )
          : null,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        items: <Widget>[
          // Icon(
          //   Icons.subject,
          //   size: 30.sp,
          //   color: kPrimaryColor,
          // ),
          Icon(
            Icons.dashboard,
            size: 32.sp,
            color: Colors.white,
          ),
          Icon(
            Icons.checklist,
            size: 32.sp,
            color: Colors.white,
          ),
          Icon(
            Icons.settings,
            size: 32.sp,
            color: Colors.white,
          ),
        ],
        color: kSecondaryColor,
        buttonBackgroundColor: Colors.red,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _page = index;
            print("Page: $_page");
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  DashboardContent({
    super.key,
    required this.subjectModel,
  });
  final SubjectModel subjectModel;
  List<String> presentStudent = [];
  List<UserModel> users = [];
  Future<List<UserModel>> _fetchUsers() async {
    List<UserModel> users = [];
    for (String email in subjectModel.studentList) {
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
          .isStudentAttended(subjectModel.subjectCode!, user.email);
      if (isPresent) {
        attendanceList.add(user.email);
      }
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
                child: Text('No students found',
                    style: TextStyle(fontSize: 24.sp)));
          } else {
            users = snapshot.data!;
            return FutureBuilder<List<String>>(
                future: presentToday(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No students found',
                            style: TextStyle(fontSize: 24.sp)));
                  } else {
                    presentStudent = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            subjectModel.subjectName,
                            style: TextStyle(
                                fontSize: 26.sp, fontWeight: FontWeight.bold),
                          ),
                          AttendanceInformation(
                            subjectModel: subjectModel,
                            presentStudent: presentStudent.length.toString(),
                          ),
                          PieChartExample(
                            subjectModel: subjectModel,
                            presentStudent: presentStudent.length.toString(),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  }
                });
          }
        });
  }
}

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({
//     super.key,
//   });

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   @override
//   Widget build(BuildContext context) {
//     return const SingleChildScrollView(
//       child: Column(
//         children: [DashboardContent(), PieChartExample()],
//       ),
//     );
//   }
// }
