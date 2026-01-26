import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a parsed SVG path with its fillable region
class SvgPathData {
  final String id;
  final Path path;
  final Rect bounds;
  Color? fillColor;
  final bool isLocked;

  SvgPathData({
    required this.id,
    required this.path,
    required this.bounds,
    this.fillColor,
    this.isLocked = false,
  });

  /// Check if a point is inside this path
  /// 
  /// Senior UI approach: 
  /// - Fast bounds check trước (cheap)
  /// - Precise path.contains() check sau (expensive)
  /// - Đảm bảo bounds chính xác
  bool containsPoint(Offset point) {
    // Fast bounds check - reject nhanh nếu ngoài bounds
    if (!bounds.contains(point)) {
      return false;
    }
    
    // Precise path contains check
    // Path.contains() sử dụng winding rule, đảm bảo chính xác
    return path.contains(point);
  }

  /// Get path as ui.Path for rendering
  ui.Path get uiPath {
    return path;
  }
}

