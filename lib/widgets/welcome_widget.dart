import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class WelcomeWidget extends StatelessWidget {
  final String welcomeMessage;
  const WelcomeWidget({
    super.key,
    required this.welcomeMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(18.r))),
      child: Center(
        child: Text(
          welcomeMessage,
          style: TextStyle(color: Colors.white, fontSize: 24.sp),
        ),
      ),
    );
  }
}
