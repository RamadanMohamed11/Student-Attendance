import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void changeTheme() {
    final ThemeMode newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    // save to box
    final box = Hive.box('settings');
    box.put("isDarkMode", newTheme == ThemeMode.dark);
    emit(newTheme);
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    final isDarkMode = box.get("isDarkMode", defaultValue: false);
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
