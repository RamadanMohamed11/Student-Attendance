// import 'package:flutter/material.dart';

// class CustomButon extends StatelessWidget {
//   CustomButon({super.key, this.onTap, required this.text});
//   VoidCallback? onTap;
//   String text;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         width: double.infinity,
//         height: 60,
//         child: Center(
//           child: Text(text),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40.h,
        width: 280.w,
        decoration: BoxDecoration(
            color: kSecondaryColor, borderRadius: BorderRadius.circular(12.r)),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 25.sp),
            ),
          ),
        ),
      ),
    );
  }
}
