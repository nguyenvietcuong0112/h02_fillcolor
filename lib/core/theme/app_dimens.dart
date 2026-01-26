import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Application dimensions and metrics
/// 
/// Centralizes spacing, radius, and sizing constants.
/// Uses ScreenUtil for responsiveness.
class AppDimens {
  AppDimens._();

  // Spacing (Padding/Margin)
  static final double space2 = 2.w;
  static final double space4 = 4.w;
  static final double space8 = 8.w;
  static final double space12 = 12.w;
  static final double space16 = 16.w;
  static final double space20 = 20.w;
  static final double space24 = 24.w;
  static final double space32 = 32.w;
  static final double space40 = 40.w;
  static final double space48 = 48.w;

  // Radius
  static final double radius4 = 4.r;
  static final double radius8 = 8.r;
  static final double radius12 = 12.r;
  static final double radius16 = 16.r;
  static final double radius24 = 24.r;
  static final double radiusMax = 100.r;

  // Icon Sizes
  static final double iconSmall = 16.w;
  static final double iconMedium = 24.w;
  static final double iconLarge = 32.w;
  static final double iconXLarge = 48.w;

  // Widget specific
  static final double buttonHeight = 48.h;
  static final double inputHeight = 56.h;
}
