import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/models/subject_model.dart';

import '../widgets/present_students_table_widget.dart';
import '../widgets/theme_mode_button.dart';

class PresentStudentsPage extends StatelessWidget {
  const PresentStudentsPage({super.key, required this.subjectModel});
  static const String id = 'present_students_page';
  final SubjectModel subjectModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        actions: const [ThemeModeButton()],
        title: Text('Present Students',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
        leading: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: kAppBarColor,
        centerTitle: true,
      ),
      body: PresentStudentsTableWidget(
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
