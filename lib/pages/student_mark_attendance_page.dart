import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
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
  // Key to force rebuild of the StudentAttendanceInfo widget
  Key _attendanceInfoKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _updatePages();
  }

  // Method to update pages with fresh instances
  void _updatePages() {
    pages = [
      StudentAttendanceInfo(
          key: _attendanceInfoKey,
          student: widget.student, 
          subjectModel: widget.subjectModel),
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

        // Check if the widget is still mounted before proceeding
        if (!mounted) return;

        // Store the current context to check if it's still valid later
        final currentContext = context;

        String qrCodeNow = await AuthenticationService()
            .getQRCode(widget.subjectModel.subjectCode!);
        if (qrText == qrCodeNow) {
          AuthenticationService().updateStudentAttendance(
            widget.subjectModel.subjectCode!,
            widget.student.email.toString(),
            DateFormat('yyyy-MM-dd')
                .format(DateTime.now()), // Use standardized date format
          );
          if (mounted) {
            // Create a new instance of StudentAttendanceInfo with a new key to force refresh
            _attendanceInfoKey = UniqueKey();
            _updatePages();

            // Update the bottom navigation bar to show the first tab
            final CurvedNavigationBarState? navBarState = _bottomNavigationKey.currentState;
            navBarState?.setPage(0);

            // Switch to the first page (student_attendance_info)
            setState(() {
              _page = 0;

              // Hide any existing snackbars
              ScaffoldMessenger.of(currentContext).hideCurrentSnackBar();

              // Show success message
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)
                  ),
                  content: Center(
                    child: Text(
                      'Attendance marked successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
              );
            });
          }
        } else {
          // Check if the widget is still mounted AND if we're still on the scanner page
          if (qrText != null && mounted) {
            // Check if the current context is still valid and the scanner is active
            // This prevents showing the snackbar if the user has navigated away
            if (_page == 1) {
              // Show a temporary error message that disappears after a few seconds
              ScaffoldMessenger.of(currentContext)
                ..hideCurrentSnackBar() // Hide any existing snackbars
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2), // Short duration
                    backgroundColor: Color(0xffA31D1D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    content: Center(
                      child: Text('Invalid QR Code',
                          style: TextStyle(
                              color: kTextColor,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
            }
          }
        }
      }
    } catch (e) {
      print('Error in QR code scanning: $e');
      if (mounted && _page == 1) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
                duration: const Duration(seconds: 2), // Short duration
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
    extends State<StudentMarkAttendancePage2> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (state == AppLifecycleState.resumed) {
      if (_isActive && _controller == null) {
        _initializeScanner();
      }
    } else if (state == AppLifecycleState.inactive || 
               state == AppLifecycleState.paused || 
               state == AppLifecycleState.detached) {
      _disposeScanner();
    }
  }

  void _initializeScanner() {
    if (_controller != null) return; // Already initialized
    
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: const [BarcodeFormat.qrCode], // Only scan QR codes
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

  void _disposeScanner() {
    try {
      _controller?.dispose();
      _controller = null;
    } catch (e) {
      print('Error disposing scanner: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isActive = false;
    _disposeScanner();
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
                _disposeScanner();
                _initializeScanner();
              },
              child: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      // Handle back button press to properly dispose of resources
      onWillPop: () async {
        _disposeScanner();
        return true;
      },
      child: Column(
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
                                _disposeScanner();
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
      ),
    );
  }
}
