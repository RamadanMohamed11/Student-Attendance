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
import 'package:intl/intl.dart';

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

class DashboardContent extends StatefulWidget {
  const DashboardContent({
    super.key,
    required this.subjectModel,
  });
  final SubjectModel subjectModel;

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  List<UserModel> users = [];
  List<String> presentStudents = [];
  DateTime selectedDate = DateTime.now();
  String formattedSelectedDate = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    formattedSelectedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Fetch users
      List<UserModel> fetchedUsers = [];
      for (String email in widget.subjectModel.studentList) {
        try {
          final doc = await AuthenticationService().getUserDataUsingEmil(email);
          if (doc.exists) {
            UserModel user = UserModel.fromSnapshot(doc);
            fetchedUsers.add(user);
          }
        } catch (e) {
          print("Error fetching user data: $e");
        }
      }

      // Check attendance for selected date
      List<String> attendanceList = [];
      for (UserModel user in fetchedUsers) {
        bool isPresent = await AuthenticationService().isStudentAttended(
            widget.subjectModel.subjectCode!,
            user.email,
            formattedSelectedDate);
        if (isPresent) {
          attendanceList.add(user.email);
        }
      }

      // Update state if still mounted
      if (mounted) {
        setState(() {
          users = fetchedUsers;
          presentStudents = attendanceList;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    print(
        "Current date before selection: $selectedDate (formatted: $formattedSelectedDate)");

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    print("Date picker returned: $picked");

    if (picked != null && picked != selectedDate) {
      // Format the date properly
      final newFormattedDate = DateFormat('yyyy-MM-dd').format(picked);
      print("New formatted date: $newFormattedDate");

      setState(() {
        selectedDate = picked;
        formattedSelectedDate = newFormattedDate;
        print(
            "State updated with date: $selectedDate (formatted: $formattedSelectedDate)");
      });

      // Make sure to call _loadData() after the state is updated
      print("Calling _loadData() for date: $formattedSelectedDate");
      await _loadData();
      print(
          "_loadData() completed for date: $formattedSelectedDate with ${presentStudents.length} present students");
    } else {
      print("Date selection was cancelled or same date was selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.subjectModel.subjectName,
                  style:
                      TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                // Date selector
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border:
                          Border.all(color: kSecondaryColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: kSecondaryColor),
                        SizedBox(width: 10.w),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: kSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // Display selected date
                Text(
                  "Showing attendance for: ${DateFormat('MMMM d, yyyy').format(selectedDate)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                AttendanceInformation(
                  subjectModel: widget.subjectModel,
                  presentStudent: presentStudents.length.toString(),
                  selectedDate: formattedSelectedDate,
                ),
                PieChartExample(
                  subjectModel: widget.subjectModel,
                  presentStudent: presentStudents.length.toString(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }
}
