import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'package:student_attendance/widgets/custom_textfield.dart';

import '../models/subject_model.dart';

class DoctorModelBottomSheetWidget extends StatefulWidget {
  const DoctorModelBottomSheetWidget({
    super.key,
  });

  @override
  State<DoctorModelBottomSheetWidget> createState() =>
      _DoctorModelBottomSheetWidgetState();
}

class _DoctorModelBottomSheetWidgetState
    extends State<DoctorModelBottomSheetWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController subjectNameController = TextEditingController();

  final TextEditingController lecturesNumberController =
      TextEditingController();
  final TextEditingController lectureMarkController = TextEditingController();

  late String subjectName;
  late String lecturesNumber;
  late String lectureMark;

  void subjectNameOnSavedMethod(String? value) {
    subjectName = value!;
  }

  void lecturesNumberOnSavedMethod(String? value) {
    lecturesNumber = value!;
  }

  void lectureMarkOnSavedMethod(String? value) {
    lectureMark = value!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.w,
          right: 8.w,
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Adjust for the keyboard
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 50.h),
              CustomTextFormField(
                maxLines: 1,
                myController: subjectNameController,
                hintText: "Subject Name",
                validatorMethod: validatorMethod,
                onSavedMehod: subjectNameOnSavedMethod,
              ),
              SizedBox(height: 25.h),
              CustomTextFormField(
                maxLines: 1,
                hintText: "Lectures Number",
                myController: lecturesNumberController,
                validatorMethod: validatorMethod,
                onSavedMehod: lecturesNumberOnSavedMethod,
              ),
              SizedBox(height: 25.h),
              CustomTextFormField(
                maxLines: 1,
                hintText: "Lectures Mark",
                myController: lectureMarkController,
                validatorMethod: validatorMethod,
                onSavedMehod: lectureMarkOnSavedMethod,
              ),
              SizedBox(height: 50.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      AuthenticationService().addSubject(SubjectModel(
                        subjectName: subjectName,
                        // subjectCode: "subjectCode",
                        profEmail: FirebaseAuth.instance.currentUser!.email!,
                        totalLectures: lecturesNumber,
                        lecturesMark: lectureMark,
                        studentList: [],
                        studentAttendance: [],
                      ));

                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            "Add Subject",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 30.sp, color: Colors.white),
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ),
      ),
    );
  }

  String? validatorMethod(value) {
    if (value == null || value.isEmpty) {
      return "This field can't be empty";
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subjectNameController.dispose();
    lecturesNumberController.dispose();
    lectureMarkController.dispose();
  }
}
