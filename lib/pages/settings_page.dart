import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';
import '../models/subject_model.dart';
import '../services/authentication_service.dart';
import '../widgets/custom_textfield.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.subjectModel});

  final SubjectModel subjectModel;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController lecturesNumberController =
      TextEditingController();
  final TextEditingController lectureMarkController = TextEditingController();

  late String name;
  late String lecturesNumber;
  late String lectureMark;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.subjectModel.subjectName;
    lecturesNumberController.text = widget.subjectModel.totalLectures;
    lectureMarkController.text = widget.subjectModel.lecturesMark;
  }

  void nameOnSavedMethod(String? value) {
    name = value!;
  }

  void lecturesNumberOnSavedMethod(String? value) {
    lecturesNumber = value!;
  }

  void lectureMarkOnSavedMethod(String? value) {
    lectureMark = value!;
  }

  String? validatorMethod(value) {
    if (value == null || value.isEmpty) {
      return "This field can't be empty";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(8.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 50.h),
            CustomTextFormField(
              maxLines: 1,
              myController: nameController,
              hintText: "Subject Name",
              validatorMethod: validatorMethod,
              onSavedMehod: nameOnSavedMethod,
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
                    SubjectModel subjectModel = SubjectModel(
                      subjectName: name,
                      subjectCode: widget.subjectModel.subjectCode,
                      profEmail: widget.subjectModel.profEmail,
                      totalLectures: lecturesNumber,
                      lecturesMark: lectureMark,
                      studentList: widget.subjectModel.studentList,
                      studentAttendance: widget.subjectModel.studentAttendance,
                    );
                    AuthenticationService().updateSubject(subjectModel);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.greenAccent,
                          content: Text('Subject updated successfully',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21.sp,
                                  fontWeight: FontWeight.bold))),
                    );
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
                          Icons.edit,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Edit Subject",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30.sp, color: kTextColor),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(height: 25.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    lecturesNumberController.dispose();
    lectureMarkController.dispose();
  }
}
