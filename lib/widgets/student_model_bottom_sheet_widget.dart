import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:student_attendance/models/subject_model.dart';
import 'package:student_attendance/services/authentication_service.dart';
import 'package:student_attendance/widgets/custom_textfield.dart';

class StudentModelBottomSheetWidget extends StatefulWidget {
  const StudentModelBottomSheetWidget({
    super.key,
  });

  @override
  State<StudentModelBottomSheetWidget> createState() =>
      _StudentModelBottomSheetWidgetState();
}

class _StudentModelBottomSheetWidgetState
    extends State<StudentModelBottomSheetWidget> {
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController subjectCodeController = TextEditingController();

  late String subjectCode;

  void subjectCodeOnSavedMethod(String? value) {
    subjectCode = value!;
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
                myController: subjectCodeController,
                hintText: "Subject Code",
                validatorMethod: validatorMethod,
                onSavedMehod: subjectCodeOnSavedMethod,
              ),
              SizedBox(height: 25.h),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Center(
                      child: ProgressButton.icon(
                          radius: 10.r,
                          height: 50.h,
                          minWidth: 70.w,
                          maxWidth: 350.w,
                          textStyle:
                              TextStyle(fontSize: 23.sp, color: Colors.white),
                          iconedButtons: {
                            ButtonState.idle: IconedButton(
                              color: Colors.red,
                              text: 'Add Subject',
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                            ButtonState.loading: IconedButton(
                              color: Colors.blue,
                              text: 'Loading',
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                            ButtonState.fail: IconedButton(
                              color: Colors.red,
                              text: 'Subject does not exist',
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                            ButtonState.success: IconedButton(
                              color: Colors.green,
                              text: 'Success',
                              icon: Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                          },
                          state: stateTextWithIcon,
                          onPressed: () async {
                            switch (stateTextWithIcon) {
                              case ButtonState.idle:
                                if (_formKey.currentState!.validate()) {
                                  stateTextWithIcon = ButtonState.loading;
                                  setState(() {});
                                  _formKey.currentState!.save();

                                  List<SubjectModel> subjects =
                                      await AuthenticationService()
                                          .getSubjects()
                                          .first
                                          .then((snapshot) {
                                    return snapshot.docs
                                        .map((doc) =>
                                            SubjectModel.fromDocument(doc))
                                        .toList();
                                  });
                                  bool subjectExists = false;
                                  for (SubjectModel subject in subjects) {
                                    if (subject.subjectCode == subjectCode) {
                                      subjectExists = true;
                                      break;
                                    }
                                  }
                                  if (subjectExists) {
                                    AuthenticationService()
                                        .addSubjectToUser(subjectCode);
                                    stateTextWithIcon = ButtonState.success;
                                    AuthenticationService()
                                        .addUserToSubject(subjectCode);
                                    setState(() {});
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    stateTextWithIcon = ButtonState.fail;
                                    setState(() {});
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      stateTextWithIcon = ButtonState.idle;
                                      setState(() {});
                                    });
                                  }

                                  // AuthenticationService().addSubject(SubjectModel(
                                  //   subjectName: subjectName,
                                  //   subjectCode: "subjectCode",
                                  //   teacherName: "teacherName",
                                  //   totalLectures: lecturesNumber,
                                  //   lecturesMark: lectureMark,
                                  //   subjectID: "subjectID",
                                  // ));
                                }
                                break;
                              case ButtonState.loading:
                              case ButtonState.fail:
                              case ButtonState.success:
                                break;
                            }
                          }))

                  // InkWell(
                  //   onTap: () {
                  //     if (_formKey.currentState!.validate()) {
                  //       _formKey.currentState!.save();
                  //       AuthenticationService().addSubjectToUser(subjectCode);
                  //       // AuthenticationService().addSubject(SubjectModel(
                  //       //   subjectName: subjectName,
                  //       //   subjectCode: "subjectCode",
                  //       //   teacherName: "teacherName",
                  //       //   totalLectures: lecturesNumber,
                  //       //   lecturesMark: lectureMark,
                  //       //   subjectID: "subjectID",
                  //       // ));
                  //     }
                  //   },
                  //   child: const CustomAnimatedButton(),
                  // ),

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
    subjectCodeController.dispose();
  }
}
