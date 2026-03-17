import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/coloring_image_model.dart';
import '../../core/widgets/coloring_widgets.dart';
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
    if (_canvasStateKey.currentContext == null) return;
    setState(() => _isSaving = true);

    try {
      final canvasState = _canvasStateKey.currentState;
      if (canvasState == null) {
        throw Exception('Canvas state is not ready');
      }

      final Uint8List? pngBytes = await canvasState.exportImageBytes();

      if (pngBytes == null) {
        throw Exception('Failed to export image bytes');
      }

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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
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
              top: 8,
              left: 12,
              right: 12,
              child: GlassControlBar(
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.undo_rounded,
                      onTap: _canUndo ? _handleUndo : null,
                      enabled: _canUndo,
                    ),
                    const SizedBox(width: 8),
                    RoundIconButton(
                      icon: Icons.redo_rounded,
                      onTap: _canRedo ? _handleRedo : null,
                      enabled: _canRedo,
                    ),
                    const SizedBox(width: 8),
                    if (_isSaving)
                      const _Loader()
                    else
                      RoundIconButton(
                        icon: Icons.save_alt_rounded,
                        onTap: _saveToAppGallery,
                        isPrimary: true,
                      ),
                  ],
                ),
              ),
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
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
