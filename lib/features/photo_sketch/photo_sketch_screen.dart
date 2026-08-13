import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/coloring_widgets.dart';
import '../../data/models/brush_stroke.dart';
import '../coloring/png_coloring_state.dart';
import '../coloring/widgets/color_palette.dart';
import '../../services/sketch_converter_service.dart';
import 'photo_sketch_controller.dart';
import 'photo_sketch_state.dart';

class PhotoSketchScreen extends ConsumerStatefulWidget {
  const PhotoSketchScreen({super.key});

  @override
  ConsumerState<PhotoSketchScreen> createState() => _PhotoSketchScreenState();
}

class _PhotoSketchScreenState extends ConsumerState<PhotoSketchScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey<ColorPaletteState> _paletteKey =
      GlobalKey<ColorPaletteState>();

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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (state.step) {
            PhotoSketchStep.select =>
              _buildSelectView(context, ref, state, controller),
            PhotoSketchStep.adjust =>
              _buildAdjustView(context, ref, state, controller),
            PhotoSketchStep.color =>
              _buildColoringView(context, ref, state, controller),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          Row(
            children: [
              if (Navigator.of(context).canPop())
                RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('photo_sketch'),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey[900],
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      ref.tr('photo_sketch_desc'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

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
              SizedBox(width: 14.w),
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

          SizedBox(height: 28.h),

          // Sample Photos Section
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 20.sp,
                color: const Color(0xFFFF6B6B),
              ),
              SizedBox(width: 8.w),
              Text(
                ref.tr('sample_photo'),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Sample images grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
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
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
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
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: GlassControlBar(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                      fontSize: 18.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),

        // Sketch Preview Container
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                          const CircularProgressIndicator(
                              color: Color(0xFFFF6B6B)),
                          SizedBox(height: 16.h),
                          Text(
                            ref.tr('processing_image'),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
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
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Style Selector Pills
              _buildStyleSelector(state, controller),
              SizedBox(height: 16.h),

              // Line Detail Slider
              _buildSliderRow(
                label: ref.tr('line_detail'),
                valueText: '${(state.detailLevel * 100).round()}%',
                value: state.detailLevel,
                activeColor: const Color(0xFFFF6B6B),
                onChanged: (val) {
                  controller.updateAdjustments(val, state.contrast);
                },
                onChangeEnd: (_) => controller.applyAdjustments(),
              ),

              SizedBox(height: 8.h),

              // Contrast Slider
              _buildSliderRow(
                label: ref.tr('line_contrast'),
                valueText: '${(state.contrast * 100).round()}%',
                value: state.contrast,
                activeColor: const Color(0xFF4ECDC4),
                onChanged: (val) {
                  controller.updateAdjustments(state.detailLevel, val);
                },
                onChangeEnd: (_) => controller.applyAdjustments(),
              ),

              SizedBox(height: 14.h),

              // Start Coloring Button
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () => controller.startColoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    ref.tr('start_coloring'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelector(
    PhotoSketchState state,
    PhotoSketchController controller,
  ) {
    final styles = [
      (SketchStyle.pureOutline, 'Gemini AI', Icons.auto_awesome_rounded),
      (SketchStyle.coloringOutline, 'Coloring', Icons.draw_rounded),
      (SketchStyle.cartoonVector, 'Cartoon', Icons.auto_fix_high_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: styles.map((item) {
          final isSelected = state.style == item.$1;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              onTap: () => controller.setStyle(item.$1),
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueGrey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueGrey.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$3,
                      size: 16.sp,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valueText,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: Colors.blueGrey[900],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                valueText,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
            activeTrackColor: activeColor,
            inactiveTrackColor: activeColor.withValues(alpha: 0.15),
            thumbColor: activeColor,
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
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
        // Floating Glass Top Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: GlassControlBar(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => controller.resetToSelect(),
                ),
                const Spacer(),

                // Mode toggle pill
                _buildModeToggle(state, controller, ref),

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
                          backgroundColor:
                              ok ? Colors.green : Colors.redAccent,
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
              child: InteractiveViewer(
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
                          controller.handleTapFill(dx.round(), dy.round());
                        }
                      },
                      onPanStart: (details) =>
                          controller.handlePanStart(details.localPosition),
                      onPanUpdate: (details) =>
                          controller.handlePanUpdate(details.localPosition),
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

        // Bottom Color Palette Component (Same as main coloring screens)
        ColorPalette(
          key: _paletteKey,
          selectedColor: state.selectedColor,
          onColorSelected: (color) => controller.setColor(color),
        ),
      ],
    );
  }

  Widget _buildModeToggle(
    PhotoSketchState state,
    PhotoSketchController controller,
    WidgetRef ref,
  ) {
    final modes = [
      (ColoringMode.fill, ref.tr('tap_to_fill'), Icons.format_paint_rounded),
      (ColoringMode.brush, ref.tr('freehand_brush'), Icons.brush_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((m) {
          final isSelected = state.mode == m.$1;
          return GestureDetector(
            onTap: () => controller.setMode(m.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    m.$3,
                    size: 15.sp,
                    color: isSelected ? Colors.blueGrey[900] : Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    m.$2,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color:
                          isSelected ? Colors.blueGrey[900] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
