import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/coloring_image_model.dart';
import 'widgets/pixel_coloring_canvas.dart';
import 'widgets/color_palette.dart';
import '../../core/constants/app_constants.dart';
import 'png_coloring_controller.dart';
import 'png_coloring_state.dart';

class ColoringScreen extends ConsumerWidget {
  final ColoringImageModel image;

  const ColoringScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(pngColoringControllerProvider(image).notifier);
    final state = ref.watch(pngColoringControllerProvider(image));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          image.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Mode toggle
          IconButton(
            icon: Icon(state.mode == ColoringMode.fill ? Icons.format_paint : Icons.brush),
            onPressed: () {
              controller.setMode(
                state.mode == ColoringMode.fill ? ColoringMode.brush : ColoringMode.fill,
              );
            },
            tooltip: state.mode == ColoringMode.fill ? 'Switch to Brush' : 'Switch to Fill',
          ),
          // Undo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: state.canUndo ? () => controller.undo() : null,
          ),
          // Redo
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: state.canRedo ? () => controller.redo() : null,
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.clearAll(),
            tooltip: 'Clear All',
          ),
          // Save/Share
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement save/share
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Brush size slider (only show in brush mode)
          if (state.mode == ColoringMode.brush)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.brush, size: 16),
                  Expanded(
                    child: Slider(
                      value: state.brushSize,
                      min: AppConstants.minBrushSize,
                      max: AppConstants.maxBrushSize,
                      onChanged: (value) => controller.setBrushSize(value),
                    ),
                  ),
                  Text('${state.brushSize.toInt()}'),
                ],
              ),
            ),
          Expanded(
            child: PixelColoringCanvas(
              imagePath: image.svgPath,
              selectedColor: state.selectedColor,
              mode: state.mode,
              brushStrokes: state.brushStrokes,
              onPanStart: controller.handlePanStart,
              onPanUpdate: controller.handlePanUpdate,
              onPanEnd: controller.handlePanEnd,
              onLoading: (loading) {
                // Loading state handled by PixelColoringCanvas
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ColorPalette(
              selectedColor: state.selectedColor,
              onColorSelected: (color) => controller.setColor(color),
            ),
          ),
        ],
      ),
    );
  }
}
