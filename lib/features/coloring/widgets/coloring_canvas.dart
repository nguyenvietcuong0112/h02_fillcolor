import 'package:flutter/material.dart';
import '../../../data/models/svg_path_data.dart';
import '../../../data/models/brush_stroke.dart';

/// Custom painter for coloring canvas
class ColoringPainter extends CustomPainter {
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;
  final double scale;
  final Offset offset;

  ColoringPainter({
    required this.svgPaths,
    required this.filledPaths,
    required this.brushStrokes,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // Layer 1: Draw filled paths (fill layer)
    for (final pathData in svgPaths) {
      final fillColor = filledPaths[pathData.id];
      if (fillColor != null) {
        final paint = Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(pathData.path, paint);
      }
    }

    // Layer 2: Draw path outlines (static outline layer - could be cached)
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / scale;
    
    for (final pathData in svgPaths) {
      canvas.drawPath(pathData.path, outlinePaint);
    }

    // Layer 3: Draw brush strokes (dynamic brush layer), clipped per region
    for (final stroke in brushStrokes) {
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.size / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = stroke.toPath();

      if (stroke.pathId != null) {
        // Find the corresponding SVG path and clip to it
        final region = svgPaths.firstWhere(
          (p) => p.id == stroke.pathId,
          orElse: () => SvgPathData(
            id: '',
            path: Path(),
            bounds: Rect.zero,
          ),
        );
        if (region.id.isNotEmpty) {
          canvas.save();
          // Clip so that brush never goes outside region boundary
          canvas.clipPath(region.path);
          canvas.drawPath(path, paint);
          canvas.restore();
          continue;
        }
      }

      // Fallback: draw normally if no region attached
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ColoringPainter oldDelegate) {
    return oldDelegate.svgPaths != svgPaths ||
        oldDelegate.filledPaths != filledPaths ||
        oldDelegate.brushStrokes != brushStrokes ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}

/// Canvas widget for coloring
class ColoringCanvas extends StatefulWidget {
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;
  final bool isBrushMode; // Add mode flag
  final Function(Offset) onTap;
  final Function(Offset) onPanStart;
  final Function(Offset) onPanUpdate;
  final Function() onPanEnd;
  final GlobalKey repaintBoundaryKey;

  const ColoringCanvas({
    super.key,
    required this.svgPaths,
    required this.filledPaths,
    required this.brushStrokes,
    required this.isBrushMode,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.repaintBoundaryKey,
  });

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastPanOffset = Offset.zero;
  double _lastScale = 1.0;
  bool _isPanning = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final localPoint = _globalToLocal(details.globalPosition);
        widget.onTap(localPoint);
      },
      onScaleStart: (details) {
        _lastPanOffset = details.focalPoint;
        _lastScale = _scale;
        _isPanning = false;
        
        if (details.pointerCount == 1) {
          if (widget.isBrushMode) {
            // Brush mode: start drawing, DON'T move canvas
            _isPanning = true;
            final localPoint = _globalToLocal(details.focalPoint);
            widget.onPanStart(localPoint);
          } else {
            // Fill mode: prepare for potential pan (but don't start yet)
            _isPanning = false;
          }
        } else {
          // Multiple fingers: prepare for zoom/pan
          _isPanning = false;
        }
      },
      onScaleUpdate: (details) {
        if (details.pointerCount == 1) {
          if (widget.isBrushMode && _isPanning) {
            // Brush mode: draw brush stroke, DON'T move canvas
            final localPoint = _globalToLocal(details.focalPoint);
            widget.onPanUpdate(localPoint);
            // Don't update _offset here - keep canvas still
          } else if (!widget.isBrushMode) {
            // Fill mode: allow panning canvas with single finger
            final delta = details.focalPoint - _lastPanOffset;
            _offset += delta;
            _lastPanOffset = details.focalPoint;
            setState(() {});
          }
        } else if (details.pointerCount >= 2) {
          // Multiple fingers: zoom and pan (works in both modes)
          _isPanning = false;
          _scale = (_lastScale * details.scale).clamp(0.5, 3.0);
          final delta = details.focalPoint - _lastPanOffset;
          _offset += delta;
          _lastPanOffset = details.focalPoint;
          setState(() {});
        }
      },
      onScaleEnd: (details) {
        // Handle pan end for brush mode
        if (_isPanning) {
          widget.onPanEnd();
        }
        _isPanning = false;
      },
      child: RepaintBoundary(
        key: widget.repaintBoundaryKey,
        child: CustomPaint(
          painter: ColoringPainter(
            svgPaths: widget.svgPaths,
            filledPaths: widget.filledPaths,
            brushStrokes: widget.brushStrokes,
            scale: _scale,
            offset: _offset,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  Offset _globalToLocal(Offset global) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    final local = renderBox.globalToLocal(global);
    return Offset(
      (local.dx - _offset.dx) / _scale,
      (local.dy - _offset.dy) / _scale,
    );
  }
}

