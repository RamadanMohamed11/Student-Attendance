import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';

import '../models/subject_model.dart';
import '../widgets/theme_mode_button.dart';
import '../widgets/total_students_table_widget.dart';

class TotalStudentsPage extends StatelessWidget {
  const TotalStudentsPage({super.key, required this.subjectModel});
  static const String id = 'total_students_page';
  final SubjectModel subjectModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        title: Text('Total Students',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
        leading: const Icon(Icons.people, color: Colors.white),
        actions: const [ThemeModeButton()],
      ),
      body: TotalStudentsTableWidget(
        subjectModel: subjectModel,
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
