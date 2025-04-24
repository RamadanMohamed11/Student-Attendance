import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:intl/intl.dart';

import '../widgets/present_students_table_widget.dart';
import '../widgets/theme_mode_button.dart';

class PresentStudentsPage extends StatefulWidget {
  const PresentStudentsPage({
    super.key,
    required this.subjectModel,
    required this.selectedDate,
  });
  static const String id = 'present_students_page';
  final SubjectModel subjectModel;
  final String selectedDate;

  @override
  State<PresentStudentsPage> createState() => _PresentStudentsPageState();
}

class _PresentStudentsPageState extends State<PresentStudentsPage> {
  // Key to force refresh of the widget tree
  Key _refreshKey = UniqueKey();

  void _refreshStudentList() {
    // Force a rebuild of the widget tree
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format date for display
    String displayDate = widget.selectedDate;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(widget.selectedDate);
      displayDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      // Use original date if parsing fails
    }

    return Scaffold(
      // backgroundColor: kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshStudentList,
          ),
          const ThemeModeButton(),
        ],
        title: Column(
          children: [
            Text('Present Students',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
            Text(
              displayDate,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        leading: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: kAppBarColor,
        centerTitle: true,
      ),
      body: PresentStudentsTableWidget(
        key: _refreshKey,
        subjectModel: widget.subjectModel,
        selectedDate: widget.selectedDate,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.withOpacity(0.65),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
