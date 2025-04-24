import 'package:flutter/material.dart';

import '../colors.dart';

class UsernameWidget extends StatelessWidget {
  void Function(String?)? usernameOnSave;
  String? Function(String?)? usernameValidationMethod;
  UsernameWidget(
      {super.key,
      required this.usernameOnSave,
      required this.usernameValidationMethod});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: usernameOnSave,
      validator: usernameValidationMethod,
      decoration: InputDecoration(
          fillColor: kTextFieldColor,
          filled: true,
          prefixIcon: const Icon(
            Icons.account_circle,
            size: 28,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kSecondaryColor),
              borderRadius: BorderRadius.circular(20)),
          hintText: "Enter your username",
          hintStyle: const TextStyle(fontSize: 18),
          labelText: "Username",
          labelStyle: TextStyle(color: kSecondaryColor, fontSize: 18)),
    );
  }
}
