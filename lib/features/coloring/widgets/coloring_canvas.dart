import 'package:flutter/material.dart';
import '../../../data/models/svg_path_data.dart';
import '../../../data/models/brush_stroke.dart';


/// Custom painter for coloring canvas
/// 
/// Vẽ toàn bộ SVG trong 1 CustomPainter duy nhất để tránh lag với Impeller.
/// Theo kiến trúc: "Coloring SVG images in Flutter and why I decided to disable Impeller"
/// 
/// Performance optimizations:
/// - Cache static paints (outline)
/// - Optimize rendering order
/// - Minimize paint object creation
class ColoringPainter extends CustomPainter {
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;

  // Cache static paints để tránh tạo mới mỗi lần paint
  static final Paint _outlinePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  ColoringPainter({
    required this.svgPaths,
    required this.filledPaths,
    required this.brushStrokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1: Draw filled paths (fill layer)
    for (final pathData in svgPaths) {
      final fillColor = filledPaths[pathData.id];
      if (fillColor != null) {
        canvas.drawPath(
          pathData.path,
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Layer 2: Draw brush strokes (dynamic brush layer), clipped per region
    if (brushStrokes.isNotEmpty) {
      // Cache region lookup để tránh search nhiều lần
      final regionCache = <String, SvgPathData>{};
      
      for (final stroke in brushStrokes) {
        final paint = Paint()
          ..color = stroke.color.withValues(alpha: stroke.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.size
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final path = stroke.toPath();

        if (stroke.pathId != null) {
          // Find region to clip to
          final region = regionCache.putIfAbsent(
            stroke.pathId!,
            () => svgPaths.firstWhere(
              (p) => p.id == stroke.pathId,
              orElse: () => SvgPathData(
                id: '',
                path: Path(),
                bounds: Rect.zero,
              ),
            ),
          );
          
          if (region.id.isNotEmpty) {
            canvas.save();
            // Critical: Clip drawing to the specific SVG path
            canvas.clipPath(region.path);
            canvas.drawPath(path, paint);
            canvas.restore();
            continue;
          }
        }

        // Fallback or Freehand (if no pathId)
        canvas.drawPath(path, paint);
      }
    }

    // Layer 3: Draw path outlines
    for (final pathData in svgPaths) {
      canvas.drawPath(pathData.path, _outlinePaint);
    }
  }

  @override
  bool shouldRepaint(ColoringPainter oldDelegate) {
    return identical(oldDelegate.filledPaths, filledPaths) == false ||
        identical(oldDelegate.brushStrokes, brushStrokes) == false;
  }
}

/// Canvas widget for coloring
/// 
/// Sử dụng InteractiveViewer để xử lý zoom/pan mượt mà.
/// Hit testing được thực hiện bằng cách transform tọa độ từ screen space về SVG space.
class ColoringCanvas extends StatefulWidget {
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;
  final bool isBrushMode;
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
  late final TransformationController _transformationController;
  final GlobalKey _childKey = GlobalKey();
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo TransformationController
    // Theo Medium articles: cần khởi tạo với Matrix4.identity() để có thể zoom out ngay từ đầu
    _transformationController = TransformationController();
    // Set initial transformation = identity (scale = 1.0)
    // Điều này đảm bảo có thể zoom out ngay từ đầu mà không cần zoom in trước
    _transformationController.value = Matrix4.identity();
    
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Calculate canvas size từ SVG bounds để tối ưu rendering
  Size _calculateCanvasSize() {
    if (widget.svgPaths.isEmpty) {
      return const Size(800, 800); // Default size
    }
    
    // Tính bounds tổng từ tất cả paths
    Rect? totalBounds;
    for (final pathData in widget.svgPaths) {
      totalBounds = totalBounds == null
          ? pathData.bounds
          : totalBounds.expandToInclude(pathData.bounds);
    }
    
    if (totalBounds != null) {
      // Thêm padding để đảm bảo không bị cắt
      return Size(
        totalBounds.width + 100,
        totalBounds.height + 100,
      );
    }
    
    return const Size(800, 800);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.1, // Cho phép zoom out nhiều hơn
      maxScale: 8.0,
      panEnabled: !widget.isBrushMode, // Disable pan in brush mode to allow drawing
      scaleEnabled: true, // Cho phép zoom trong brush mode (2 ngón tay), nhưng vẽ với 1 ngón tay
      boundaryMargin: const EdgeInsets.all(double.infinity), // Cho phép pan ra ngoài bounds
      clipBehavior: Clip.none, // Không clip để tối ưu performance
      // Theo Medium articles: constrained = false cho phép zoom out ngay từ đầu
      // Không bị constraint bởi child size, có thể zoom out tự do
      // Điều này đảm bảo có thể zoom out ngay từ đầu mà không cần zoom in trước
      constrained: false,
      onInteractionStart: (details) {
        if (widget.isBrushMode && details.pointerCount == 1) {
          // Brush mode: start drawing với 1 ngón tay
          _isPanning = true;
          // localFocalPoint là trong coordinate space của child (đã transform)
          final svgPoint = _transformToSvgSpace(details.localFocalPoint);
          widget.onPanStart(svgPoint);
        }
      },
      onInteractionUpdate: (details) {
        if (widget.isBrushMode) {
          if (details.pointerCount == 1 && _isPanning) {
            // Brush mode: continue drawing với 1 ngón tay
            // localFocalPoint là trong coordinate space của child (đã transform)
            final svgPoint = _transformToSvgSpace(details.localFocalPoint);
            widget.onPanUpdate(svgPoint);
          } else if (details.pointerCount >= 2) {
            final RenderBox? box = _childKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              final localOffset = box.globalToLocal(details.focalPoint);
              widget.onPanUpdate(localOffset);
            }
          } 
          // 2 fingers (pointerCount >= 2) will be handled by InteractiveViewer for zoom automatically
        }
      },
      onInteractionEnd: (details) {
        if (widget.isBrushMode) {
          // Note: onInteractionEnd details doesn't have pointerCount usually, 
          // or acts differently. But if we were drawing, we should end.
          // We can just call end stroke safely.
          widget.onPanEnd();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // Đảm bảo hit test chính xác
        onTapDown: (details) {
          if (!widget.isBrushMode) {
            // Fill mode: handle tap
            // Use globalToLocal to ensure precise coordinates relative to the CustomPaint
            final RenderBox? box = _childKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              final localOffset = box.globalToLocal(details.globalPosition);
              widget.onTap(localOffset);
            }
          }
        },
        // Remove Pan callbacks from GestureDetector to avoid conflict with InteractiveViewer
        // InteractiveViewer will handle the "gesture arena" and give us events via onInteraction*
        onPanStart: null,
        onPanUpdate: null,
        onPanEnd: null,
        child: RepaintBoundary(
          key: widget.repaintBoundaryKey,
          child: CustomPaint(
            key: _childKey,
            painter: ColoringPainter(
              svgPaths: widget.svgPaths,
              filledPaths: widget.filledPaths,
              brushStrokes: widget.brushStrokes,
            ),
            // Sử dụng size từ bounds của SVG để tối ưu
            size: _calculateCanvasSize(),
          ),
        ),
      ),
    );
  }

  /// Transform tọa độ từ InteractiveViewer local space về SVG space
  /// 
  /// Với InteractiveViewer:
  /// - `localPosition` hoặc `localFocalPoint` là trong coordinate space của child widget
  /// - Child widget đã bị transform bởi InteractiveViewer (scale + translate)
  /// - Để transform ngược về SVG space (original), ta cần invert transformation matrix
  /// 
  /// Công thức: SVG_point = inverseMatrix * localPoint
  Offset _transformToSvgSpace(Offset localPoint) {
    final matrix = _transformationController.value;
    
    // Nếu không có transform, return trực tiếp
    if (matrix.isIdentity()) {
      return localPoint;
    }
    
    // Invert matrix để transform ngược từ transformed space về original space
    // InteractiveViewer sử dụng affine transform (scale + translate)
    final inverseMatrix = Matrix4.inverted(matrix);
    final storage = inverseMatrix.storage;
    
    final x = localPoint.dx;
    final y = localPoint.dy;
    
    // Transform point [x, y, 0, 1] qua inverse matrix
    // Matrix4 storage format (column-major):
    // [m0, m4, m8,  m12]   [x]   [x']
    // [m1, m5, m9,  m13] * [y] = [y']
    // [m2, m6, m10, m14]   [0]   [z']
    // [m3, m7, m11, m15]   [1]   [w']
    //
    // Với affine transform (InteractiveViewer chỉ dùng scale + translate):
    // x' = m0*x + m4*y + m12
    // y' = m1*x + m5*y + m13
    // w' = m3*x + m7*y + m15 (luôn = 1 cho affine)
    
    final transformedX = storage[0] * x + storage[4] * y + storage[12];
    final transformedY = storage[1] * x + storage[5] * y + storage[13];
    
    return Offset(transformedX, transformedY);
  }
}

