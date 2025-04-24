import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class EmailTextFieldWidget extends StatelessWidget {
  void Function(String?)? emailOnSave;
  String? Function(String?)? emailValidationMethod;
  EmailTextFieldWidget(
      {super.key,
      required this.emailOnSave,
      required this.emailValidationMethod});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: kSecondaryColor, fontSize: 18.sp),
      onSaved: emailOnSave,
      validator: emailValidationMethod,
      decoration: InputDecoration(
          fillColor: kTextFieldColor,
          filled: true,
          prefixIcon: Icon(
            Icons.email,
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
          hintText: "Enter your email",
          hintStyle: TextStyle(fontSize: 18.sp),
          labelText: "Email",
          labelStyle: TextStyle(color: kSecondaryColor, fontSize: 18.sp)),
    );
  }
}
