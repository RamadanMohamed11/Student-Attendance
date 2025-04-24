import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.myController,
      required this.validatorMethod,
      required this.hintText,
      required this.onSavedMehod,
      required this.maxLines});
  final String? Function(String?)? validatorMethod;
  final TextEditingController myController;
  final Function(String?)? onSavedMehod;
  final String hintText;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: kSecondaryColor, fontSize: 26.sp),
      maxLines: maxLines,
      onSaved: onSavedMehod,
      controller: myController,
      validator: validatorMethod,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(
                color: kSecondaryColor,
              ),
              borderRadius: BorderRadius.circular(12.r)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: kSecondaryColor)),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 26.sp, color: kSecondaryColor)),
    );
  }
}
