import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/coloring_image_model.dart';
import '../../core/services/app_gallery_service.dart';
import '../gallery/gallery_screen.dart';
import 'widgets/pixel_coloring_canvas.dart';
import 'widgets/color_palette.dart';
import '../../core/constants/app_constants.dart';
import 'png_coloring_state.dart';

/// Fill mode coloring screen
class FillColoringScreen extends ConsumerStatefulWidget {
  final ColoringImageModel image;

  const FillColoringScreen({
    super.key,
    required this.image,
  });

  @override
  ConsumerState<FillColoringScreen> createState() => _FillColoringScreenState();
}

class _FillColoringScreenState extends ConsumerState<FillColoringScreen> {
  Color _selectedColor = Color(AppConstants.defaultColors[0]);
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveToAppGallery() async {
    setState(() => _isSaving = true);
    
    try {
      final RenderRepaintBoundary boundary = 
          _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to app gallery
      await AppGalleryService.saveToAppGallery(pngBytes, widget.image.id);

      // Refresh gallery provider
      ref.read(galleryImagesProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to gallery! Check Gallery tab to view.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.image.name} - Fill Mode',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveToAppGallery,
              tooltip: 'Save to Gallery',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: PixelColoringCanvas(
                imagePath: widget.image.svgPath,
                selectedColor: _selectedColor,
                mode: ColoringMode.fill,
                brushStrokes: const [],
                onLoading: (loading) {}, // Ignore loading callback
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ColorPalette(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),
          ),
        ],
      ),
    );
  }
}
