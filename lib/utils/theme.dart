import 'package:flutter/material.dart';

class BTColor {
  static Color background = const Color(0xFF1A1F24);
  static Color darkBackground = const Color(0xFF111417);
  static Color brighterGreen = const Color(0xFF1DB954);
  static Color brighterRed = const Color(0xFFf73939);
  static Color errorRed = const Color(0xFFfa8a8a);
  static Color darkerErrorRed = const Color(0x9af06a6a);
  static Color successGreen = const Color(0xFF39d2c0);
  static Color darkerSuccessGreen = const Color(0x4d39d2c0);
  static Color normal = const Color(0xFFa5e6ff);
  static Color darkBlue = const Color(0xFF4F56FF);
}

class BTTextTheme {
  static TextStyle headline1 = const TextStyle(
      fontSize: 24,
      color: Color(0xFFf8f8f8),
      fontWeight: FontWeight.w600,
      letterSpacing: 1);
  static TextStyle headline2 = const TextStyle(
      fontSize: 22, color: Color(0xFFa5e6ff), fontWeight: FontWeight.w500);
  static TextStyle headline3 = const TextStyle(
      fontSize: 20, color: Color(0xFF4971ff), fontWeight: FontWeight.w500);
  static TextStyle subtitle1 = const TextStyle(
      fontSize: 18, color: Color(0xFFbdbdbd), fontWeight: FontWeight.w400);
  static TextStyle subtitle2 = const TextStyle(
      fontSize: 16, color: Color(0xFF757575), fontWeight: FontWeight.w400);
  static TextStyle bodyText1 = const TextStyle(
      fontSize: 14, color: Color(0xFF8b97a2), fontWeight: FontWeight.w400);
  static TextStyle bodyText2 = const TextStyle(
      fontSize: 14, color: Color(0xFF96dfff), fontWeight: FontWeight.w400);
}
