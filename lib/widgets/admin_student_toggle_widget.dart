import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminStudentToggleWidget extends StatelessWidget {
  const AdminStudentToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: double.infinity,
      initialLabelIndex: 1,
      cornerRadius: 12.r,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      animate: true,
      fontSize: 25.sp,
      iconSize: 25.sp,
      totalSwitches: 2,
      centerText: true,
      minHeight: 45.h,
      animationDuration: 400,
      curve: Curves.decelerate,
      labels: const [' Doctor', 'Student'],
      icons: const [
        FontAwesomeIcons.personChalkboard,
        FontAwesomeIcons.userGraduate
      ],
      activeBgColors: const [
        [Colors.blue],
        [Colors.pink]
      ],
      onToggle: (index) {
        print('switched to: $index');
      },
    );
  }
}
