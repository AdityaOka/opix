import 'package:flutter/material.dart';

class SizeConfig {
  static double screenWidth = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }

  static double widthPercent(double percent) => screenWidth * percent / 100;

  static double heightPercent(double percent) => screenHeight * percent / 100;
}
