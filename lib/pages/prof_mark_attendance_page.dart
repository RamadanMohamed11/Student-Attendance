import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String qrData = '';
  bool isLoading = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    qrData = widget.subjectModel.subjectCode! +
        DateTime.now().millisecondsSinceEpoch.toString();
    
    // Initialize the timer
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _generateQRCode();
      print("QR Code refreshed: $qrData");
    });
    
    // Show confirmation dialog after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAttendanceConfirmationDialog();
    });
  }

  // Show confirmation dialog for taking attendance
  Future<void> _showAttendanceConfirmationDialog() async {
    final DateTime now = DateTime.now();
    // Ensure consistent YYYY-MM-DD format
    final String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Attendance'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to mark attendance for ${widget.subjectModel.subjectName} today?'),
                const SizedBox(height: 10),
                Text('Date: $today', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('This will create a new attendance session for today.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User confirmed, add today's date to the attendance dates list
      _addAttendanceDate(today);
    } else {
      // User cancelled, go back
      Navigator.of(context).pop();
    }
  }

  // Add today's date to the attendance dates list in Firestore
  Future<void> _addAttendanceDate(String date) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Reference to the subject document
      final subjectRef = FirebaseFirestore.instance
          .collection('Subjects')
          .doc(widget.subjectModel.subjectCode);

      // Get the current document
      final subjectDoc = await subjectRef.get();

      if (subjectDoc.exists) {
        // Check if attendanceDates field exists
        final data = subjectDoc.data() as Map<String, dynamic>;
        List<String> attendanceDates = [];

        if (data.containsKey('attendanceDates') && data['attendanceDates'] != null) {
          // Convert to List<String>
          attendanceDates = List<String>.from(data['attendanceDates']);
        }

        // Check if today's date is already in the list
        if (!attendanceDates.contains(date)) {
          attendanceDates.add(date);

          // Update the document with the new list
          await subjectRef.update({
            'attendanceDates': attendanceDates,
          });

          print('Added attendance date: $date');
        } else {
          print('Attendance date already exists: $date');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error adding attendance date: $e');
      setState(() {
        isLoading = false;
      });

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update attendance dates: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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
