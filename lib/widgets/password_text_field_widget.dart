import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class PasswordTextFieldWidget extends StatefulWidget {
  final String hintText;
  final String labelText;
  final void Function(String?) passwordOnSave;

  final String? Function(String?) passwordValidationMethod;
  const PasswordTextFieldWidget(
      {super.key,
      required this.passwordOnSave,
      required this.passwordValidationMethod,
      required this.hintText,
      required this.labelText});

  @override
  State<PasswordTextFieldWidget> createState() =>
      _PasswordTextFieldWidgetState();
}

class _PasswordTextFieldWidgetState extends State<PasswordTextFieldWidget> {
  bool isObsecureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        style: TextStyle(color: kSecondaryColor, fontSize: 18.sp),
        onSaved: widget.passwordOnSave,
        validator: widget.passwordValidationMethod,
        obscureText: isObsecureText,
        decoration: InputDecoration(
          fillColor: kTextFieldColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: kSecondaryColor)),
          errorStyle: TextStyle(fontSize: 13.sp),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 18.sp),
          labelText: widget.labelText,
          labelStyle: TextStyle(color: kSecondaryColor, fontSize: 18.sp),
          prefixIcon: const Icon(Icons.password),
          suffixIcon: IconButton(
            icon:
                Icon(isObsecureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                isObsecureText = !isObsecureText;
              });
            },
          ),
        ));
  }
}
