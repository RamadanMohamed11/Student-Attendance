import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_attendance/cubits/theme_cubit/theme_cubit.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/login_page.dart';
import 'package:student_attendance/pages/sign_up_page.dart';
import 'package:student_attendance/pages/about_page.dart';
import 'package:student_attendance/pages/doctor_subjects_page.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'colors.dart';
import 'helper/tansitions.dart';
import 'models/subject_model.dart';
import 'pages/absent_students_page.dart';
import 'pages/present_students_page.dart';
import 'pages/student_subjects_page.dart';
import 'pages/total_students_page.dart';
import 'widgets/dashboard_card_widget.dart';
import 'package:firebase_core/firebase_core.dart';

// Import the firebase_app_check plugin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Set androidProvider to `AndroidProvider.debug`
    androidProvider: AndroidProvider.debug,
  );

  // AuthenticationService().signOut();

  await Hive.initFlutter();
  await Hive.openBox('settings'); // Open a box to store theme mode

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.reload(); // Ensure we have the latest verification status
        if (!user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          runApp(BlocProvider(
            create: (context) => ThemeCubit(),
            child: const LoginMaterialApp(),
          ));
          return;
        }
        List<UserModel> users = await AuthenticationService().getUsers();
        for (UserModel userModel in users) {
          if (userModel.email == user.email) {
            if (userModel.userType == 'Student') {
              runApp(BlocProvider(
                create: (context) => ThemeCubit(),
                child: StudentMaterialApp(student: userModel),
              ));
              break;
            } else if (userModel.userType == 'Doctor') {
              runApp(BlocProvider(
                create: (context) => ThemeCubit(),
                child: const DoctorMaterialApp(),
              ));
            }
          }
        }
      } catch (e) {
        print("Error reloading user: $e");
        // If there's an error with the user token, sign out and go to login
        await FirebaseAuth.instance.signOut();
        runApp(BlocProvider(
          create: (context) => ThemeCubit(),
          child: const LoginMaterialApp(),
        ));
      }
    } else {
      runApp(BlocProvider(
        create: (context) => ThemeCubit(),
        child: const LoginMaterialApp(),
      ));
    }
  } catch (e) {
    print("Firebase initialization error: $e");
    // Fallback to login screen if there's any Firebase error
    runApp(BlocProvider(
      create: (context) => ThemeCubit(),
      child: const LoginMaterialApp(),
    ));
  }
}

class DoctorMaterialApp extends StatelessWidget {
  const DoctorMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (_, child) {
      return BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor:
                  kPrimaryColor, // Apply light mode background
            ),

            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              // MarkAttendancePage.id: (context) => const MarkAttendancePage(),
              AboutPage.id: (context) => const AboutPage(),
              SignUpPage.id: (context) => const SignUpPage(),
              LoginPage.id: (context) => const LoginPage(),
              DoctorSubjectsPage.id: (context) => const DoctorSubjectsPage(),
              // MainPage.id: (context) => const MainPage(),
            },
            initialRoute: DoctorSubjectsPage.id,
            title: 'AttendanceTrack',
            // theme: ThemeData.dark(),
          );
        },
      );
    });
  }
}

class StudentMaterialApp extends StatelessWidget {
  const StudentMaterialApp({super.key, required this.student});
  final UserModel student;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (_, child) {
      return BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor:
                  kPrimaryColor, // Apply light mode background
            ),

            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              // MarkAttendancePage.id: (context) => const MarkAttendancePage(),
              AboutPage.id: (context) => const AboutPage(),
              SignUpPage.id: (context) => const SignUpPage(),
              LoginPage.id: (context) => const LoginPage(),
              DoctorSubjectsPage.id: (context) => const DoctorSubjectsPage(),
              StudentSubjectsPage.id: (context) =>
                  StudentSubjectsPage(student: student),
              // MainPage.id: (context) => const MainPage(),
            },
            initialRoute: StudentSubjectsPage.id,
            title: 'AttendanceTrack',
            // theme: ThemeData.dark(),
          );
        },
      );
    });
  }
}

class LoginMaterialApp extends StatelessWidget {
  const LoginMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (_, child) {
      return BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor:
                  kPrimaryColor, // Apply light mode background
            ),

            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              // MarkAttendancePage.id: (context) => const MarkAttendancePage(),
              AboutPage.id: (context) => const AboutPage(),
              SignUpPage.id: (context) => const SignUpPage(),
              LoginPage.id: (context) => const LoginPage(),
              DoctorSubjectsPage.id: (context) => const DoctorSubjectsPage(),
              // MainPage.id: (context) => const MainPage(),
            },
            initialRoute: LoginPage.id,
            title: 'AttendanceTrack',
            // theme: ThemeData.dark(),
          );
        },
      );
    });
  }
}

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  Future<UserModel> fetchUser() async {
    return await AuthenticationService()
        .getUserByEmail(FirebaseAuth.instance.currentUser!.email!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
        future: fetchUser(),
        builder: (context, userModel) {
          if (userModel.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userModel.hasError) {
            return Center(child: Text('Error: ${userModel.error}'));
          } else if (!userModel.hasData) {
            return Center(child: Text('No data found'));
          } else {
            return Container(
              width: 250.w,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  userModel.data!.userType == 'Doctor'
                      ? Icon(
                          FontAwesomeIcons.personChalkboard,
                          size: 50.sp,
                        )
                      : Icon(
                          FontAwesomeIcons.userGraduate,
                          size: 50.sp,
                        ),
                  Text(
                    userModel.data!.name,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userModel.data!.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                  Divider(
                    color: kSecondaryColor,
                    thickness: 5.h,
                  ),
                  // const SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
                  // Divider(
                  //   color: kSecondaryColor,
                  // ),
                  // InkWell(
                  //   onTap: () {
                  //     // Navigator.pushNamed(context, MarkAttendancePage.id);
                  //   },
                  //   child: const SidebarItem(
                  //     icon: Icons.checklist,
                  //     title: 'Mark Attendance',
                  //   ),
                  // ),
                  // Divider(
                  //   color: kSecondaryColor,
                  // ),
                  // const SidebarItem(icon: Icons.bar_chart, title: 'Reports'),
                  // Divider(
                  //   color: kSecondaryColor,
                  // ),
                  // const SidebarItem(icon: Icons.settings, title: 'Settings'),
                  // Divider(
                  //   color: kSecondaryColor,
                  // ),
                  const Spacer(),

                  // About Page Link
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AboutPage.id);
                    },
                    child: const SidebarItem(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, LoginPage.id);
                    },
                    child: InkWell(
                      onTap: () {
                        AuthenticationService().signOut();
                        Navigator.pushNamedAndRemoveUntil(context, LoginPage.id,
                            (Route<dynamic> route) => false);
                      },
                      child: const SidebarItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final Color? color;

  const SidebarItem(
      {super.key,
      required this.icon,
      required this.title,
      this.selected = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListTile(
        leading: Icon(icon,
            color: title == 'Sign Out' ? Colors.red : kSecondaryColor,
            size: 30.sp),
        title: Text(title, style: TextStyle(fontSize: 22.sp)),
        tileColor: selected ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class AttendanceInformation extends StatelessWidget {
  const AttendanceInformation({
    super.key,
    required this.subjectModel,
    required this.presentStudent,
    required this.selectedDate,
  });
  final SubjectModel subjectModel;
  final String presentStudent;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    children: [
                      DashboardCard(
                          title: 'Total Students',
                          count: subjectModel.studentList.length.toString(),
                          color: Colors.blue,
                          icon: Icons.people,
                          onTap: () {
                            Navigator.push(
                                context,
                                CustomSizeTransition(
                                    TotalStudentsPage(
                                      subjectModel: subjectModel,
                                      selectedDate: selectedDate,
                                    ),
                                    alignment: Alignment.centerLeft));
                          }),
                      const Spacer(),
                      DashboardCard(
                          title: 'Present',
                          count: presentStudent,
                          color: Colors.green,
                          icon: Icons.check_circle,
                          onTap: () {
                            Navigator.push(
                                context,
                                CustomSizeTransition(
                                    PresentStudentsPage(
                                      subjectModel: subjectModel,
                                      selectedDate: selectedDate,
                                    ),
                                    alignment: Alignment.centerRight));
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                            title: 'Absent',
                            count: (subjectModel.studentList.length -
                                    int.parse(presentStudent))
                                .toString(),
                            color: Colors.red,
                            icon: Icons.cancel,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CustomSizeTransition(
                                      AbsentStudentsPage(
                                        subjectModel: subjectModel,
                                        selectedDate: selectedDate,
                                      ),
                                      alignment: Alignment.center));
                            }),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5.r)
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListTile(
            title: Text("Mark Johnson marked attendance for Class 10A"),
            subtitle: Text("9:00 AM"),
          ),
          ListTile(
            title: Text("Sarah Williams marked attendance for Class 11B"),
            subtitle: Text("8:45 AM"),
          ),
          ListTile(
            title: Text("David Brown marked attendance for Class 9C"),
            subtitle: Text("8:30 AM"),
          ),
        ],
      ),
    );
  }
}

class AttendanceOverview extends StatelessWidget {
  const AttendanceOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5.r)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Attendance Overview",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          const Text("Class 10A - 35/38 present"),
          const Text("Class 11B - 32/34 present"),
          const Text("Class 9C - 36/40 present"),
        ],
      ),
    );
  }
}
