import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/sketch_converter_service.dart';
import '../coloring/png_coloring_state.dart';

enum PhotoSketchStep {
  select,
  adjust,
  color,
}

class PhotoSketchState {
  final PhotoSketchStep step;
  final Uint8List? originalBytes;
  final Uint8List? sketchBytes;
  final bool isProcessing;
  final double detailLevel;
  final double contrast;
  final SketchStyle style;

  // Coloring State
  final ColoringMode mode;
  final Color selectedColor;
  final double brushSize;
  final bool canUndo;
  final bool canRedo;

  PhotoSketchState({
    this.step = PhotoSketchStep.select,
    this.originalBytes,
    this.sketchBytes,
    this.isProcessing = false,
    this.detailLevel = 0.2,
    this.contrast = 0.5,
    this.style = SketchStyle.pureOutline,
    this.mode = ColoringMode.fill,
    Color? selectedColor,
    this.brushSize = 12.0,
    this.canUndo = false,
    this.canRedo = false,
  }) : selectedColor = selectedColor ?? Color(AppConstants.defaultColors[0]);

  PhotoSketchState copyWith({
    PhotoSketchStep? step,
    Uint8List? originalBytes,
    Uint8List? sketchBytes,
    bool? isProcessing,
    double? detailLevel,
    double? contrast,
    SketchStyle? style,
    ColoringMode? mode,
    Color? selectedColor,
    double? brushSize,
    bool? canUndo,
    bool? canRedo,
  }) {
    return PhotoSketchState(
      step: step ?? this.step,
      originalBytes: originalBytes ?? this.originalBytes,
      sketchBytes: sketchBytes ?? this.sketchBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      detailLevel: detailLevel ?? this.detailLevel,
      contrast: contrast ?? this.contrast,
      style: style ?? this.style,
      mode: mode ?? this.mode,
      selectedColor: selectedColor ?? this.selectedColor,
      brushSize: brushSize ?? this.brushSize,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
