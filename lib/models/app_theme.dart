import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppTheme extends GetxController {
  ThemeMode _mode;

  AppTheme() {
    AdaptiveTheme.getThemeMode().then((value) {
      if (value == AdaptiveThemeMode.light)
        _mode = ThemeMode.light;
      else if (value == AdaptiveThemeMode.dark)
        _mode = ThemeMode.dark;
      else
        _mode = ThemeMode.system;
    });
  }

  ThemeMode get mode => _mode;

  void updateThemeMode(ThemeMode mode) {
    _mode = mode;
    update();
  }
}