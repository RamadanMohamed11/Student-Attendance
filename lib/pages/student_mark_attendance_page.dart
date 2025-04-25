import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/main.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/student_attendance_info.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'package:student_attendance/widgets/oval_right_border_clipper.dart';
import 'package:student_attendance/widgets/theme_mode_button.dart';

class StudentMarkAttendancePage extends StatefulWidget {
  const StudentMarkAttendancePage(
      {super.key, required this.subjectModel, required this.student});

  final SubjectModel subjectModel;
  final UserModel student;

  @override
  _StudentMarkAttendancePageState createState() =>
      _StudentMarkAttendancePageState();
}

class _StudentMarkAttendancePageState extends State<StudentMarkAttendancePage> {
  String? qrText;
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  List<dynamic> pages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [
      StudentAttendanceInfo(
          student: widget.student, subjectModel: widget.subjectModel),
      StudentMarkAttendancePage2(onDetect: onDetect)
    ];
  }

  void onDetect(barcodeCapture) async {
    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue != null) {
      qrText = barcode.rawValue;
      String qrCodeNow = await AuthenticationService()
          .getQRCode(widget.subjectModel.subjectCode!);
      if (qrText == qrCodeNow) {
        AuthenticationService().updateStudentAttendance(
          widget.subjectModel.subjectCode!,
          widget.student.email.toString(),
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (qrText != null) {
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Color(0xffA31D1D),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                content: Center(
                  child: Text('Invalid QR Code',
                      style: TextStyle(
                          color: kTextColor,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.bold)),
                )),
          );
        }
      }
      // print(qrText);
      // You can add additional logic here to handle the scanned QR code,
      // such as marking attendance in the database.
      // _sendMessageToOwner(qrText!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
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
          // Icon(
          //   Icons.settings,
          //   size: 32.sp,
          //   color: Colors.white,
          // ),
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

class StudentMarkAttendancePage2 extends StatefulWidget {
  const StudentMarkAttendancePage2({super.key, required this.onDetect});
  final void Function(BarcodeCapture)? onDetect;
  @override
  State<StudentMarkAttendancePage2> createState() =>
      _StudentMarkAttendancePage2State();
}

class _StudentMarkAttendancePage2State
    extends State<StudentMarkAttendancePage2> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: MobileScanner(
            onDetect: widget.onDetect,
          ),
        ),
      ],
    );
  }
}
