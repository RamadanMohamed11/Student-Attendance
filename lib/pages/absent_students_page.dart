import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/widgets/absent_students_table_widget.dart';

import '../widgets/theme_mode_button.dart';

class AbsentStudentsPage extends StatelessWidget {
  const AbsentStudentsPage({super.key, required this.subjectModel});
  static const String id = 'absent_students_page';
  final SubjectModel subjectModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      appBar: AppBar(
        actions: const [ThemeModeButton()],
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        title: Text('Absent Students',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
        leading: const Icon(Icons.cancel, color: Colors.white),
        backgroundColor: kAppBarColor,
        centerTitle: true,
      ),
      body: AbsentStudentsTableWidget(
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
