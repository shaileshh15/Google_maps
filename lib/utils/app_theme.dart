import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF1976D2);
const Color primaryLight = Color(0xFF63A4FF);
const Color primaryDark = Color(0xFF004BA0);
const Color successColor = Color(0xFF43A047);
const Color warningColor = Color(0xFFFBC02D);
const Color errorColor = Color(0xFFD32F2F);
const Color neutralLight = Color(0xFFF5F5F5);
const Color neutralDark = Color(0xFF212121);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: neutralLight,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    secondary: primaryLight,
    error: errorColor,
    surface: neutralLight,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(primaryColor),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryDark,
  scaffoldBackgroundColor: neutralDark,
  colorScheme: const ColorScheme.dark(
    primary: primaryDark,
    secondary: primaryLight,
    error: errorColor,
    surface: neutralDark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryDark,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(primaryDark),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  ),
); 