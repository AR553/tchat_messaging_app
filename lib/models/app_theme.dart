import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppTheme extends GetxController{
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  void updateThemeMode(ThemeMode mode) {
    _mode = mode;
    update();
  }

}