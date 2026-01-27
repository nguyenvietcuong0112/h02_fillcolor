import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/coloring_image_model.dart';
import '../../data/models/brush_stroke.dart';
import '../../core/services/app_gallery_service.dart';
import '../gallery/gallery_screen.dart';
import 'engine/flood_fill_engine.dart';
import 'widgets/pixel_coloring_canvas.dart';
import 'widgets/color_palette.dart';
import '../../core/constants/app_constants.dart';
import 'png_coloring_state.dart';

/// Brush mode coloring screen - simplified with local state
class BrushColoringScreen extends ConsumerStatefulWidget {
  final ColoringImageModel image;

  const BrushColoringScreen({
    super.key,
    required this.image,
  });

  @override
  ConsumerState<BrushColoringScreen> createState() => _BrushColoringScreenState();
}

class _BrushColoringScreenState extends ConsumerState<BrushColoringScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;
  
  // Local state for brush
  Color _selectedColor = Color(AppConstants.defaultColors[0]);
  double _brushSize = 10.0;
  List<BrushStroke> _brushStrokes = [];
  BrushStroke? _currentStroke;
  
  // Region clipping
  Uint8List? _activeRegionMask;
  int _imageWidth = 0;
  int _imageHeight = 0;
  bool _isLoadingRegion = false;
  
  // Undo/Redo
  List<List<BrushStroke>> _undoStack = [];
  List<List<BrushStroke>> _redoStack = [];
  
  // Eraser mode
  bool _isEraserMode = false;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    // Load image to get dimensions for region detection
    final data = await rootBundle.load(widget.image.svgPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    
    setState(() {
      _redoStack.add(List.from(_brushStrokes));
      _brushStrokes = _undoStack.removeLast();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    
    setState(() {
      _undoStack.add(List.from(_brushStrokes));
      _brushStrokes = _redoStack.removeLast();
    });
  }

  void _toggleEraser() {
    setState(() {
      _isEraserMode = !_isEraserMode;
    });
  }

  Future<void> _selectRegion(Offset point) async {
    if (_isLoadingRegion) return;
    
    final x = point.dx.toInt();
    final y = point.dy.toInt();
    
    if (x < 0 || x >= _imageWidth || y < 0 || y >= _imageHeight) return;

    setState(() => _isLoadingRegion = true);

    try {
      // Use flood fill engine to detect region
      final engine = FloodFillEngine();
      await engine.loadImage(widget.image.svgPath);
      final mask = await engine.getRegionMask(x, y);
      
      if (mask != null && mounted) {
        setState(() {
          _activeRegionMask = mask;
          _isLoadingRegion = false;
        });
        HapticFeedback.mediumImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Region selected! You can now draw within it.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        setState(() => _isLoadingRegion = false);
      }
    } catch (e) {
      debugPrint('Region selection error: $e');
      setState(() => _isLoadingRegion = false);
    }
  }

  bool _isPointInRegion(Offset point) {
    if (_activeRegionMask == null) return true; // No region selected, allow all
    
    final x = point.dx.toInt();
    final y = point.dy.toInt();
    
    if (x < 0 || x >= _imageWidth || y < 0 || y >= _imageHeight) {
      return false;
    }
    
    final index = y * _imageWidth + x;
    return _activeRegionMask![index] == 1;
  }

  void _handlePanStart(Offset point) {
    debugPrint('Controller: Pan start at $point');
    
    // Check if point is in region
    if (!_isPointInRegion(point)) {
      debugPrint('Point outside region, ignoring');
      return;
    }
    
    setState(() {
      _currentStroke = BrushStroke(
        points: [point],
        color: _isEraserMode ? Colors.transparent : _selectedColor,
        size: _brushSize,
        opacity: 1.0,
      );
    });
  }

  void _handlePanUpdate(Offset point) {
    debugPrint('Controller: Pan update at $point');
    if (_currentStroke != null && _isPointInRegion(point)) {
      setState(() {
        _currentStroke = BrushStroke(
          points: [..._currentStroke!.points, point],
          color: _currentStroke!.color,
          size: _currentStroke!.size,
          opacity: _currentStroke!.opacity,
        );
      });
    }
  }

  void _handlePanEnd() {
    debugPrint('Controller: Pan end');
    if (_currentStroke != null) {
      setState(() {
        // Save current state to undo stack
        _undoStack.add(List.from(_brushStrokes));
        _redoStack.clear(); // Clear redo stack on new action
        
        _brushStrokes = [..._brushStrokes, _currentStroke!];
        _currentStroke = null;
      });
      debugPrint('Total strokes: ${_brushStrokes.length}');
    }
  }

  List<BrushStroke> get _allStrokes {
    if (_currentStroke != null) {
      return [..._brushStrokes, _currentStroke!];
    }
    return _brushStrokes;
  }

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
    } catch (e, stackTrace) {
      debugPrint('Save error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
          '${widget.image.name} - Brush Mode',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoStack.isNotEmpty ? _undo : null,
            tooltip: 'Undo',
          ),
          // Redo
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
            tooltip: 'Redo',
          ),
          // Eraser toggle
          IconButton(
            icon: Icon(_isEraserMode ? Icons.brush : Icons.auto_fix_high),
            onPressed: _toggleEraser,
            tooltip: _isEraserMode ? 'Switch to Brush' : 'Switch to Eraser',
            color: _isEraserMode ? Colors.orange : null,
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _undoStack.add(List.from(_brushStrokes));
                _redoStack.clear();
                _brushStrokes = [];
                _currentStroke = null;
              });
            },
            tooltip: 'Clear All',
          ),
          // Save
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
              tooltip: 'Save to App Gallery',
            ),
        ],
      ),
      body: Column(
        children: [
          // Brush size slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.brush, size: 16),
                Expanded(
                  child: Slider(
                    value: _brushSize,
                    min: AppConstants.minBrushSize,
                    max: AppConstants.maxBrushSize,
                    onChanged: (value) {
                      setState(() => _brushSize = value);
                    },
                  ),
                ),
                Text('${_brushSize.toInt()}'),
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: PixelColoringCanvas(
                imagePath: widget.image.svgPath,
                selectedColor: _selectedColor,
                mode: ColoringMode.brush,
                brushStrokes: _allStrokes,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                onTapForRegion: _selectRegion,
                onLoading: (loading) {},
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
