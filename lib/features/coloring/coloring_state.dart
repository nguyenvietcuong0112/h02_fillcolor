import 'package:flutter/material.dart';
import '../../data/models/coloring_image_model.dart';
import '../../data/models/svg_path_data.dart';
import '../../data/models/brush_stroke.dart';

/// Coloring mode enum
enum ColoringMode {
  fill,
  brush,
}

/// State for coloring screen
class ColoringState {
  final ColoringImageModel image;
  final ColoringMode mode;
  final Color selectedColor;
  final double brushSize;
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;
  final bool canUndo;
  final bool canRedo;
  final bool isLoading;
  final String? error;

  const ColoringState({
    required this.image,
    required this.mode,
    required this.selectedColor,
    required this.brushSize,
    required this.svgPaths,
    required this.filledPaths,
    required this.brushStrokes,
    this.canUndo = false,
    this.canRedo = false,
    this.isLoading = false,
    this.error,
  });

  ColoringState copyWith({
    ColoringImageModel? image,
    ColoringMode? mode,
    Color? selectedColor,
    double? brushSize,
    List<SvgPathData>? svgPaths,
    Map<String, Color>? filledPaths,
    List<BrushStroke>? brushStrokes,
    bool? canUndo,
    bool? canRedo,
    bool? isLoading,
    String? error,
  }) {
    return ColoringState(
      image: image ?? this.image,
      mode: mode ?? this.mode,
      selectedColor: selectedColor ?? this.selectedColor,
      brushSize: brushSize ?? this.brushSize,
      svgPaths: svgPaths ?? this.svgPaths,
      filledPaths: filledPaths ?? this.filledPaths,
      brushStrokes: brushStrokes ?? this.brushStrokes,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

