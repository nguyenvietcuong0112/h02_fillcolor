import 'package:flutter/material.dart';
import '../../../data/models/brush_stroke.dart';

/// Engine for handling brush strokes
/// 
/// Restored to support "Brush Strokes" logic:
/// - Stores vector paths as BrushStroke objects.
/// - Each stroke is associated with a pathId for clipping.
class BrushEngine {
  final List<BrushStroke> _strokes = [];
  BrushStroke? _currentStroke;

  /// Start a new stroke
  void startStroke(
    Offset point,
    Color color,
    double size,
    double opacity, {
    String? pathId,
  }) {
    _currentStroke = BrushStroke(
      points: [point],
      color: color,
      size: size,
      opacity: opacity,
      pathId: pathId,
    );
    _strokes.add(_currentStroke!);
  }

  /// Add a point to the current stroke
  void addPointToStroke(Offset point) {
    if (_currentStroke == null) return;
    
    // Optimize: Don't add if point is too close to last point
    if (_currentStroke!.points.isNotEmpty) {
      final lastPoint = _currentStroke!.points.last;
      if ((point - lastPoint).distance < 2.0) return;
    }

    final updatedPoints = List<Offset>.from(_currentStroke!.points)..add(point);
    
    // Update the stroke in the list
    final index = _strokes.indexOf(_currentStroke!);
    if (index != -1) {
      _currentStroke = _currentStroke!.copyWith(points: updatedPoints);
      _strokes[index] = _currentStroke!;
    }
  }

  /// End current stroke
  void endStroke() {
    _currentStroke = null;
  }

  /// Get all strokes
  List<BrushStroke> getStrokes() {
    return List.unmodifiable(_strokes);
  }

  /// Clear all strokes
  void clearAllStrokes() {
    _strokes.clear();
    _currentStroke = null;
  }
  
  /// Remove last stroke (for undo)
  void removeLastStroke() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
    }
  }

  /// Add stroke (for redo)
  void addStroke(BrushStroke stroke) {
    _strokes.add(stroke);
  }
}
