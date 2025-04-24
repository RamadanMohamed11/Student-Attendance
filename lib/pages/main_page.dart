// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:student_attendance/main.dart';
// import 'package:student_attendance/pages/dashboard_page.dart';
// import 'package:student_attendance/pages/mark_attendance_page.dart';
// import 'package:student_attendance/pages/settings_page.dart';
// import 'package:student_attendance/pages/subjects_page.dart';
// import 'package:student_attendance/widgets/model_bottom_sheet_widget.dart';
// import 'package:student_attendance/widgets/oval_right_border_clipper.dart';

// import '../colors.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});
//   static const String id = 'main_page';

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _page = 0;
//   DateTime dateSelected = DateTime.now();

//   List<StatefulWidget> pages = [
//     const SubjectsPage(),
//     const MarkAttendancePage(),
//     const SettingsPage(),
//   ];

//   final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     void dataPickerDialog() {
//       showDatePicker(
//         context: context,
//         initialDate: dateSelected,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2050),
//       ).then((DateTime? value) {
//         if (value != null) {
//           dateSelected = value;
//           print(dateSelected);
//         }
//       });
//     }

//     var screenSize = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: kPrimaryColor,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
//         centerTitle: true,
//         backgroundColor: kSecondaryColor,
//         title: Text(
//           'AttendanceTrack',
//           style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//               fontSize: 22.sp),
//         ),
//       ),
//       drawer: ClipPath(
//         clipper: OvalRightBorderClipper(),
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//                   color: const Color.fromARGB(255, 74, 78, 101), width: 3.w)),
//           child: Drawer(
//             width: screenSize.width / 1.3,
//             // backgroundColor: CustomColor.scaffoldColor,
//             child: const SidebarMenu(),
//           ),
//         ),
//       ),
//       body: pages[_page],
//       floatingActionButton: _page == 1
//           ? FloatingActionButton(
//               backgroundColor: Colors.blue.withOpacity(0.65),
//               foregroundColor: Colors.white,
//               onPressed: dataPickerDialog,
//               child: Icon(
//                 Icons.calendar_month_outlined,
//                 size: 35.sp,
//               ),
//             )
//           : (_page == 0
//               ? FloatingActionButton(
//                   backgroundColor: Colors.blue.withOpacity(0.65),
//                   foregroundColor: Colors.white,
//                   onPressed: () {
//                     showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         builder: (context) {
//                           return const ModelBottomSheetWidget();
//                         });
//                   },
//                   child: Icon(
//                     Icons.add,
//                     size: 35.sp,
//                   ),
//                 )
//               : null),
//       bottomNavigationBar: CurvedNavigationBar(
//         key: _bottomNavigationKey,
//         index: 0,
//         items: <Widget>[
//           Icon(
//             Icons.subject,
//             size: 30.sp,
//             color: kPrimaryColor,
//           ),
//           // Icon(
//           //   Icons.dashboard,
//           //   size: 30.sp,
//           //   color: kPrimaryColor,
//           // ),
//           // Icon(
//           //   Icons.checklist,
//           //   size: 30.sp,
//           //   color: kPrimaryColor,
//           // ),
//           Icon(
//             Icons.settings,
//             size: 30.sp,
//             color: kPrimaryColor,
//           ),
//         ],
//         color: kSecondaryColor,
//         buttonBackgroundColor: kSecondaryColor,
//         backgroundColor: kPrimaryColor,
//         animationCurve: Curves.easeInOut,
//         animationDuration: const Duration(milliseconds: 400),
//         onTap: (index) {
//           setState(() {
//             _page = index;
//             print("Page: $_page");
//           });
//         },
//         letIndexChange: (index) => true,
//       ),
//     );
//   }
// }
