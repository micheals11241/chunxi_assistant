import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color lightRed = Color(0xFFEF5350);
  static const Color darkRed = Color(0xFFB71C1C);

  // 金色
  static const Color gold = Color(0xFFFFD700);
  static const Color lightGold = Color(0xFFFFEB3B);
  static const Color darkGold = Color(0xFFFFC107);

  // 背景色
  static const Color background = Color(0xFFFFFBF0);
  static const Color cardBackground = Colors.white;

  // 文字颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryRed,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        primary: primaryRed,
        secondary: gold,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryRed,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: gold, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
      ),
    );
  }

  // 喜庆装饰边框
  static BoxDecoration festiveBoxDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: gold, width: 2),
    boxShadow: [
      BoxShadow(
        color: primaryRed.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // 渐变背景
  static LinearGradient festiveGradient = const LinearGradient(
    colors: [primaryRed, lightRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 金色渐变
  static LinearGradient goldGradient = const LinearGradient(
    colors: [gold, lightGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
