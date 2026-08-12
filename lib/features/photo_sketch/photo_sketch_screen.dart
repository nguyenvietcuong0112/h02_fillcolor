import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/coloring_widgets.dart';
import '../../data/models/brush_stroke.dart';
import '../coloring/png_coloring_state.dart';
import '../../services/sketch_converter_service.dart';
import 'photo_sketch_controller.dart';
import 'photo_sketch_state.dart';

class PhotoSketchScreen extends ConsumerStatefulWidget {
  const PhotoSketchScreen({super.key});

  @override
  ConsumerState<PhotoSketchScreen> createState() => _PhotoSketchScreenState();
}

class _PhotoSketchScreenState extends ConsumerState<PhotoSketchScreen> {
  final TransformationController _transformationController = TransformationController();

  final List<String> _sampleAssets = [
    'assets/images/animal_cat.png',
    'assets/images/flower_rose.png',
    'assets/images/landscape_beach.png',
    'assets/images/food_cupcake.png',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoSketchControllerProvider);
    final controller = ref.read(photoSketchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (state.step) {
            PhotoSketchStep.select => _buildSelectView(context, ref, state, controller),
            PhotoSketchStep.adjust => _buildAdjustView(context, ref, state, controller),
            PhotoSketchStep.color => _buildColoringView(context, ref, state, controller),
          },
        ),
      ),
    );
  }

  // --- 1. SELECT PHOTO VIEW ---
  Widget _buildSelectView(
    BuildContext context,
    WidgetRef ref,
    PhotoSketchState state,
    PhotoSketchController controller,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppDimens.space24, AppDimens.space16, AppDimens.space24, AppDimens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('photo_sketch'),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ref.tr('photo_sketch_desc'),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppDimens.space24),

          // Primary Actions: Camera & Gallery
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: ref.tr('take_photo'),
                  color: const Color(0xFFFF6B6B),
                  onTap: () => controller.pickPhoto(ImageSource.camera),
                ),
              ),
              SizedBox(width: AppDimens.space16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.photo_library_rounded,
                  title: ref.tr('choose_gallery'),
                  color: const Color(0xFF4ECDC4),
                  onTap: () => controller.pickPhoto(ImageSource.gallery),
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimens.space32),
          Text(
            ref.tr('sample_photo'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey[900],
            ),
          ),
          SizedBox(height: AppDimens.space16),

          // Sample images grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.space16,
              mainAxisSpacing: AppDimens.space16,
              childAspectRatio: 1.0,
            ),
            itemCount: _sampleAssets.length,
            itemBuilder: (context, index) {
              final asset = _sampleAssets[index];
              return InkWell(
                onTap: () => controller.useSamplePhoto(asset),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 130.h,
        padding: EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. ADJUST SKETCH PREVIEW VIEW ---
  Widget _buildAdjustView(
    BuildContext context,
    WidgetRef ref,
    PhotoSketchState state,
    PhotoSketchController controller,
  ) {
    return Column(
      children: [
        // App Bar matching ModeSelectionScreen
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space12),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => controller.resetToSelect(),
              ),
              Expanded(
                child: Text(
                  ref.tr('photo_sketch'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey[900],
                    fontWeight: FontWeight.w900,
                    fontSize: 20.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 44), // Symmetry balance for back button
            ],
          ),
        ),

        // Sketch Preview Container
        Expanded(
          child: Container(
            margin: EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Center(
                child: state.isProcessing
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                          SizedBox(height: 16.h),
                          Text(
                            ref.tr('processing_image'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                          ),
                        ],
                      )
                    : state.sketchBytes != null
                        ? Image.memory(
                            state.sketchBytes!,
                            fit: BoxFit.contain,
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // Sliders & Controls
        Container(
          padding: EdgeInsets.all(AppDimens.space24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Style Selector (Segmented / Cartoon / Ink / Pencil)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<SketchStyle>(
                  segments: [
                    ButtonSegment<SketchStyle>(
                      value: SketchStyle.pureOutline,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text('Gemini AI Outline', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey[900])),
                    ),
                    ButtonSegment<SketchStyle>(
                      value: SketchStyle.coloringOutline,
                      icon: const Icon(Icons.draw_rounded),
                      label: Text('Coloring Outline', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey[900])),
                    ),
                    ButtonSegment<SketchStyle>(
                      value: SketchStyle.cartoonVector,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: Text('Nét mượt Hoạt hình', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey[900])),
                    ),
                  ],
                  selected: {state.style},
                  onSelectionChanged: (Set<SketchStyle> selected) {
                    controller.setStyle(selected.first);
                  },
                ),
              ),
              SizedBox(height: AppDimens.space16),

              // Line Detail Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.tr('line_detail'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: Colors.blueGrey[900])),
                  Text('${(state.detailLevel * 100).round()}%', style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
                ],
              ),
              Slider(
                value: state.detailLevel,
                activeColor: const Color(0xFFFF6B6B),
                onChanged: (val) {
                  controller.updateAdjustments(val, state.contrast);
                },
                onChangeEnd: (_) => controller.applyAdjustments(),
              ),

              // Contrast Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.tr('line_contrast'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: Colors.blueGrey[900])),
                  Text('${(state.contrast * 100).round()}%', style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
                ],
              ),
              Slider(
                value: state.contrast,
                activeColor: const Color(0xFF4ECDC4),
                onChanged: (val) {
                  controller.updateAdjustments(state.detailLevel, val);
                },
                onChangeEnd: (_) => controller.applyAdjustments(),
              ),

              SizedBox(height: AppDimens.space12),

              // Start Coloring Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: state.isProcessing ? null : () => controller.startColoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    ref.tr('start_coloring'),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. COLORING CANVAS VIEW ---
  Widget _buildColoringView(
    BuildContext context,
    WidgetRef ref,
    PhotoSketchState state,
    PhotoSketchController controller,
  ) {
    final ui.Image? displayImage = controller.floodFillEngine.image;

    return Column(
      children: [
        // Top Toolbar with RoundIconButton
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space8,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => controller.resetToSelect(),
                ),

                SizedBox(width: AppDimens.space8),

                // Mode toggle
                SegmentedButton<ColoringMode>(
                  segments: [
                    ButtonSegment<ColoringMode>(
                      value: ColoringMode.fill,
                      icon: const Icon(Icons.format_paint_outlined),
                      label: Text(
                        ref.tr('tap_to_fill'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ),
                    ButtonSegment<ColoringMode>(
                      value: ColoringMode.brush,
                      icon: const Icon(Icons.brush_outlined),
                      label: Text(
                        ref.tr('freehand_brush'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ),
                  ],
                  selected: {state.mode},
                  onSelectionChanged: (Set<ColoringMode> selected) {
                    controller.setMode(selected.first);
                  },
                ),

                SizedBox(width: AppDimens.space16),

                // Undo
                RoundIconButton(
                  icon: Icons.undo_rounded,
                  enabled: state.canUndo,
                  onTap: () => controller.undo(),
                ),

                SizedBox(width: 8.w),

                // Redo
                RoundIconButton(
                  icon: Icons.redo_rounded,
                  enabled: state.canRedo,
                  onTap: () => controller.redo(),
                ),

                SizedBox(width: 8.w),

                // Save
                RoundIconButton(
                  icon: Icons.save_alt_rounded,
                  isPrimary: true,
                  onTap: () async {
                    final ok = await controller.saveArtwork();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? ref.tr('saved_to_gallery')
                                : ref.tr('save_failed'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        // Interactive Canvas Container
        Expanded(
          child: Container(
            margin: EdgeInsets.all(AppDimens.space12),
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
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.8,
                maxScale: 4.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapUp: (details) {
                        if (state.mode == ColoringMode.fill && displayImage != null) {
                          final dx = (details.localPosition.dx / constraints.maxWidth) * displayImage.width;
                          final dy = (details.localPosition.dy / constraints.maxHeight) * displayImage.height;
                          controller.handleTapFill(dx.round(), dy.round());
                        }
                      },
                      onPanStart: (details) => controller.handlePanStart(details.localPosition),
                      onPanUpdate: (details) => controller.handlePanUpdate(details.localPosition),
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
                            painter: _PhotoSketchBrushPainter(
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

        // Bottom Color Palette Bar
        Container(
          height: 76.h,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.defaultColors.length,
            itemBuilder: (context, index) {
              final colorValue = AppConstants.defaultColors[index];
              final color = Color(colorValue);
              final isSelected = state.selectedColor == color;

              return GestureDetector(
                onTap: () => controller.setColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isSelected ? 48.w : 40.w,
                  height: isSelected ? 48.w : 40.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.white,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PhotoSketchBrushPainter extends CustomPainter {
  final List<BrushStroke> strokes;

  _PhotoSketchBrushPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.isEraser ? Colors.transparent : stroke.color
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PhotoSketchBrushPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
