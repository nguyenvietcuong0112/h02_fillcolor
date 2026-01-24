import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Color utility functions
class ColorUtils {
  ColorUtils._();

  /// Convert hex color to Color
  static Color hexToColor(int hex) {
    return Color(hex);
  }

  /// Convert Color to hex
  static int colorToHex(Color color) {
    // Use toARGB32 for explicit conversion instead of deprecated .value
    return color.toARGB32();
  }

  /// Check if color is dark
  static bool isDark(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  /// Get contrast color (black or white)
  static Color getContrastColor(Color color) {
    return isDark(color) ? Colors.white : Colors.black;
  }

  /// Convert Color to ui.Color
  static ui.Color toUiColor(Color color) {
    // Use toARGB32 for explicit conversion instead of deprecated .value
    return ui.Color(color.toARGB32());
  }
}

