import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/coloring_image_model.dart';
import '../../data/models/svg_path_data.dart';
import '../../data/models/brush_stroke.dart';
import '../../core/constants/app_constants.dart';
import '../../services/analytics_service.dart';
import 'coloring_state.dart';
import 'engine/svg_parser.dart';
import 'engine/fill_engine.dart';
import 'engine/brush_engine.dart';
import 'engine/undo_redo_manager.dart';
import 'engine/optimized_undo_redo.dart';

/// Controller for coloring screen
class ColoringController extends StateNotifier<ColoringState> {
  final ColoringImageModel _image;
  FillEngine? _fillEngine;
  BrushEngine? _brushEngine;
  UndoRedoManager? _undoRedoManager;
  SvgPathData? _activeBrushPath;
  OptimizedUndoRedoManager? _optimizedUndoRedo;
  final Map<String, SvgPathData> _pathsMap = {};

  ColoringController(this._image)
      : super(
          ColoringState(
            image: _image,
            mode: ColoringMode.fill,
            selectedColor: Color(AppConstants.defaultColors[0]),
            brushSize: AppConstants.defaultBrushSize,
            svgPaths: [],
            filledPaths: {},
            brushStrokes: [],
            isLoading: true,
          ),
        ) {
    _initialize();
  }

  /// Initialize coloring engine
  Future<void> _initialize() async {
    try {
      // Parse SVG
      final paths = await SvgParser.parseSvg(_image.svgPath);
      for (final path in paths) {
        _pathsMap[path.id] = path;
      }

      _fillEngine = FillEngine(_pathsMap);
      _brushEngine = BrushEngine();
      _undoRedoManager = UndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);
      _optimizedUndoRedo = OptimizedUndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);

      state = state.copyWith(
        svgPaths: paths,
        isLoading: false,
      );

      AnalyticsService.instance.logColoringStarted(_image.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set coloring mode
  void setMode(ColoringMode mode) {
    if (_brushEngine != null && state.mode == ColoringMode.brush) {
      _brushEngine!.completeStroke();
    }
    state = state.copyWith(mode: mode);
  }

  /// Set selected color
  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  /// Set brush size
  void setBrushSize(double size) {
    state = state.copyWith(
      brushSize: size.clamp(AppConstants.minBrushSize, AppConstants.maxBrushSize),
    );
  }

  /// Handle tap for fill mode
  void handleTap(Offset point) {
    if (state.mode != ColoringMode.fill || _fillEngine == null) return;

    final filledPath = _fillEngine!.fillPathAtPoint(point, state.selectedColor);
    if (filledPath != null) {
      final newFills = _fillEngine!.getFilledPaths();
      // Store only changed path for undo (delta optimization)
      _undoRedoManager?.addFillAction({filledPath.id: state.selectedColor});
      _optimizedUndoRedo?.addFillAction({filledPath.id: state.selectedColor});
      state = state.copyWith(filledPaths: newFills);
      _updateUndoRedoState();
    }
  }

  /// Handle pan start for brush mode
  void handlePanStart(Offset point) {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;

    // Lock brush to the region (SVG path) at the first touch point
    _activeBrushPath = _fillEngine?.findPathAtPoint(point);
    if (_activeBrushPath == null) {
      // If user starts outside any region, ignore this stroke
      return;
    }

    if (!_activeBrushPath!.containsPoint(point)) return;

    _brushEngine!.addPointToStroke(
      point,
      state.selectedColor,
      state.brushSize,
      1.0,
      pathId: _activeBrushPath!.id,
    );
  }

  /// Handle pan update for brush mode
  void handlePanUpdate(Offset point) {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;

    // If no active region (started outside), ignore
    if (_activeBrushPath == null) return;

    // Only draw inside the locked region, even if finger moves outside on screen
    if (!_activeBrushPath!.containsPoint(point)) {
      return;
    }

    _brushEngine!.addPointToStroke(
      point,
      state.selectedColor,
      state.brushSize,
      1.0,
      pathId: _activeBrushPath!.id,
    );
    state = state.copyWith(brushStrokes: _brushEngine!.getStrokes());
  }

  /// Handle pan end for brush mode
  void handlePanEnd() {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;
    _brushEngine!.completeStroke();
    final strokes = _brushEngine!.getStrokes();
    if (strokes.isNotEmpty) {
      _undoRedoManager?.addBrushAction(strokes.last);
    }
    state = state.copyWith(brushStrokes: strokes);
    _updateUndoRedoState();

    // Reset active region for next stroke
    _activeBrushPath = null;
  }

  /// Undo last action
  void undo() {
    final action = _undoRedoManager?.undo();
    if (action == null) return;

    switch (action.type) {
      case ActionType.fill:
        if (action.fillChanges != null && _fillEngine != null) {
          for (final entry in action.fillChanges!.entries) {
            _fillEngine!.setFillColor(entry.key, null);
          }
          state = state.copyWith(filledPaths: _fillEngine!.getFilledPaths());
        }
        break;
      case ActionType.brushStroke:
        if (action.brushStroke != null && _brushEngine != null) {
          _brushEngine!.removeLastStroke();
          state = state.copyWith(brushStrokes: _brushEngine!.getStrokes());
        }
        break;
      case ActionType.clearAll:
        // Handle clear all undo
        break;
    }
    _updateUndoRedoState();
  }

  /// Redo last undone action
  void redo() {
    final action = _undoRedoManager?.redo();
    if (action == null) return;

    switch (action.type) {
      case ActionType.fill:
        if (action.fillChanges != null && _fillEngine != null) {
          for (final entry in action.fillChanges!.entries) {
            _fillEngine!.setFillColor(entry.key, entry.value);
          }
          state = state.copyWith(filledPaths: _fillEngine!.getFilledPaths());
        }
        break;
      case ActionType.brushStroke:
        if (action.brushStroke != null && _brushEngine != null) {
          _brushEngine!.addStroke(action.brushStroke!);
          state = state.copyWith(brushStrokes: _brushEngine!.getStrokes());
        }
        break;
      case ActionType.clearAll:
        // Handle clear all redo
        break;
    }
    _updateUndoRedoState();
  }

  /// Clear all
  void clearAll() {
    if (_fillEngine != null) {
      final previousFills = _fillEngine!.clearAllFills();
      _undoRedoManager?.addClearAllAction(previousFills);
    }
    if (_brushEngine != null) {
      _brushEngine!.clearAllStrokes();
    }
    state = state.copyWith(
      filledPaths: {},
      brushStrokes: [],
    );
    _updateUndoRedoState();
  }

  /// Update undo/redo state
  void _updateUndoRedoState() {
    state = state.copyWith(
      canUndo: _undoRedoManager?.canUndo() ?? false,
      canRedo: _undoRedoManager?.canRedo() ?? false,
    );
  }

  /// Get all paths for rendering
  List<SvgPathData> getPaths() {
    return state.svgPaths;
  }

  /// Get filled paths
  Map<String, Color> getFilledPaths() {
    return state.filledPaths;
  }

  /// Get brush strokes
  List<BrushStroke> getBrushStrokes() {
    return state.brushStrokes;
  }
}

/// Provider for coloring controller
final coloringControllerProvider = StateNotifierProvider.family<ColoringController, ColoringState, ColoringImageModel>(
  (ref, image) => ColoringController(image),
);

