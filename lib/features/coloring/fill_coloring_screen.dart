import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/coloring_image_model.dart';
import '../../core/services/app_gallery_service.dart';
import '../gallery/gallery_screen.dart';
import 'widgets/pixel_coloring_canvas.dart';
import 'widgets/color_palette.dart';
import 'png_coloring_state.dart';
import '../../core/localization/app_localizations.dart';
import 'package:ds_ads/ds_ads.dart';
import '../../ads/ad_constants.dart';
import '../../ads/widgets/closable_native_ad.dart';

/// Fill mode coloring screen
class FillColoringScreen extends ConsumerStatefulWidget {
  final ColoringImageModel image;
  final File? savedImageFile;

  const FillColoringScreen({
    super.key,
    required this.image,
    this.savedImageFile,
  });

  @override
  ConsumerState<FillColoringScreen> createState() => _FillColoringScreenState();
}

class _FillColoringScreenState extends ConsumerState<FillColoringScreen> {
  Color _selectedColor = Color(AppConstants.defaultColors[0]);
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey<PixelColoringCanvasState> _canvasStateKey =
      GlobalKey<PixelColoringCanvasState>();
  bool _isSaving = false;
  bool _canUndo = false;
  bool _canRedo = false;
  final GlobalKey<ColorPaletteState> _paletteKey =
      GlobalKey<ColorPaletteState>();

  void _updateUndoRedoState() {
    final canvasState = _canvasStateKey.currentState;
    if (canvasState != null) {
      setState(() {
        _canUndo = canvasState.canUndo;
        _canRedo = canvasState.canRedo;
      });
    }
  }

  Future<void> _handleUndo() async {
    final canvasState = _canvasStateKey.currentState;
    if (canvasState != null) {
      await canvasState.undo();
      _updateUndoRedoState();
    }
  }

  Future<void> _handleRedo() async {
    final canvasState = _canvasStateKey.currentState;
    if (canvasState != null) {
      await canvasState.redo();
      _updateUndoRedoState();
    }
  }

  Future<void> _saveToAppGallery() async {
    setState(() => _isSaving = true);

    try {
      final RenderRepaintBoundary boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to app gallery
      await AppGalleryService.saveToAppGallery(
        pngBytes,
        widget.image.id,
        overwritePath: widget.savedImageFile?.path,
      );

      // Refresh gallery provider
      ref.read(galleryImagesProvider.notifier).refresh();

      if (mounted) {
        // Clear image cache to force reload of the overwritten file
        if (widget.savedImageFile != null) {
          final imageProvider = FileImage(widget.savedImageFile!);
          imageProvider.evict();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.tr('saved_to_gallery')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        if (mounted) {
          DSAdInterstitial.show(
            id: AppAdIds.interstitialSave,
            onAdClosed: () {
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ref.tr('error')}: $e'),
            backgroundColor: Colors.red,
          ),
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
          '${widget.image.name}',
          // '${widget.image.name} - ${ref.tr('tap_to_fill')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _canUndo ? _handleUndo : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _canRedo ? _handleRedo : null,
            tooltip: 'Redo',
          ),
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
              tooltip: ref.tr('save'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: PixelColoringCanvas(
                    key: _canvasStateKey,
                    imagePath: widget.image.svgPath,
                    initialImageFile: widget.savedImageFile,
                    selectedColor: _selectedColor,
                    mode: ColoringMode.fill,
                    brushStrokes: const [],
                    onLoading: (loading) {
                      if (!loading) {
                        // Update undo/redo state after image loads
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          _updateUndoRedoState,
                        );
                      }
                    },
                    onFillComplete: () {
                      _updateUndoRedoState();
                      // Add selected color to recent colors when a fill is completed
                      final paletteState = _paletteKey.currentState;
                      if (paletteState != null) {
                        paletteState.addColorToHistory(_selectedColor);
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ColorPalette(
                  key: _paletteKey,
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() => _selectedColor = color);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClosableNativeAd(
              adId: AppAdIds.nativeColoring,
              height: 265.h,
            ),
          ),
        ],
      ),
    );
  }
}
