import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_utils.dart';
import '../../services/gemini_sketch_service.dart';
import '../../services/sketch_converter_service.dart';
import '../coloring/engine/brush_engine.dart';
import '../coloring/engine/flood_fill_engine.dart';
import '../coloring/engine/undo_redo_manager.dart';
import '../coloring/png_coloring_state.dart';
import 'photo_sketch_state.dart';

class PhotoSketchController extends StateNotifier<PhotoSketchState> {
  final ImagePicker _picker = ImagePicker();
  final FloodFillEngine floodFillEngine = FloodFillEngine();
  final BrushEngine brushEngine = BrushEngine();
  final UndoRedoManager _undoManager = UndoRedoManager(maxSteps: AppConstants.maxUndoRedoSteps);

  PhotoSketchController() : super(PhotoSketchState());

  /// Pick photo from Camera or Gallery
  Future<void> pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();
      await setImageBytes(bytes);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Use a sample photo from app assets
  Future<void> useSamplePhoto(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      await setImageBytes(bytes);
    } catch (e) {
      debugPrint('Error loading sample photo: $e');
    }
  }

  /// Set original image bytes and generate initial sketch preview
  Future<void> setImageBytes(Uint8List bytes) async {
    state = state.copyWith(
      originalBytes: bytes,
      isProcessing: true,
      step: PhotoSketchStep.adjust,
    );

    await _generateSketch();
  }

  /// Update adjustment parameters (detail & contrast)
  void updateAdjustments(double detail, double contrast) {
    state = state.copyWith(detailLevel: detail, contrast: contrast);
  }

  /// Change sketch filter style
  void setStyle(SketchStyle style) {
    if (state.style != style) {
      state = state.copyWith(style: style, isProcessing: true);
      _generateSketch();
    }
  }

  /// Trigger sketch re-generation after sliders change
  Future<void> applyAdjustments() async {
    if (state.originalBytes == null) return;
    state = state.copyWith(isProcessing: true);
    await _generateSketch();
  }

  Future<void> _generateSketch() async {
    if (state.originalBytes == null) return;

    final Uint8List? sketch = await GeminiSketchService.convertToSketchWithGemini(
      state.originalBytes!,
      detailLevel: state.detailLevel,
      contrast: state.contrast,
      style: state.style,
    );

    state = state.copyWith(
      sketchBytes: sketch,
      isProcessing: false,
    );
  }

  /// Transition to coloring step and load sketch into FloodFillEngine
  Future<void> startColoring() async {
    if (state.sketchBytes == null) return;

    state = state.copyWith(isProcessing: true);

    // Save temporary sketch file to load into FloodFillEngine
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/sketch_temp_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(state.sketchBytes!);

    await floodFillEngine.loadFromFile(tempFile);

    state = state.copyWith(
      step: PhotoSketchStep.color,
      isProcessing: false,
      canUndo: floodFillEngine.canUndo,
      canRedo: floodFillEngine.canRedo,
    );
  }

  /// Set coloring mode (Tap to fill vs Brush)
  void setMode(ColoringMode mode) {
    if (state.mode != mode) {
      if (state.mode == ColoringMode.brush) {
        brushEngine.endStroke();
      }
      state = state.copyWith(mode: mode);
    }
  }

  /// Set active color
  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  /// Set brush size
  void setBrushSize(double size) {
    state = state.copyWith(
      brushSize: size.clamp(AppConstants.minBrushSize, AppConstants.maxBrushSize),
    );
  }

  /// Handle tap to fill at (x, y) coordinates on canvas
  Future<void> handleTapFill(int x, int y) async {
    if (state.mode != ColoringMode.fill || !floodFillEngine.isReady) return;

    final resultImage = await floodFillEngine.floodFill(x, y, state.selectedColor);
    if (resultImage != null) {
      HapticFeedback.lightImpact();
      state = state.copyWith(
        canUndo: floodFillEngine.canUndo,
        canRedo: floodFillEngine.canRedo,
      );
    }
  }

  /// Handle brush pan start
  void handlePanStart(Offset point) {
    if (state.mode != ColoringMode.brush) return;

    brushEngine.startStroke(
      point,
      state.selectedColor,
      state.brushSize,
      1.0,
    );
    HapticFeedback.selectionClick();
  }

  /// Handle brush pan update
  void handlePanUpdate(Offset point) {
    if (state.mode != ColoringMode.brush) return;

    brushEngine.addPointToStroke(point);
    state = state.copyWith(canUndo: true);
  }

  /// Handle brush pan end
  void handlePanEnd() {
    if (state.mode != ColoringMode.brush) return;

    brushEngine.endStroke();
    final strokes = brushEngine.getStrokes();
    if (strokes.isNotEmpty) {
      _undoManager.addBrushAction(strokes.last);
    }

    state = state.copyWith(
      canUndo: floodFillEngine.canUndo || _undoManager.canUndo(),
      canRedo: floodFillEngine.canRedo || _undoManager.canRedo(),
    );
  }

  /// Undo last fill or brush action
  Future<void> undo() async {
    if (state.mode == ColoringMode.fill) {
      await floodFillEngine.undo();
      state = state.copyWith(
        canUndo: floodFillEngine.canUndo,
        canRedo: floodFillEngine.canRedo,
      );
    } else {
      final action = _undoManager.undo();
      if (action != null && action.type == ActionType.brushStroke) {
        brushEngine.removeLastStroke();
        state = state.copyWith(
          canUndo: _undoManager.canUndo(),
          canRedo: _undoManager.canRedo(),
        );
      }
    }
  }

  /// Redo last undone action
  Future<void> redo() async {
    if (state.mode == ColoringMode.fill) {
      await floodFillEngine.redo();
      state = state.copyWith(
        canUndo: floodFillEngine.canUndo,
        canRedo: floodFillEngine.canRedo,
      );
    } else {
      final action = _undoManager.redo();
      if (action != null && action.type == ActionType.brushStroke && action.brushStroke != null) {
        brushEngine.addStroke(action.brushStroke!);
        state = state.copyWith(
          canUndo: _undoManager.canUndo(),
          canRedo: _undoManager.canRedo(),
        );
      }
    }
  }

  /// Clear all strokes / reset canvas
  void clearAll() {
    brushEngine.clearAllStrokes();
    floodFillEngine.clearHistory();
    state = state.copyWith(
      canUndo: false,
      canRedo: false,
    );
  }

  /// Save completed artwork to local storage & GalleryRepository
  Future<bool> saveArtwork() async {
    try {
      if (state.sketchBytes == null) return false;
      final String fileName = 'sketch_${const Uuid().v4()}.png';
      await StorageUtils.saveToGallery(fileName, state.sketchBytes!);
      await StorageUtils.incrementSaveCount();
      return true;
    } catch (e) {
      debugPrint('Error saving artwork: $e');
      return false;
    }
  }

  /// Go back to select step
  void resetToSelect() {
    brushEngine.clearAllStrokes();
    floodFillEngine.clearHistory();
    state = PhotoSketchState();
  }
}

final photoSketchControllerProvider = StateNotifierProvider<PhotoSketchController, PhotoSketchState>(
  (ref) => PhotoSketchController(),
);
