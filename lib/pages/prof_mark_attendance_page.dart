import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/services/authentication_service.dart';

import '../colors.dart';

// class MarkAttendancePage extends StatefulWidget {
//   const MarkAttendancePage({super.key});

//   static const String id = 'mark_attendance_page';

//   @override
//   _MarkAttendancePageState createState() => _MarkAttendancePageState();
// }

// class _MarkAttendancePageState extends State<MarkAttendancePage> {
//   String qrData = "Initial QR Code";
//   late Timer timer;

//   @override
//   void initState() {
//     super.initState();
//     _generateQRCode();
//     timer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       _generateQRCode();
//       print("QR Code refreshed: $qrData");
//     });
//   }

//   void _generateQRCode() {
//     setState(() {
//       qrData =
//           "Attendance-${Random().nextInt(100000)}"; // Generate random QR data
//     });
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kPrimaryColor,
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Attendance"),
//         backgroundColor: kSecondaryColor,
//       ),
//       body: MarkAttendanceP(qrData: qrData),
//     );
//   }
// }

// QR code = Subject Code + Random Number
// Put the QR code of the subject in the database and the student will scan the QR code to mark attendance
// If the QR code is not the same as in the database at this time, then the student will not be able to mark attendance
// If the QR code is the same as in the database at this time, then the student will be able to mark attendance

class ProfMarkAttendancePage extends StatefulWidget {
  const ProfMarkAttendancePage({
    super.key,
    // required this.qrData,
    required this.subjectModel,
  });

  // final String qrData;
  final SubjectModel subjectModel;

  @override
  State<ProfMarkAttendancePage> createState() => _ProfMarkAttendancePageState();
}

class _ProfMarkAttendancePageState extends State<ProfMarkAttendancePage> {
  String qrData = "Initial QR Code";
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _generateQRCode();
      print("QR Code refreshed: $qrData");
    });
  }

  void _generateQRCode() {
    setState(() {
      qrData =
          "${widget.subjectModel.subjectCode}-${Random().nextInt(100000)}"; // Generate random QR data
      AuthenticationService()
          .saveQRCodeToFirebase(qrData, widget.subjectModel.subjectCode!);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: kSecondaryColor, width: 6.w),
            borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Attendance QR Code",
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 5.h),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.sp,
              ),
              SizedBox(height: 5.h),
              Text(
                "QR Code refreshes every 10 seconds",
                style: TextStyle(fontSize: 18.sp, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
