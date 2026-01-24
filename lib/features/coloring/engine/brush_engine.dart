import 'package:flutter/material.dart';
import '../../../data/models/brush_stroke.dart';

/// Engine for handling brush strokes
class BrushEngine {
  final List<BrushStroke> _strokes = [];
  final List<BrushStroke> _redoStack = [];

  /// Add a point to the current stroke
  void addPointToStroke(
    Offset point,
    Color color,
    double size,
    double opacity, {
    String? pathId,
  }) {
    if (_strokes.isEmpty || _strokes.last.points.length > 100) {
      // Start new stroke if empty or current stroke is too long
      _strokes.add(
        BrushStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
          pathId: pathId,
        ),
      );
    } else {
      // Add point to current stroke
      final currentStroke = _strokes.last;
      _strokes[_strokes.length - 1] = currentStroke.copyWith(
        points: [...currentStroke.points, point],
      );
    }
    // Clear redo stack when new action is performed
    _redoStack.clear();
  }

  /// Complete current stroke
  void completeStroke() {
    // Stroke is already complete when addPointToStroke is called
  }

  /// Get all strokes
  List<BrushStroke> getStrokes() {
    return List.unmodifiable(_strokes);
  }

  /// Undo last stroke
  BrushStroke? undoLastStroke() {
    if (_strokes.isNotEmpty) {
      final lastStroke = _strokes.removeLast();
      _redoStack.add(lastStroke);
      return lastStroke;
    }
    return null;
  }

  /// Redo last undone stroke
  BrushStroke? redoLastStroke() {
    if (_redoStack.isNotEmpty) {
      final stroke = _redoStack.removeLast();
      _strokes.add(stroke);
      return stroke;
    }
    return null;
  }

  /// Clear all strokes
  void clearAllStrokes() {
    _strokes.clear();
    _redoStack.clear();
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

  /// Check if can undo
  bool canUndo() => _strokes.isNotEmpty;

  /// Check if can redo
  bool canRedo() => _redoStack.isNotEmpty;
}

