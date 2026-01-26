import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/utils/storage_utils.dart';
import '../../services/ads_service.dart';
import '../../services/analytics_service.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'coloring_state.dart';
import 'coloring_controller.dart';
import 'widgets/coloring_canvas.dart';
import 'widgets/color_palette.dart';
import 'widgets/brush_toolbar.dart';
import '../gallery/gallery_screen.dart'; // For galleryControllerProvider

/// Coloring screen
class ColoringScreen extends ConsumerStatefulWidget {
  final dynamic image;
  final ColoringMode mode; // Mode được chọn từ màn selection

  const ColoringScreen({
    super.key,
    required this.image,
    required this.mode,
  });

  @override
  ConsumerState<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends ConsumerState<ColoringScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set mode và load data tương ứng khi screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(coloringControllerProvider(widget.image).notifier);
      // Set mode (sẽ tự động load data của mode đó)
      controller.setMode(widget.mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coloringControllerProvider(widget.image));

    return Scaffold(
      backgroundColor: Colors.white, // Force white background for coloring canvas
      appBar: AppBar(
        title: Text(
          widget.image.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.undo,
              color: state.canUndo ? null : Colors.grey[400],
            ),
            tooltip: 'Undo',
            onPressed: state.canUndo
                ? () => ref.read(coloringControllerProvider(widget.image).notifier).undo()
                : null,
          ),
          IconButton(
            icon: Icon(
              Icons.redo,
              color: state.canRedo ? null : Colors.grey[400],
            ),
            tooltip: 'Redo',
            onPressed: state.canRedo
                ? () => ref.read(coloringControllerProvider(widget.image).notifier).redo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear All',
            onPressed: () => _showClearDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () => _saveArtwork(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareArtwork(),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? ErrorDisplayWidget(message: state.error!)
              : Column(
                  children: [
                    // Mode indicator (chỉ hiển thị, không cho switch)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.mode == ColoringMode.fill 
                            ? Colors.blue[50] 
                            : Colors.purple[50],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.mode == ColoringMode.fill 
                                ? Icons.format_color_fill 
                                : Icons.brush,
                            color: widget.mode == ColoringMode.fill 
                                ? Colors.blue 
                                : Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.mode == ColoringMode.fill ? 'Fill Mode' : 'Brush Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.mode == ColoringMode.fill 
                                  ? Colors.blue[700] 
                                  : Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Color palette
                    ColorPalette(
                      selectedColor: state.selectedColor,
                      onColorSelected: (color) => ref.read(coloringControllerProvider(widget.image).notifier).setColor(color),
                    ),
                    // Brush toolbar (only in brush mode)
                    if (widget.mode == ColoringMode.brush)
                      BrushToolbar(
                        brushSize: state.brushSize,
                        onBrushSizeChanged: (size) => ref.read(coloringControllerProvider(widget.image).notifier).setBrushSize(size),
                      ),
                    // Canvas
                    Expanded(
                      child: ColoringCanvas(
                        repaintBoundaryKey: _repaintBoundaryKey,
                        svgPaths: state.svgPaths,
                        filledPaths: state.filledPaths,
                        brushStrokes: state.brushStrokes,
                        isBrushMode: widget.mode == ColoringMode.brush,
                        onTap: (point) => ref.read(coloringControllerProvider(widget.image).notifier).handleTap(point),
                        onPanStart: (point) => ref.read(coloringControllerProvider(widget.image).notifier).handlePanStart(point),
                        onPanUpdate: (point) => ref.read(coloringControllerProvider(widget.image).notifier).handlePanUpdate(point),
                        onPanEnd: () => ref.read(coloringControllerProvider(widget.image).notifier).handlePanEnd(),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all coloring?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(coloringControllerProvider(widget.image).notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveArtwork() async {
    try {
      // Show interstitial ad occasionally
      await AdsService.instance.showInterstitialAd();

      // Render image
      final imageBytes = await _renderImage();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save artwork')),
          );
        }
        return;
      }

      // Save to gallery
      final fileName = '${widget.image.id}_${const Uuid().v4()}.png';
      final file = await StorageUtils.saveToGallery(fileName, imageBytes);

      // Increment save count
      await StorageUtils.incrementSaveCount();

      // Log analytics
      AnalyticsService.instance.logArtworkSaved();

      // Refresh Gallery so it shows up immediately
      // We need to import the provider from gallery_feature
      ref.read(galleryControllerProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork saved: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving artwork: $e')),
        );
      }
    }
  }

  Future<void> _shareArtwork() async {
    try {
      final imageBytes = await _renderImage();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to share artwork')),
          );
        }
        return;
      }

      // Save temporarily for sharing
      final tempDir = await StorageUtils.getGalleryDirectory();
      final tempFile = File('${tempDir.path}/temp_share.png');
      await tempFile.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(tempFile.path)], text: 'Check out my coloring!');

      AnalyticsService.instance.logArtworkShared();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing artwork: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _renderImage() async {
    try {
      final renderObject = _repaintBoundaryKey.currentContext?.findRenderObject();
      if (renderObject == null || !renderObject.attached) return null;

      final renderRepaintBoundary = renderObject as RenderRepaintBoundary;
      final image = await renderRepaintBoundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}



