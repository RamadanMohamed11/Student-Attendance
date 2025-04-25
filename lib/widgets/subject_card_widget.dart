import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/helper/tansitions.dart';
import 'package:student_attendance/models/user_model.dart';
import 'package:student_attendance/pages/dashboard_page.dart';
import 'package:student_attendance/pages/student_mark_attendance_page.dart';
import 'package:student_attendance/services/authentication_service.dart';

import '../colors.dart';
import '../models/subject_model.dart';

class SubjectCardWidget extends StatelessWidget {
  const SubjectCardWidget(
      {super.key,
      required this.subjectModel,
      required this.isDoctor,
      this.student});

  final SubjectModel subjectModel;
  final bool isDoctor;
  final UserModel? student;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete, color: Colors.white, size: 30),
            Text('Delete',
                style: TextStyle(color: Colors.white, fontSize: 22.sp)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Subject'),
            content:
                const Text('Are you sure you want to delete this subject?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  if (isDoctor) {
                    AuthenticationService()
                        .deleteSubject(subjectModel.subjectCode!);
                    AuthenticationService()
                        .removeSubjectFromUser(subjectModel.subjectCode!);
                  } else {
                    AuthenticationService()
                        .removeSubjectFromUser(subjectModel.subjectCode!);
                    AuthenticationService()
                        .removeUserFromSubject(subjectModel.subjectCode!);
                  }

                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
      child: InkWell(
        onLongPress: isDoctor
            ? () {
                Clipboard.setData(
                    ClipboardData(text: subjectModel.subjectCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      content: Text('Subject code copied to clipboard',
                          style: TextStyle(
                              color: kTextColor,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.bold))),
                );
              }
            : null,
        onTap: () {
          // Navigator.pushNamed(context, DashboardPage.id);

          if (isDoctor) {
            Navigator.push(
                context,
                CustomScaleTransition(DashboardPage(subjectModel: subjectModel),
                    alignment: Alignment.center));
          } else {
            Navigator.push(
                context,
                CustomScaleTransition(
                    StudentMarkAttendancePage(
                      subjectModel: subjectModel,
                      student: student!,
                    ),
                    alignment: Alignment.center));
          }
        },
        child: Container(
          margin: EdgeInsets.all(10.sp),
          padding: EdgeInsets.all(10.sp),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffA31D1D),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(children: [
            Row(
              children: [
                Icon(Icons.book, size: 24.sp, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(subjectModel.subjectName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.sp,
                          color: Colors.white)),
                ),
              ],
            ),
            Divider(
              color: kTextColor,
              thickness: 2.sp,
              endIndent: 100.w,
            ),
            Row(
              children: isDoctor
                  ? [
                      Icon(Icons.key, color: Colors.white, size: 22.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text("Code: ${subjectModel.subjectCode}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: Colors.black)),
                      )
                    ]
                  : [const SizedBox()],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.event_note, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text("Total Lectures: ${subjectModel.totalLectures}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.grade, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text("Total Marks: ${subjectModel.lecturesMark}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.black)),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
