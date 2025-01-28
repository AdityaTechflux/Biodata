import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF5508); // Orange color

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(primaryColor.value, {
        50: primaryColor.withOpacity(0.1),
        100: primaryColor.withOpacity(0.2),
        200: primaryColor.withOpacity(0.3),
        300: primaryColor.withOpacity(0.4),
        400: primaryColor.withOpacity(0.5),
        500: primaryColor,
        600: primaryColor.withOpacity(0.6),
        700: primaryColor.withOpacity(0.7),
        800: primaryColor.withOpacity(0.8),
        900: primaryColor.withOpacity(0.9),
      }),
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp, // Responsive font size
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r), // Responsive radius
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w, // Responsive horizontal padding
          vertical: 12.h, // Responsive vertical padding
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 12.h), // Responsive padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r), // Responsive radius
          ),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp, // Responsive font size
        ),
        bodyMedium: TextStyle(
          color: Colors.grey[800],
          fontSize: 14.sp, // Responsive font size
        ),
        bodySmall: TextStyle(
          color: Colors.grey[600],
          fontSize: 12.sp, // Responsive font size
        ),
      ),
    );
  }
}
