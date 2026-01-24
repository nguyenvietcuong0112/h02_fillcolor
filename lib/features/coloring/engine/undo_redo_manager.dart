import 'package:flutter/material.dart';
import '../../../data/models/brush_stroke.dart';

/// Action types for undo/redo
enum ActionType {
  fill,
  brushStroke,
  clearAll,
}

/// Represents an action that can be undone/redone
class UndoRedoAction {
  final ActionType type;
  final Map<String, Color>? fillChanges; // For fill actions
  final BrushStroke? brushStroke; // For brush actions
  final Map<String, Color>? previousFills; // For clear all

  UndoRedoAction({
    required this.type,
    this.fillChanges,
    this.brushStroke,
    this.previousFills,
  });
}

/// Manager for undo/redo functionality
class UndoRedoManager {
  final List<UndoRedoAction> _undoStack = [];
  final List<UndoRedoAction> _redoStack = [];
  final int _maxSteps;

  UndoRedoManager({int maxSteps = 50}) : _maxSteps = maxSteps;

  /// Add fill action to undo stack
  void addFillAction(Map<String, Color> fillChanges) {
    _redoStack.clear();
    _undoStack.add(UndoRedoAction(
      type: ActionType.fill,
      fillChanges: Map.from(fillChanges),
    ));
    _limitStackSize();
  }

  /// Add brush stroke action to undo stack
  void addBrushAction(BrushStroke stroke) {
    _redoStack.clear();
    _undoStack.add(UndoRedoAction(
      type: ActionType.brushStroke,
      brushStroke: stroke,
    ));
    _limitStackSize();
  }

  /// Add clear all action
  void addClearAllAction(Map<String, Color> previousFills) {
    _redoStack.clear();
    _undoStack.add(UndoRedoAction(
      type: ActionType.clearAll,
      previousFills: Map.from(previousFills),
    ));
    _limitStackSize();
  }

  /// Undo last action
  UndoRedoAction? undo() {
    if (_undoStack.isEmpty) return null;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    return action;
  }

  /// Redo last undone action
  UndoRedoAction? redo() {
    if (_redoStack.isEmpty) return null;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    return action;
  }

  /// Check if can undo
  bool canUndo() => _undoStack.isNotEmpty;

  /// Check if can redo
  bool canRedo() => _redoStack.isNotEmpty;

  /// Clear all stacks
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Limit stack size
  void _limitStackSize() {
    if (_undoStack.length > _maxSteps) {
      _undoStack.removeAt(0);
    }
  }

  /// Get undo stack size
  int get undoStackSize => _undoStack.length;

  /// Get redo stack size
  int get redoStackSize => _redoStack.length;
}

