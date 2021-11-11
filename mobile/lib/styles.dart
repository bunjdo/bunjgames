import 'dart:math';
import 'package:flutter/material.dart';

const Color baseBackgroundButton = Color(0xFF535456);
const Color baseBackgroundDark = Color(0xFF333435);
const Color baseBackground = Color(0xFF31495e);
const Color baseBackgroundSelect = Color(0xFFDBD011);
const Color baseBackgroundRed = Color(0xFF582727);

const Color baseTextColor = Color(0xFFE5E5ED);
const Color baseTextColorGray = Color(0xFF707072);
const Color baseTextColorSelect = Color(0xFF000000);
const Color valueTextColor = Color(0xFFDCCA77);

const Color buttonColorGray = Color(0xFF4A4A4C);
const Color buttonColorRed = Color(0xFFc63939);

int tintValue(int value, double factor) => max(
    0, min((value + ((255 - value) * factor)).round(), 255)
);

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1
);

int shadeValue(int value, double factor) => max(
    0, min(value - (value * factor).round(), 255)
);

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1
);

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

ThemeData appTheme = ThemeData(
  primaryColorBrightness: Brightness.dark,
  primaryColor: baseBackgroundDark,
  primarySwatch: generateMaterialColor(baseBackgroundDark),
  scaffoldBackgroundColor: baseBackground,
  hintColor: baseTextColorGray,
  canvasColor: baseBackgroundDark,
  textTheme: TextTheme(
    bodyText1: TextStyle(color: baseTextColor),
    bodyText2: TextStyle(color: baseTextColor),
    button: TextStyle(color: baseTextColor),
    caption: TextStyle(color: baseTextColor),
    subtitle1: TextStyle(color: baseTextColor),
    headline1: TextStyle(color: baseTextColor),
    headline2: TextStyle(color: baseTextColor),
    headline3: TextStyle(color: baseTextColor),
    headline4: TextStyle(color: baseTextColor),
    headline5: TextStyle(color: baseTextColor),
    headline6: TextStyle(color: baseTextColor),
  ),
  iconTheme: IconThemeData(color: baseTextColor),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: new TextStyle(color: baseTextColor),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: baseTextColor),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: baseTextColor),
    ),
    border: UnderlineInputBorder(
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(primary: Colors.white)
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: baseTextColor,
  ),
);