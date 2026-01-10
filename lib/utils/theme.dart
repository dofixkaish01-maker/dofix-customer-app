import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  useMaterial3: false,
  fontFamily: 'AlbertSans',
  primaryColor: const Color(0xFF207FA8),
  secondaryHeaderColor: const Color(0xFF92B2DD),
  disabledColor: const Color(0xFF000000),
  brightness: Brightness.light,
  highlightColor: Color(0xffA0Df6D),
  hintColor: const Color(0xFF000000).withOpacity(0.60),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B9EFB))),
  colorScheme: const ColorScheme.light(
          primary: Color(0xFF3B9EFB), secondary: Color(0xFF3B9EFB))
      .copyWith(error: const Color(0xFF3B9EFB)),
);
const Color blackColor = Color(0xff171414);
const Color redColor = Colors.redAccent;
const Color profileRedColor = Color(0xffD27D7D);
const Color categorybgImage = Color(0xffefe0c3);
const Color primaryPinkColor = Colors.pinkAccent;
const Color primaryColorDuskyWhite = Color(0xfff4f4f4);
const Color darkRed = Color(0xffAF1818);
const Color primaryBlue = Color(0xFF207FA8);
const Color ratingsOrange = Color(0xFFFFAC33);
const Color grey = Color(0xFF212121);
