import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

Future<dynamic> myShowDialogFunction(BuildContext context, String errorMessage,
    {String? pageToGo}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kPrimaryColor,
          title: Text(
            errorMessage,
            style: TextStyle(
              color: kSecondaryColor,
              fontSize: 22.sp,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (pageToGo != null) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, pageToGo, (Route<dynamic> route) => false);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                    height: 40.h,
                    width: 55.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: kSecondaryColor),
                    child: Center(
                      child: Text(
                        "Ok",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    )))
          ],
        );
      });
}
