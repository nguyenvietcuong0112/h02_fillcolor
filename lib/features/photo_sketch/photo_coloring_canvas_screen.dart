import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/coloring_widgets.dart';
import '../../core/widgets/save_success_dialog.dart';
import '../../data/models/brush_stroke.dart';
import '../../services/firebase_remote_config_service.dart';
import '../coloring/png_coloring_state.dart';
import '../coloring/widgets/color_palette.dart';
import '../gallery/gallery_screen.dart';
import 'photo_sketch_controller.dart';
import 'photo_sketch_state.dart';

/// Standalone full screen for coloring picked photo
class PhotoColoringCanvasScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const PhotoColoringCanvasScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  ConsumerState<PhotoColoringCanvasScreen> createState() =>
      _PhotoColoringCanvasScreenState();
}

class _PhotoColoringCanvasScreenState
    extends ConsumerState<PhotoColoringCanvasScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey<ColorPaletteState> _paletteKey =
      GlobalKey<ColorPaletteState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(photoSketchControllerProvider.notifier)
          .setImageBytes(widget.imageBytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoSketchControllerProvider);
    final controller = ref.read(photoSketchControllerProvider.notifier);
    final ui.Image? displayImage = controller.floodFillEngine.image;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top Control Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: GlassControlBar(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        controller.resetToSelect();
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),

                    // Undo
                    RoundIconButton(
                      icon: Icons.undo_rounded,
                      enabled: state.canUndo,
                      onTap: () => controller.undo(),
                    ),
                    SizedBox(width: 6.w),

                    // Redo
                    RoundIconButton(
                      icon: Icons.redo_rounded,
                      enabled: state.canRedo,
                      onTap: () => controller.redo(),
                    ),
                    SizedBox(width: 6.w),

                    // Save
                    RoundIconButton(
                      icon: Icons.save_alt_rounded,
                      isPrimary: true,
                      onTap: () async {
                        // 1. Save artwork to App Gallery
                        final ok = await controller.saveArtwork();

                        if (!context.mounted) return;

                        if (ok) {
                          // 2. Refresh gallery provider so Gallery tab updates immediately
                          ref.read(galleryImagesProvider.notifier).refresh();

                          // 3. Show shared SaveSuccessDialog popup
                          if (context.mounted) {
                            SaveSuccessDialog.show(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Full width Mode Toggle bar right under header (matching header 14.w padding)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: _buildModeToggle(state, controller, ref),
            ),

            // Interactive Canvas Container
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: state.isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF6B6B),
                          ),
                        )
                      : InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTapUp: (details) {
                                  if (state.mode == ColoringMode.fill &&
                                      displayImage != null) {
                                    final dx = (details.localPosition.dx /
                                            constraints.maxWidth) *
                                        displayImage.width;
                                    final dy = (details.localPosition.dy /
                                            constraints.maxHeight) *
                                        displayImage.height;
                                    controller.handleTapFill(
                                        dx.round(), dy.round());
                                  }
                                },
                                onPanStart: (details) => controller
                                    .handlePanStart(details.localPosition),
                                onPanUpdate: (details) => controller
                                    .handlePanUpdate(details.localPosition),
                                onPanEnd: (_) => controller.handlePanEnd(),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (displayImage != null)
                                      RawImage(
                                        image: displayImage,
                                        fit: BoxFit.contain,
                                      ),
                                    CustomPaint(
                                      painter: BrushPainter(
                                        strokes: controller.brushEngine.getStrokes(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),

            // Bottom Palette
            ColorPalette(
              key: _paletteKey,
              selectedColor: state.selectedColor,
              onColorSelected: (color) => controller.setColor(color),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAd(),
    );
  }

  Widget? _buildBottomAd() {
    final isEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_sketch,
    );
    if (EasyAds.instance.isPremiumUser || !isEnabled) {
      return null;
    }
    return SafeArea(
      child: EasyNativeAd(
        factoryId: NativeFactoryId.nativeBanner,
        adId: MyAdIdName.nativeAll.getId,
        adIdName: MyAdIdName.nativeAll,
        height: AdDimen.nativeBannerHeight,
      ),
    );
  }

  Widget _buildModeToggle(
    PhotoSketchState state,
    PhotoSketchController controller,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              icon: Icons.format_color_fill_rounded,
              label: ref.tr('fill_mode'),
              isSelected: state.mode == ColoringMode.fill,
              onTap: () => controller.setMode(ColoringMode.fill),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _buildToggleItem(
              icon: Icons.brush_rounded,
              label: ref.tr('brush_mode'),
              isSelected: state.mode == ColoringMode.brush,
              onTap: () => controller.setMode(ColoringMode.brush),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrushPainter extends CustomPainter {
  final List<BrushStroke> strokes;

  BrushPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.size / 2, paint);
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BrushPainter oldDelegate) => true;
}
