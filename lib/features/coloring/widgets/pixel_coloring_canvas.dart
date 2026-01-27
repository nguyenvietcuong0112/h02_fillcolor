
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/flood_fill_engine.dart';
import '../png_coloring_state.dart';
import '../../../data/models/brush_stroke.dart';

class PixelColoringCanvas extends StatefulWidget {
  final String imagePath;
  final Color selectedColor;
  final ColoringMode mode;
  final List<BrushStroke> brushStrokes;
  final Function(Offset)? onPanStart;
  final Function(Offset)? onPanUpdate;
  final Function()? onPanEnd;
  final Function(Offset)? onTapForRegion; // For brush mode region selection
  final Function(bool)? onLoading;
  final Function()? onFillComplete; // Called after a fill operation completes

  const PixelColoringCanvas({
    super.key,
    required this.imagePath,
    required this.selectedColor,
    required this.mode,
    this.brushStrokes = const [],
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onTapForRegion,
    this.onLoading,
    this.onFillComplete,
  });

  @override
  State<PixelColoringCanvas> createState() => PixelColoringCanvasState();
}

class PixelColoringCanvasState extends State<PixelColoringCanvas> {
  final FloodFillEngine _engine = FloodFillEngine();
  final TransformationController _transformationController = TransformationController();
  bool _isLoading = true;
  ui.Image? _displayImage;
  bool _isDrawing = false; // Track if currently drawing
  bool _engineReady = false; // Track if engine is ready

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // Public methods to access engine functionality
  bool get canUndo => _engine.canUndo;
  bool get canRedo => _engine.canRedo;

  Future<void> undo() async {
    if (_engine.canUndo) {
      final newImage = await _engine.undo();
      if (newImage != null) {
        setState(() {
          _displayImage = newImage;
        });
      }
    }
  }

  Future<void> redo() async {
    if (_engine.canRedo) {
      final newImage = await _engine.redo();
      if (newImage != null) {
        setState(() {
          _displayImage = newImage;
        });
      }
    }
  }

  Future<void> _loadImage() async {
    widget.onLoading?.call(true);
    try {
      // Load image for display
      await _engine.loadImage(widget.imagePath);
      if (mounted) {
        setState(() {
          _displayImage = _engine.image;
          _isLoading = false;
          _engineReady = true; // Mark engine as ready
        });
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    } finally {
      if (mounted) {
        widget.onLoading?.call(false);
      }
    }
  }

  void _handleTapOrPanStart(Offset globalPosition, BoxConstraints constraints) {
    if (_isLoading || _displayImage == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);

    // Apply inverse transformation
    final Matrix4 inverse = Matrix4.inverted(_transformationController.value);
    final Offset transformedPosition = MatrixUtils.transformPoint(inverse, localPosition);

    if (widget.mode == ColoringMode.fill) {
      _handleFillTap(transformedPosition, constraints);
    } else {
      // Brush mode - convert to image coordinates
      setState(() => _isDrawing = true); // Start drawing
      final imagePoint = _screenToImageCoords(transformedPosition, constraints);
      widget.onPanStart?.call(imagePoint);
    }
  }

  Offset _screenToImageCoords(Offset screenPoint, BoxConstraints constraints) {
    final double widgetWidth = constraints.maxWidth;
    final double widgetHeight = constraints.maxHeight;
    final double imageWidth = _displayImage!.width.toDouble();
    final double imageHeight = _displayImage!.height.toDouble();

    final double scaleX = widgetWidth / imageWidth;
    final double scaleY = widgetHeight / imageHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double displayedWidth = imageWidth * scale;
    final double displayedHeight = imageHeight * scale;

    final double dx = (widgetWidth - displayedWidth) / 2;
    final double dy = (widgetHeight - displayedHeight) / 2;

    final double imgX = (screenPoint.dx - dx) / scale;
    final double imgY = (screenPoint.dy - dy) / scale;

    return Offset(imgX, imgY);
  }

  void _handleTapDown(Offset globalPosition, BoxConstraints constraints) {
    if (_isLoading || _displayImage == null) return;
    if (widget.mode != ColoringMode.brush) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final Matrix4 inverse = Matrix4.inverted(_transformationController.value);
    final Offset transformedPosition = MatrixUtils.transformPoint(inverse, localPosition);

    // Convert to image coordinates for region selection
    final double widgetWidth = constraints.maxWidth;
    final double widgetHeight = constraints.maxHeight;
    final double imageWidth = _displayImage!.width.toDouble();
    final double imageHeight = _displayImage!.height.toDouble();

    final double scaleX = widgetWidth / imageWidth;
    final double scaleY = widgetHeight / imageHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double displayedWidth = imageWidth * scale;
    final double displayedHeight = imageHeight * scale;

    final double dx = (widgetWidth - displayedWidth) / 2;
    final double dy = (widgetHeight - displayedHeight) / 2;

    final double imgX = (transformedPosition.dx - dx) / scale;
    final double imgY = (transformedPosition.dy - dy) / scale;

    final imagePoint = Offset(imgX, imgY);
    widget.onTapForRegion?.call(imagePoint);
  }

  void _handleFillTap(Offset transformedPosition, BoxConstraints constraints) {
    // Check if engine is ready
    if (!_engineReady || _displayImage == null) {
      debugPrint('Engine not ready yet, ignoring tap');
      return;
    }

    // Calculate scaling to map UI coordinates to Image coordinates
    final double widgetWidth = constraints.maxWidth;
    final double widgetHeight = constraints.maxHeight;
    final double imageWidth = _displayImage!.width.toDouble();
    final double imageHeight = _displayImage!.height.toDouble();

    final double scaleX = widgetWidth / imageWidth;
    final double scaleY = widgetHeight / imageHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double displayedWidth = imageWidth * scale;
    final double displayedHeight = imageHeight * scale;

    final double dx = (widgetWidth - displayedWidth) / 2;
    final double dy = (widgetHeight - displayedHeight) / 2;

    final double imgX = (transformedPosition.dx - dx) / scale;
    final double imgY = (transformedPosition.dy - dy) / scale;

    final int x = imgX.round();
    final int y = imgY.round();

    if (x < 0 || x >= _displayImage!.width || y < 0 || y >= _displayImage!.height) {
      return;
    }

    // Run flood fill synchronously - UI will lag briefly but won't hang
    _engine.floodFill(x, y, widget.selectedColor).then((newImage) {
      if (newImage != null && mounted) {
        setState(() {
          _displayImage = newImage;
        });
        HapticFeedback.lightImpact();
        // Notify parent that fill completed
        widget.onFillComplete?.call();
      }
    }).catchError((error) {
      debugPrint('Flood fill error: $error');
    });
  }

  void _handlePanUpdate(Offset globalPosition, BoxConstraints constraints) {
    if (widget.mode != ColoringMode.brush) return;
    if (!_isDrawing) return; // Only update if drawing
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final Matrix4 inverse = Matrix4.inverted(_transformationController.value);
    final Offset transformedPosition = MatrixUtils.transformPoint(inverse, localPosition);
    
    final imagePoint = _screenToImageCoords(transformedPosition, constraints);
    widget.onPanUpdate?.call(imagePoint);
  }

  void _handlePanEnd() {
    if (_isDrawing) {
      setState(() => _isDrawing = false); // Stop drawing
      widget.onPanEnd?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isLoading || _displayImage == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // For brush mode, use simple GestureDetector without InteractiveViewer
        if (widget.mode == ColoringMode.brush) {
          return GestureDetector(
            onTapDown: (details) {
              // Tap to select region
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              final imagePoint = _screenToImageCoords(localPosition, constraints);
              debugPrint('Tap for region selection at: $imagePoint');
              widget.onTapForRegion?.call(imagePoint);
            },
            onPanStart: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              final imagePoint = _screenToImageCoords(localPosition, constraints);
              debugPrint('Brush start at: $imagePoint');
              debugPrint('Calling widget.onPanStart: ${widget.onPanStart != null}');
              widget.onPanStart?.call(imagePoint);
            },
            onPanUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              final imagePoint = _screenToImageCoords(localPosition, constraints);
              debugPrint('Brush update at: $imagePoint');
              debugPrint('Calling widget.onPanUpdate: ${widget.onPanUpdate != null}');
              widget.onPanUpdate?.call(imagePoint);
            },
            onPanEnd: (_) {
              debugPrint('Brush end');
              debugPrint('Calling widget.onPanEnd: ${widget.onPanEnd != null}');
              widget.onPanEnd?.call();
            },
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CombinedPainter(
                image: _displayImage!,
                brushStrokes: widget.brushStrokes,
              ),
            ),
          );
        }

        // For fill mode, use InteractiveViewer with zoom/pan
        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: GestureDetector(
            onTapDown: (details) {
              _handleTapOrPanStart(details.globalPosition, constraints);
            },
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CombinedPainter(
                image: _displayImage!,
                brushStrokes: widget.brushStrokes,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CombinedPainter extends CustomPainter {
  final ui.Image image;
  final List<BrushStroke> brushStrokes;

  _CombinedPainter({
    required this.image,
    required this.brushStrokes,
  }) {
    debugPrint('Painter created with ${brushStrokes.length} strokes');
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the filled image
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double displayedWidth = image.width * scale;
    final double displayedHeight = image.height * scale;
    
    final double dx = (size.width - displayedWidth) / 2;
    final double dy = (size.height - displayedHeight) / 2;

    final Rect srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect dstRect = Rect.fromLTWH(dx, dy, displayedWidth, displayedHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    // Draw brush strokes on top
    for (final stroke in brushStrokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.size * scale // Scale brush size too
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      
      // Convert first point from image coords to screen coords
      final firstScreenPoint = Offset(
        stroke.points.first.dx * scale + dx,
        stroke.points.first.dy * scale + dy,
      );
      path.moveTo(firstScreenPoint.dx, firstScreenPoint.dy);
      
      // Convert remaining points
      for (int i = 1; i < stroke.points.length; i++) {
        final screenPoint = Offset(
          stroke.points[i].dx * scale + dx,
          stroke.points[i].dy * scale + dy,
        );
        path.lineTo(screenPoint.dx, screenPoint.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CombinedPainter oldDelegate) {
    return image != oldDelegate.image || brushStrokes != oldDelegate.brushStrokes;
  }
}
