import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/main.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'package:student_attendance/widgets/oval_right_border_clipper.dart';
import 'package:student_attendance/widgets/subject_card_widget.dart';

import '../colors.dart';
import '../widgets/doctor_model_bottom_sheet_widget.dart';
import '../widgets/theme_mode_button.dart';

class DoctorSubjectsPage extends StatefulWidget {
  static const String id = 'doctor_subjects_page';
  const DoctorSubjectsPage({
    super.key,
  });

  @override
  State<DoctorSubjectsPage> createState() => _DoctorSubjectsPageState();
}

class _DoctorSubjectsPageState extends State<DoctorSubjectsPage> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
        stream: AuthenticationService().getSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isNotEmpty) {
            List<SubjectModel> subjectModels = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              var subject = SubjectModel.fromSnapshot(snapshot.data!.docs[i]);
              if (subject.profEmail ==
                  FirebaseAuth.instance.currentUser!.email) {
                subjectModels.add(subject);
              }
            }
            return Scaffold(
              // backgroundColor: kPrimaryColor,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
                centerTitle: true,
                backgroundColor: kAppBarColor,
                title: Text(
                  'Subject Added',
                  style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp),
                ),
                actions: const [ThemeModeButton()],
              ),
              drawer: ClipPath(
                clipper: OvalRightBorderClipper(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 74, 78, 101),
                          width: 3.w)),
                  child: Drawer(
                    width: screenSize.width / 1.3,
                    // backgroundColor: CustomColor.scaffoldColor,
                    child: const SidebarMenu(),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue.withOpacity(0.65),
                foregroundColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: kPrimaryColor.withOpacity(0.9),
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const DoctorModelBottomSheetWidget();
                      });
                },
                child: Icon(
                  Icons.add,
                  size: 35.sp,
                ),
              ),
              body: ListView.builder(
                itemCount: subjectModels.length,
                itemBuilder: (BuildContext context, int index) {
                  return SubjectCardWidget(
                    subjectModel: subjectModels[index],
                    isDoctor: true,
                  );
                },
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
                centerTitle: true,
                backgroundColor: kAppBarColor,
                title: Text(
                  'Subject Added',
                  style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp),
                ),
                actions: const [ThemeModeButton()],
              ),
              drawer: ClipPath(
                clipper: OvalRightBorderClipper(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 74, 78, 101),
                          width: 3.w)),
                  child: Drawer(
                    width: screenSize.width / 1.3,
                    // backgroundColor: CustomColor.scaffoldColor,
                    child: const SidebarMenu(),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue.withOpacity(0.65),
                foregroundColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: kPrimaryColor.withOpacity(0.9),
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const DoctorModelBottomSheetWidget();
                      });
                },
                child: Icon(
                  Icons.add,
                  size: 35.sp,
                ),
              ),
              body: Center(
                child: Text('No subjects added yet',
                    style: TextStyle(fontSize: 24.sp)),
              ),
            );
          }
        });
  }
}
