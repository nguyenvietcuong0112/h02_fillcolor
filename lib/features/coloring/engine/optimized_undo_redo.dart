import 'package:flutter/material.dart';
import '../../../data/models/brush_stroke.dart';
import 'undo_redo_manager.dart' show ActionType;

/// Optimized undo/redo action with delta storage
class OptimizedAction {
  final ActionType type;
  final Map<String, Color>? fillDelta; // Only changed paths: {pathId: newColor}
  final BrushStroke? brushStroke;
  final Map<String, Color>? clearAllSnapshot; // Snapshot before clear

  OptimizedAction({
    required this.type,
    this.fillDelta,
    this.brushStroke,
    this.clearAllSnapshot,
  });

  /// Get size estimate in bytes (for memory management)
  int get estimatedSize {
    int size = 0;
    if (fillDelta != null) {
      size += fillDelta!.length * 20; // ~20 bytes per entry
    }
    if (brushStroke != null) {
      size += brushStroke!.points.length * 16; // ~16 bytes per point
    }
    if (clearAllSnapshot != null) {
      size += clearAllSnapshot!.length * 20;
    }
    return size;
  }
}

/// Optimized undo/redo manager with delta storage and memory limits
class OptimizedUndoRedoManager {
  final List<OptimizedAction> _undoStack = [];
  final List<OptimizedAction> _redoStack = [];
  final int _maxSteps;
  final int _maxMemoryBytes; // Max memory in bytes
  int _currentMemoryUsage = 0;

  OptimizedUndoRedoManager({
    int maxSteps = 100,
    int maxMemoryMB = 10,
  })  : _maxSteps = maxSteps,
        _maxMemoryBytes = (maxMemoryMB * 1024 * 1024).toInt();

  /// Add fill action (only stores changed paths)
  void addFillAction(Map<String, Color> changedPaths) {
    if (changedPaths.isEmpty) return;
    
    _redoStack.clear();
    
    final action = OptimizedAction(
      type: ActionType.fill,
      fillDelta: Map.from(changedPaths),
    );
    
    _addToUndoStack(action);
  }

  /// Add brush stroke action
  void addBrushAction(BrushStroke stroke) {
    _redoStack.clear();
    
    final action = OptimizedAction(
      type: ActionType.brushStroke,
      brushStroke: stroke,
    );
    
    _addToUndoStack(action);
  }

  /// Add clear all action (stores snapshot)
  void addClearAllAction(Map<String, Color> previousFills) {
    _redoStack.clear();
    
    final action = OptimizedAction(
      type: ActionType.clearAll,
      clearAllSnapshot: Map.from(previousFills),
    );
    
    _addToUndoStack(action);
  }

  /// Add action to undo stack with memory management
  void _addToUndoStack(OptimizedAction action) {
    final actionSize = action.estimatedSize;
    
    // Remove old actions if memory limit exceeded
    while (_currentMemoryUsage + actionSize > _maxMemoryBytes && _undoStack.isNotEmpty) {
      final removed = _undoStack.removeAt(0);
      _currentMemoryUsage -= removed.estimatedSize;
    }
    
    // Remove old actions if step limit exceeded
    while (_undoStack.length >= _maxSteps) {
      final removed = _undoStack.removeAt(0);
      _currentMemoryUsage -= removed.estimatedSize;
    }
    
    _undoStack.add(action);
    _currentMemoryUsage += actionSize;
  }

  /// Undo last action
  OptimizedAction? undo() {
    if (_undoStack.isEmpty) return null;
    
    final action = _undoStack.removeLast();
    _currentMemoryUsage -= action.estimatedSize;
    _redoStack.add(action);
    
    return action;
  }

  /// Redo last undone action
  OptimizedAction? redo() {
    if (_redoStack.isEmpty) return null;
    
    final action = _redoStack.removeLast();
    _addToUndoStack(action);
    
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
    _currentMemoryUsage = 0;
  }

  /// Get memory usage in MB
  double get memoryUsageMB => _currentMemoryUsage / (1024 * 1024);

  /// Get undo stack size
  int get undoStackSize => _undoStack.length;

  /// Get redo stack size
  int get redoStackSize => _redoStack.length;
}

