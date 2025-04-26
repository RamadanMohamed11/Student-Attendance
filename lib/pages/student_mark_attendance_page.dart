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
    super.initState();
    pages = [
      StudentAttendanceInfo(
          student: widget.student, subjectModel: widget.subjectModel),
      StudentMarkAttendancePage2(onDetect: onDetect)
    ];
  }

  void onDetect(barcodeCapture) async {
    try {
      if (barcodeCapture.barcodes.isEmpty) {
        return;
      }
      
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
          if (qrText != null && mounted) {
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
      }
    } catch (e) {
      print('Error in QR code scanning: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              content: Center(
                child: Text('Error scanning QR code. Please try again.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold)),
              )),
        );
      }
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
            child: const SidebarMenu(),
          ),
        ),
      ),
      body: pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        items: <Widget>[
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
        ],
        color: kSecondaryColor,
        buttonBackgroundColor: Colors.red,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _page = index;
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
  MobileScannerController? _controller;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  void _initializeScanner() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize camera: $e';
      });
      print('Error initializing scanner: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Camera Error',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Failed to access camera. Please check permissions and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                _initializeScanner();
              },
              child: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: _controller != null
              ? MobileScanner(
                  controller: _controller,
                  onDetect: widget.onDetect,
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'Scanner Error',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Text(
                              error.errorDetails?.message ?? 'Unknown error occurred',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: () {
                              _initializeScanner();
                            },
                            child: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Position the QR code within the scanner frame',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}
