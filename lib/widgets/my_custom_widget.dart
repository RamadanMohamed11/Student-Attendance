import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kSecondaryColor,
              width: 5.w,
            ),
          ),
          child: Center(
            child: Text(
              "S|A",
              style: TextStyle(
                color: kSecondaryColor,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Student ",
              style: TextStyle(fontSize: 23.sp),
            ),
            Container(
              height: 26.h,
              width: 4.w,
              color: kSecondaryColor,
            ),
            Text(
              " Attendance",
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ],
    );
  }
}
