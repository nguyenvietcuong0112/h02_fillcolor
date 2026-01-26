import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // Component Themes
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: AppDimens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimaryLight),
        titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      
      // Colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // Component Themes
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: AppDimens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

