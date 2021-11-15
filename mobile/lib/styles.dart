import 'dart:math';
import 'package:flutter/material.dart';

const Color primarySwatchLight = Color(0xFF333435);
const Color primarySwatchDark = Color(0xFFE5E5ED);

const Color backgroundColor = Color(0xFF31495e);

const Color buttonColorGray = Color(0xFF4A4A4C);
const Color buttonColorRed = Color(0xFFc63939);
const buttonTextColor = Color(0xFFE5E5ED);


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

ThemeData lightTheme = ThemeData(
  primarySwatch: generateMaterialColor(primarySwatchLight),
  brightness: Brightness.light,
);

ThemeData darkTheme = ThemeData(
  primarySwatch: generateMaterialColor(primarySwatchDark),
  brightness: Brightness.dark,
);
