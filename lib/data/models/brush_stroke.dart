import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a brush stroke
class BrushStroke {
  final List<Offset> points;
  final Color color;
  final double size;
  final double opacity;
  final String? pathId; // Optional: which SVG region this stroke belongs to

  BrushStroke({
    required this.points,
    required this.color,
    required this.size,
    this.opacity = 1.0,
    this.pathId,
  });

  /// Create a copy with updated points
  BrushStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? size,
    double? opacity,
    String? pathId,
  }) {
    return BrushStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      pathId: pathId ?? this.pathId,
    );
  }

  /// Convert to ui.Path for rendering
  ui.Path toPath() {
    final path = ui.Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    return path;
  }
}

