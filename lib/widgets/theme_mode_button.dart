import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubits/theme_cubit/theme_cubit.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return IconButton(
          onPressed: () {
            BlocProvider.of<ThemeCubit>(context).changeTheme();
          },
          icon: themeMode == ThemeMode.light
              ? Icon(
                  Icons.dark_mode,
                  size: 35.sp,
                )
              : Icon(
                  Icons.light_mode,
                  size: 35.sp,
                ),
        );
      },
    );
  }
}
