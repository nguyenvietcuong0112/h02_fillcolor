import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a brush stroke
class BrushStroke {
  final List<Offset> points;
  final Color color;
  final double size;
  final double opacity;
  final bool isEraser;
  final String? pathId; // Optional: which SVG region this stroke belongs to
  final ui.Image? maskImage; // Optional: raster mask for drawing inside a region

  BrushStroke({
    required this.points,
    required this.color,
    required this.size,
    this.opacity = 1.0,
    this.isEraser = false,
    this.pathId,
    this.maskImage,
  });

  /// Create a copy with updated points
  BrushStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? size,
    double? opacity,
    bool? isEraser,
    String? pathId,
    ui.Image? maskImage,
  }) {
    return BrushStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      isEraser: isEraser ?? this.isEraser,
      pathId: pathId ?? this.pathId,
      maskImage: maskImage ?? this.maskImage,
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

