import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;
  final void Function() onTap;

  const DashboardCard(
      {super.key,
      required this.title,
      required this.count,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 155.w,
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30.sp),
            SizedBox(height: 10.h),
            Text(count,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 5.h),
            Text(title,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
