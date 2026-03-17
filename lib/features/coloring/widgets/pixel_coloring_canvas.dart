import 'dart:async';
import 'dart:io';
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
  final Function(Offset, ui.Image?)? onPanStartWithMask;
  final Function(Offset)? onPanUpdate;
  final Function()? onPanEnd;
  final Function(Offset)? onTapForRegion;
  final Function(bool)? onLoading;
  final Function()? onFillComplete;
  final bool isMoveMode;
  final bool isLockRegionMode;
  final bool isEraserMode;
  final File? initialImageFile;

  const PixelColoringCanvas({
    super.key,
    required this.imagePath,
    required this.selectedColor,
    required this.mode,
    this.brushStrokes = const [],
    this.onPanStart,
    this.onPanStartWithMask,
    this.onPanUpdate,
    this.onPanEnd,
    this.onTapForRegion,
    this.onLoading,
    this.onFillComplete,
    this.isMoveMode = false,
    this.isLockRegionMode = false,
    this.isEraserMode = false,
    this.initialImageFile,
  });

  @override
  State<PixelColoringCanvas> createState() => PixelColoringCanvasState();
}

class PixelColoringCanvasState extends State<PixelColoringCanvas> {
  final FloodFillEngine _engine = FloodFillEngine();
  final TransformationController _transformationController =
      TransformationController();
  bool _isLoading = true;
  ui.Image? _displayImage;
  bool _isDrawing = false; // Track if currently drawing
  bool _engineReady = false; // Track if engine is ready
  int _pointerCount = 0; // Track active touches for auto-zoom
  bool _ignoreCurrentInteraction =
      false; // Flag to skip drawing if multi-touch detected
  int _lastBackgroundUpdateTime = 0; // Throttle background UI updates

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
      if (widget.initialImageFile != null) {
        await _engine.loadFromFile(widget.initialImageFile!);
      } else {
        await _engine.loadImage(widget.imagePath);
      }

      if (mounted) {
        setState(() {
          _displayImage = _engine.image;
          _isLoading = false;
          _engineReady = true;

          // Initialize transformation to fit image to screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final RenderBox box = context.findRenderObject() as RenderBox;
            final size = box.size;

            final double imgW = _displayImage!.width.toDouble();
            final double imgH = _displayImage!.height.toDouble();

            final double scaleX = size.width / imgW;
            final double scaleY = size.height / imgH;
            final double scale =
                (scaleX < scaleY ? scaleX : scaleY) * 0.9; // 90% fit

            final double dx = (size.width - imgW * scale) / 2;
            final double dy = (size.height - imgH * scale) / 2;

            _transformationController.value = Matrix4.identity()
              ..translate(dx, dy)
              ..scale(scale);
          });
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

    // Apply inverse transformation to get image coordinates
    final Matrix4 inverse = Matrix4.inverted(_transformationController.value);
    final Offset transformedPosition = MatrixUtils.transformPoint(
      inverse,
      localPosition,
    );

    if (widget.mode == ColoringMode.fill) {
      _handleFillTap(transformedPosition, constraints);
    } else {
      if (_ignoreCurrentInteraction || _pointerCount > 1) return;

      setState(() => _isDrawing = true);

      if (widget.isEraserMode) {
        _engine.saveHistoryState();
      }

      if (widget.isLockRegionMode && widget.onPanStartWithMask != null) {
        // Fetch mask image
        final int x = transformedPosition.dx.round();
        final int y = transformedPosition.dy.round();
        _engine.getRegionMaskImage(x, y).then((maskImage) {
          if (mounted &&
              _isDrawing &&
              !_ignoreCurrentInteraction &&
              _pointerCount == 1) {
            widget.onPanStartWithMask?.call(transformedPosition, maskImage);
          }
        });
      } else {
        widget.onPanStart?.call(transformedPosition);
      }
    }
  }

  void _handleFillTap(Offset transformedPosition, BoxConstraints constraints) {
    if (!_engineReady || _displayImage == null) return;

    final int x = transformedPosition.dx.round();
    final int y = transformedPosition.dy.round();

    if (x < 0 ||
        x >= _displayImage!.width ||
        y < 0 ||
        y >= _displayImage!.height) {
      return;
    }

    _engine
        .floodFill(x, y, widget.selectedColor)
        .then((newImage) {
          if (newImage != null && mounted) {
            setState(() {
              _displayImage = newImage;
            });
            HapticFeedback.lightImpact();
            widget.onFillComplete?.call();
          }
        })
        .catchError((error) {
          debugPrint('Flood fill error: $error');
        });
  }

  void _handlePanEnd() {
    _ignoreCurrentInteraction = false;
    if (_isDrawing) {
      setState(() => _isDrawing = false);
      widget.onPanEnd?.call();
    }
  }

  /// Exports the full image (including all brush strokes) as PNG bytes.
  /// This ensures the entire image is saved at original resolution,
  /// even if the user is currently zoomed in.
  Future<Uint8List?> exportImageBytes() async {
    if (_displayImage == null) return null;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(
        0,
        0,
        _displayImage!.width.toDouble(),
        _displayImage!.height.toDouble(),
      ),
    );

    final painter = _CombinedPainter(
      image: _displayImage!,
      brushStrokes: widget.brushStrokes,
    );

    painter.paint(
      canvas,
      ui.Size(
        _displayImage!.width.toDouble(),
        _displayImage!.height.toDouble(),
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      _displayImage!.width,
      _displayImage!.height,
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Commits current brush strokes to the background image.
  /// This flattens the strokes and makes them part of the base image,
  /// allowing them to be erased by the persistent eraser.
  Future<void> commitStrokesToImage() async {
    if (widget.brushStrokes.isEmpty || _displayImage == null) return;

    final bytes = await exportImageBytes();
    if (bytes != null) {
      await _engine.updateFromBytes(bytes);
      if (mounted) {
        setState(() {
          _displayImage = _engine.image;
        });
        widget.onFillComplete?.call(); // Notify that image has changed
      }
    }
  }

  Future<void> reloadImage() async {
    await _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isLoading || _displayImage == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            setState(() => _pointerCount++);
            if (_pointerCount > 1) {
              _ignoreCurrentInteraction = true;
              _handlePanEnd();
            }
          },
          onPointerUp: (event) {
            setState(() => _pointerCount--);
            if (_pointerCount == 0) {
              _ignoreCurrentInteraction = false;
            }
          },
          onPointerCancel: (event) {
            setState(() => _pointerCount = 0);
            _ignoreCurrentInteraction = false;
            _handlePanEnd();
          },
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.01,
            maxScale: 20.0,
            boundaryMargin: const EdgeInsets.all(5000),
            constrained: false,
            // Only enable panel/scale if 2+ fingers are used OR if in fill mode
            panEnabled: widget.mode == ColoringMode.fill || _pointerCount > 1,
            scaleEnabled: widget.mode == ColoringMode.fill || _pointerCount > 1,
            onInteractionStart: (details) {
              if (widget.mode == ColoringMode.brush && _pointerCount == 1) {
                _handleTapOrPanStart(details.focalPoint, constraints);
              }
            },
            onInteractionUpdate: (details) {
              if (widget.mode == ColoringMode.brush) {
                if (_pointerCount == 1 && !_ignoreCurrentInteraction) {
                  // Drawing mode
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(
                    details.focalPoint,
                  );
                  final Matrix4 inverse = Matrix4.inverted(
                    _transformationController.value,
                  );
                  final Offset transformedPosition = MatrixUtils.transformPoint(
                    inverse,
                    localPosition,
                  );

                  if (!_isDrawing) {
                    _handleTapOrPanStart(details.focalPoint, constraints);
                  } else {
                    widget.onPanUpdate?.call(transformedPosition);

                    // If we are drawing with eraser, also erase the background image pixels
                    if (widget.isEraserMode) {
                      final double eraserRadius = widget.brushStrokes.isNotEmpty
                          ? widget.brushStrokes.last.size / 2
                          : 30.0;

                      final bool changed = _engine.erasePixels(
                        transformedPosition.dx.round(),
                        transformedPosition.dy.round(),
                        eraserRadius,
                      );

                      if (changed) {
                        // Throttled update of the background image for UI feedback (max 30fps)
                        final int now = DateTime.now().millisecondsSinceEpoch;
                        if (now - _lastBackgroundUpdateTime > 32) {
                          _lastBackgroundUpdateTime = now;
                          _engine.updateDisplayImage().then((newImage) {
                            if (newImage != null && mounted && _isDrawing) {
                              setState(() => _displayImage = newImage);
                            }
                          });
                        }
                      }
                    }
                  }
                } else if (_pointerCount > 1 && _isDrawing) {
                  // Switched to zoom, kill active stroke
                  _handlePanEnd();
                }
              }
            },
            onInteractionEnd: (details) {
              _handlePanEnd();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_pointerCount <= 1) {
                  _handleTapOrPanStart(details.globalPosition, constraints);
                }
              },
              child: Container(
                width: _displayImage!.width.toDouble(),
                height: _displayImage!.height.toDouble(),
                color: Colors.transparent,
                child: CustomPaint(
                  painter: _CombinedPainter(
                    image: _displayImage!,
                    brushStrokes: widget.brushStrokes,
                  ),
                ),
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

  _CombinedPainter({required this.image, required this.brushStrokes}) {
    debugPrint('Painter created with ${brushStrokes.length} strokes');
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1:1 scale drawing - much simpler!
    final Rect rect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw brush strokes on a separate layer for eraser support
    canvas.saveLayer(rect, Paint());

    for (final stroke in brushStrokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.isEraser ? Colors.black : stroke.color
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }

      if (stroke.maskImage != null) {
        // Apply masking for this specific stroke
        canvas.saveLayer(rect, Paint());
        canvas.drawPath(path, paint);
        // Apply the mask
        canvas.drawImage(
          stroke.maskImage!,
          Offset.zero,
          Paint()..blendMode = BlendMode.dstIn,
        );
        canvas.restore();
      } else {
        canvas.drawPath(path, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CombinedPainter oldDelegate) {
    return image != oldDelegate.image ||
        brushStrokes != oldDelegate.brushStrokes;
  }
}
