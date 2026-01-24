import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a parsed SVG path with its fillable region
class SvgPathData {
  final String id;
  final Path path;
  final Rect bounds;
  Color? fillColor;

  SvgPathData({
    required this.id,
    required this.path,
    required this.bounds,
    this.fillColor,
  });

  /// Check if a point is inside this path
  bool containsPoint(Offset point) {
    return path.contains(point);
  }

  /// Get path as ui.Path for rendering
  ui.Path get uiPath {
    return path;
  }
}

