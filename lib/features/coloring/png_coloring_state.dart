import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../data/models/brush_stroke.dart';

enum ColoringMode { fill, brush }

class PngColoringState {
  final ColoringMode mode;
  final Color selectedColor;
  final double brushSize;
  final List<BrushStroke> brushStrokes;
  final bool canUndo;
  final bool canRedo;
  final bool isLoading;
  final Uint8List? activeRegionMask; // Mask of pixels in active region for clipping
  final int imageWidth;
  final int imageHeight;

  const PngColoringState({
    this.mode = ColoringMode.fill,
    required this.selectedColor,
    this.brushSize = 10.0,
    this.brushStrokes = const [],
    this.canUndo = false,
    this.canRedo = false,
    this.isLoading = false,
    this.activeRegionMask,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  PngColoringState copyWith({
    ColoringMode? mode,
    Color? selectedColor,
    double? brushSize,
    List<BrushStroke>? brushStrokes,
    bool? canUndo,
    bool? canRedo,
    bool? isLoading,
    Uint8List? activeRegionMask,
    int? imageWidth,
    int? imageHeight,
  }) {
    return PngColoringState(
      mode: mode ?? this.mode,
      selectedColor: selectedColor ?? this.selectedColor,
      brushSize: brushSize ?? this.brushSize,
      brushStrokes: brushStrokes ?? this.brushStrokes,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      isLoading: isLoading ?? this.isLoading,
      activeRegionMask: activeRegionMask ?? this.activeRegionMask,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}
