import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/coloring_image_model.dart';
import '../../core/constants/app_constants.dart';
import 'png_coloring_state.dart';
import 'engine/brush_engine.dart';
import 'engine/undo_redo_manager.dart';
import 'engine/flood_fill_engine.dart';

/// Controller for PNG coloring with Fill and Brush modes
class PngColoringController extends StateNotifier<PngColoringState> {
  final ColoringImageModel _image;
  final BrushEngine _brushEngine = BrushEngine();
  final UndoRedoManager _undoRedoManager = UndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);
  final FloodFillEngine _regionEngine = FloodFillEngine();

  PngColoringController(this._image)
      : super(PngColoringState(
          selectedColor: Color(AppConstants.defaultColors[0]),
        )) {
    _loadSavedData();
  }

  /// Load saved brush data
  Future<void> _loadSavedData() async {
    // final savedStrokes = await ColoringStorageService.loadBrushData(_image); // Commented out
    // if (savedStrokes.isNotEmpty) {
    //   for (final stroke in savedStrokes) {
    //     _brushEngine.addStroke(stroke);
    //   }
    //   state = state.copyWith(brushStrokes: savedStrokes);
    // }
  }

  /// Select region for brush clipping
  Future<void> selectRegion(int x, int y) async {
    if (!_regionEngine.isReady) return;
    
    // Use flood fill to detect region
    final regionMask = await _regionEngine.getRegionMask(x, y);
    
    if (regionMask != null) {
      state = state.copyWith(
        activeRegionMask: regionMask,
        imageWidth: 800, // Default size
        imageHeight: 800,
      );
      HapticFeedback.mediumImpact();
    }
  }

  /// Check if point is inside active region
  bool _isPointInRegion(Offset point) {
    if (state.activeRegionMask == null) return true; // No region selected, allow all
    
    final x = point.dx.toInt();
    final y = point.dy.toInt();
    
    if (x < 0 || x >= state.imageWidth || y < 0 || y >= state.imageHeight) {
      return false;
    }
    
    final index = y * state.imageWidth + x;
    return state.activeRegionMask![index] == 1;
  }

  /// Set coloring mode
  void setMode(ColoringMode mode) {
    if (state.mode != mode) {
      // End current brush stroke if switching from brush mode
      if (state.mode == ColoringMode.brush) {
        _brushEngine.endStroke();
      }
      state = state.copyWith(mode: mode);
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

  /// Handle pan start for brush mode
  void handlePanStart(Offset point) {
    if (state.mode != ColoringMode.brush) return;

    // Temporarily allow drawing anywhere - remove region check
    debugPrint('Brush pan start: $point');
    
    _brushEngine.startStroke(
      point,
      state.selectedColor,
      state.brushSize,
      1.0,
    );
    HapticFeedback.selectionClick();
  }

  /// Handle pan update for brush mode
  void handlePanUpdate(Offset point) {
    if (state.mode != ColoringMode.brush) return;

    // Allow all points - remove region check
    debugPrint('Brush pan update: $point');
    _brushEngine.addPointToStroke(point);
    final strokes = _brushEngine.getStrokes();
    debugPrint('Total strokes: ${strokes.length}, Current stroke points: ${strokes.isNotEmpty ? strokes.last.points.length : 0}');
    state = state.copyWith(brushStrokes: strokes);
  }

  /// Handle pan end for brush mode
  void handlePanEnd() {
    if (state.mode != ColoringMode.brush) return;

    _brushEngine.endStroke();
    final strokes = _brushEngine.getStrokes();
    
    if (strokes.isNotEmpty) {
      _undoRedoManager.addBrushAction(strokes.last);
      // ColoringStorageService.saveBrushData(_image, strokes); // Removed
    }
    
    state = state.copyWith(
      brushStrokes: strokes,
      canUndo: _undoRedoManager.canUndo(),
      canRedo: _undoRedoManager.canRedo(),
    );
  }

  /// Undo last action
  void undo() {
    final action = _undoRedoManager.undo();
    if (action == null) return;

    if (action.type == ActionType.brushStroke) {
      _brushEngine.removeLastStroke();
      final strokes = _brushEngine.getStrokes();
      // ColoringStorageService.saveBrushData(_image, strokes); // Removed
      
      state = state.copyWith(
        brushStrokes: strokes,
        canUndo: _undoRedoManager.canUndo(),
        canRedo: _undoRedoManager.canRedo(),
      );
    }
  }

  /// Redo last undone action
  void redo() {
    final action = _undoRedoManager.redo();
    if (action == null) return;

    if (action.type == ActionType.brushStroke && action.brushStroke != null) {
      _brushEngine.addStroke(action.brushStroke!);
      final strokes = _brushEngine.getStrokes();
      // ColoringStorageService.saveBrushData(_image, strokes); // Removed
      
      state = state.copyWith(
        brushStrokes: strokes,
        canUndo: _undoRedoManager.canUndo(),
        canRedo: _undoRedoManager.canRedo(),
      );
    }
  }

  /// Clear all brush strokes
  void clearAll() {
    _brushEngine.clearAllStrokes();
    // ColoringStorageService.clearBrushData(_image); // Removed
    
    state = state.copyWith(
      brushStrokes: [],
      canUndo: false,
      canRedo: false,
    );
  }

  /// Load image for region detection
  Future<void> loadImageForRegionDetection(String imagePath) async {
    await _regionEngine.loadImage(imagePath);
    state = state.copyWith(
      imageWidth: 800, // Default size
      imageHeight: 800,
    );
  }
}

/// Provider for PNG coloring controller
final pngColoringControllerProvider = StateNotifierProvider.family<PngColoringController, PngColoringState, ColoringImageModel>(
  (ref, image) => PngColoringController(image),
);
