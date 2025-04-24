import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class NameTextFieldWidget extends StatelessWidget {
  void Function(String?)? nameOnSave;
  String? Function(String?)? nameValidationMethod;
  NameTextFieldWidget(
      {super.key,
      required this.nameOnSave,
      required this.nameValidationMethod});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: kSecondaryColor,
      onSaved: nameOnSave,
      validator: nameValidationMethod,
      style: TextStyle(color: kSecondaryColor, fontSize: 18.sp),
      decoration: InputDecoration(
          fillColor: kTextFieldColor,
          filled: true,
          prefixIcon: Icon(
            Icons.account_circle,
            size: 28.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kSecondaryColor),
              borderRadius: BorderRadius.circular(20.r)),
          errorStyle: TextStyle(fontSize: 13.sp),
          hintText: "Enter your name",
          hintStyle: TextStyle(fontSize: 18.sp),
          labelText: "Name",
          labelStyle: TextStyle(color: kSecondaryColor, fontSize: 18.sp)),
    );
  }
}
