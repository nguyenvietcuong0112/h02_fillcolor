import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'services/coloring_storage_service.dart';

/// Controller for coloring screen
class ColoringController extends StateNotifier<ColoringState> {
  final ColoringImageModel _image;
  FillEngine? _fillEngine;
  BrushEngine? _brushEngine;
  UndoRedoManager? _undoRedoManager;
  SvgPathData? _activeBrushPath; // Unused field restored check
  OptimizedUndoRedoManager? _optimizedUndoRedo;
  final Map<String, SvgPathData> _pathsMap = {};

  ColoringController(this._image)
      : super(
          ColoringState(
            image: _image,
            mode: ColoringMode.fill, // Default, sẽ được set lại trong initState của screen
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
      _brushEngine = BrushEngine(); // No dependencies needed for simple stoke storage, 
      // but logic might need to check locks? 
      // Check locks happens in controller before calling startStroke, so engine can be simple.
      // Restoring to simple constructor.
      _undoRedoManager = UndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);
      _optimizedUndoRedo = OptimizedUndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);

      state = state.copyWith(
        svgPaths: paths,
        isLoading: false,
      );

      // Load data của mode hiện tại ngay sau khi parse SVG xong
      // Để khi vào màn hình, data đã được load sẵn
      await _loadSavedDataForMode(state.mode);

      AnalyticsService.instance.logColoringStarted(_image.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  /// Set coloring mode
  /// Khi đổi mode, clear data của mode cũ và load data của mode mới
  /// Nếu mode đã đúng, vẫn load data để đảm bảo data được refresh khi quay lại màn hình
  void setMode(ColoringMode mode) {
    final isModeChanged = state.mode != mode;
    
    // Complete current mode's work nếu đổi mode
    if (isModeChanged && _brushEngine != null && state.mode == ColoringMode.brush) {
      _brushEngine!.endStroke();
    }
    
    // Save current mode's data trước khi switch (chỉ khi đổi mode)
    if (isModeChanged) {
      if (state.mode == ColoringMode.fill) {
        ColoringStorageService.saveFillData(_image, state.filledPaths);
      } else if (state.mode == ColoringMode.brush) {
        ColoringStorageService.saveBrushData(_image, state.brushStrokes);
      }
    }
    
    // Switch mode (nếu đổi)
    if (isModeChanged) {
      state = state.copyWith(mode: mode);
    }
    
    // Luôn load data của mode hiện tại để đảm bảo data được refresh
    // Điều này đảm bảo khi quay lại màn hình, data mới nhất được load
    _loadSavedDataForMode(mode);
  }
  
  /// Load saved data cho một mode cụ thể
  Future<void> _loadSavedDataForMode(ColoringMode mode) async {
    if (mode == ColoringMode.fill) {
      // Load fill data, clear brush
      final savedFills = await ColoringStorageService.loadFillData(_image);
      if (savedFills.isNotEmpty && _fillEngine != null) {
        for (final entry in savedFills.entries) {
          _fillEngine!.setFillColor(entry.key, entry.value);
        }
        state = state.copyWith(filledPaths: savedFills);
      } else {
        state = state.copyWith(filledPaths: {});
      }
      
      // Clear brush data
      if (_brushEngine != null) {
        _brushEngine!.endStroke();
      }
      state = state.copyWith(brushStrokes: []);
    } else if (mode == ColoringMode.brush) {
      // Load brush data, clear fill
      final savedStrokes = await ColoringStorageService.loadBrushData(_image);
      if (savedStrokes.isNotEmpty && _brushEngine != null) {
        for (final stroke in savedStrokes) {
          _brushEngine!.addStroke(stroke);
        }
        state = state.copyWith(brushStrokes: savedStrokes);
      } else {
        state = state.copyWith(brushStrokes: []);
      }
      
      // Clear fill data
      if (_fillEngine != null) {
        _fillEngine!.clearAllFills();
      }
      state = state.copyWith(filledPaths: {});
    }
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
      
      // Auto-save fill data
      ColoringStorageService.saveFillData(_image, newFills);
      
      _updateUndoRedoState();

      // Haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  /// Handle pan start for brush mode
  void handlePanStart(Offset point) {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;

    // Lock brush to the region (SVG path) at the first touch point
    // This implements "Stay inside the lines"
    _activeBrushPath = _fillEngine?.findPathAtPoint(point);
    if (_activeBrushPath == null) {
      // If user starts outside any region, ignore this stroke
      return;
    }

    if (_activeBrushPath!.isLocked) return; // Don't draw on locked paths

    if (!_activeBrushPath!.containsPoint(point)) return;

    _brushEngine!.startStroke(
      point,
      state.selectedColor,
      state.brushSize,
      1.0,
      pathId: _activeBrushPath!.id,
    );
    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Handle pan update for brush mode
  void handlePanUpdate(Offset point) {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;

    // If no active region (started outside), ignore
    if (_activeBrushPath == null) return;
    
    // We allow dragging outside, but the stroke only shows inside due to Painter clipping.
    // So we just add points.
    _brushEngine!.addPointToStroke(point);
    
    state = state.copyWith(brushStrokes: _brushEngine!.getStrokes());
  }

  /// Handle pan end for brush mode
  void handlePanEnd() {
    if (state.mode != ColoringMode.brush || _brushEngine == null) return;
    
    _brushEngine!.endStroke();
    
    final strokes = _brushEngine!.getStrokes();
    if (strokes.isNotEmpty) {
      _undoRedoManager?.addBrushAction(strokes.last);
    }
    state = state.copyWith(brushStrokes: strokes);
    
    // Auto-save brush data
    ColoringStorageService.saveBrushData(_image, strokes);
    
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

  /// Clear all - chỉ clear data của mode hiện tại
  void clearAll() {
    if (state.mode == ColoringMode.fill) {
      // Clear fill data
      if (_fillEngine != null) {
        final previousFills = _fillEngine!.clearAllFills();
        _undoRedoManager?.addClearAllAction(previousFills);
        ColoringStorageService.clearFillData(_image);
      }
      state = state.copyWith(filledPaths: {});
    } else if (state.mode == ColoringMode.brush) {
      // Clear brush data
      if (_brushEngine != null) {
        _brushEngine!.clearAllStrokes();
        ColoringStorageService.clearBrushData(_image);
      }
      state = state.copyWith(brushStrokes: []);
    }
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

