import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Engine for performing flood fill operations on images
class FloodFillEngine {
  ui.Image? _image;
  Uint8List? _pixels;
  int _width = 0;
  int _height = 0;
  
  // History management for undo/redo
  final List<Uint8List> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 20;

  ui.Image? get image => _image;
  bool get isReady => _image != null && _pixels != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  /// Load an image from assets
  Future<void> loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    _image = frameInfo.image;
    
    _width = _image!.width;
    _height = _image!.height;
    
    // Convert image to pixel data
    final ByteData? byteData = await _image!.toByteData(format: ui.ImageByteFormat.rawRgba);
    _pixels = byteData!.buffer.asUint8List();
    
    // Initialize history with the initial state
    _history.clear();
    _history.add(Uint8List.fromList(_pixels!));
    _historyIndex = 0;
  }

  /// Perform optimized flood fill
  Future<ui.Image?> floodFill(int x, int y, ui.Color newColor) async {
    if (!isReady) return null;
    if (x < 0 || x >= _width || y < 0 || y >= _height) return null;

    // Save current state to history before making changes
    _saveToHistory();

    final int startIndex = (y * _width + x) * 4;
    final int targetR = _pixels![startIndex];
    final int targetG = _pixels![startIndex + 1];
    final int targetB = _pixels![startIndex + 2];
    final int targetA = _pixels![startIndex + 3];

    final int newR = (newColor.r * 255.0).round();
    final int newG = (newColor.g * 255.0).round();
    final int newB = (newColor.b * 255.0).round();
    final int newA = (newColor.a * 255.0).round();

    // If target color is same as new color, no need to fill
    if (targetR == newR && targetG == newG && targetB == newB && targetA == newA) {
      return _image;
    }

    // Create a copy of pixels to modify
    final Uint8List newPixels = Uint8List.fromList(_pixels!);
    
    // Use BFS flood fill with pixel limit to prevent hanging
    final Queue<int> queue = Queue<int>();
    final Set<int> visited = {};
    queue.add(x);
    queue.add(y);
    
    const int tolerance = 15;
    const int maxPixels = 500000; // Limit to prevent infinite loops
    int pixelsFilled = 0;

    bool isMatch(int px, int py) {
      if (px < 0 || px >= _width || py < 0 || py >= _height) return false;
      
      final int i = (py * _width + px) * 4;
      final int r = _pixels![i];
      final int g = _pixels![i + 1];
      final int b = _pixels![i + 2];
      final int a = _pixels![i + 3];

      return (r - targetR).abs() <= tolerance &&
             (g - targetG).abs() <= tolerance &&
             (b - targetB).abs() <= tolerance &&
             (a - targetA).abs() <= tolerance;
    }

    void fillPixel(int px, int py) {
      final int i = (py * _width + px) * 4;
      newPixels[i] = newR;
      newPixels[i + 1] = newG;
      newPixels[i + 2] = newB;
      newPixels[i + 3] = newA;
    }

    while (queue.isNotEmpty && pixelsFilled < maxPixels) {
      final int cx = queue.removeFirst();
      final int cy = queue.removeFirst();
      final int key = cy * _width + cx;

      if (visited.contains(key)) continue;
      if (!isMatch(cx, cy)) continue;

      visited.add(key);
      fillPixel(cx, cy);
      pixelsFilled++;

      // Add neighbors (4-connected)
      if (cx + 1 < _width) {
        queue.add(cx + 1);
        queue.add(cy);
      }
      if (cx - 1 >= 0) {
        queue.add(cx - 1);
        queue.add(cy);
      }
      if (cy + 1 < _height) {
        queue.add(cx);
        queue.add(cy + 1);
      }
      if (cy - 1 >= 0) {
        queue.add(cx);
        queue.add(cy - 1);
      }
    }

    debugPrint('Flood fill completed: $pixelsFilled pixels filled');

    // Convert modified pixels back to image
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(newPixels);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: _width,
      height: _height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    
    _image = frameInfo.image;
    _pixels = newPixels; // Update pixels cache
    return _image;
  }

  /// Get region mask for brush clipping
  Future<Uint8List?> getRegionMask(int x, int y) async {
    if (!isReady) return null;
    if (x < 0 || x >= _width || y < 0 || y >= _height) return null;

    final int startIndex = (y * _width + x) * 4;
    final int targetR = _pixels![startIndex];
    final int targetG = _pixels![startIndex + 1];
    final int targetB = _pixels![startIndex + 2];
    final int targetA = _pixels![startIndex + 3];

    // Create mask
    final Uint8List mask = Uint8List(_width * _height);
    final Queue<int> queue = Queue<int>();
    queue.add(x);
    queue.add(y);
    mask[y * _width + x] = 1;

    const int tolerance = 15;
    const int maxPixels = 500000;
    int pixelsProcessed = 0;

    bool isMatch(int px, int py) {
      if (px < 0 || px >= _width || py < 0 || py >= _height) return false;
      
      final int i = (py * _width + px) * 4;
      final int r = _pixels![i];
      final int g = _pixels![i + 1];
      final int b = _pixels![i + 2];
      final int a = _pixels![i + 3];

      return (r - targetR).abs() <= tolerance &&
             (g - targetG).abs() <= tolerance &&
             (b - targetB).abs() <= tolerance &&
             (a - targetA).abs() <= tolerance;
    }

    while (queue.isNotEmpty && pixelsProcessed < maxPixels) {
      final int cx = queue.removeFirst();
      final int cy = queue.removeFirst();
      pixelsProcessed++;

      // Check neighbors
      void checkAndAdd(int nx, int ny) {
        if (nx >= 0 && nx < _width && ny >= 0 && ny < _height) {
          final int idx = ny * _width + nx;
          if (mask[idx] == 0 && isMatch(nx, ny)) {
            mask[idx] = 1;
            queue.add(nx);
            queue.add(ny);
          }
        }
      }

      checkAndAdd(cx + 1, cy);
      checkAndAdd(cx - 1, cy);
      checkAndAdd(cx, cy + 1);
      checkAndAdd(cx, cy - 1);
    }

    debugPrint('Region mask created: $pixelsProcessed pixels processed');
    return mask;
  }

  /// Save current state to history
  void _saveToHistory() {
    // Remove any redo history when a new action is performed
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    
    // Add current state to history
    _history.add(Uint8List.fromList(_pixels!));
    _historyIndex++;
    
    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  /// Undo the last fill operation
  Future<ui.Image?> undo() async {
    if (!canUndo) return _image;
    
    _historyIndex--;
    _pixels = Uint8List.fromList(_history[_historyIndex]);
    
    // Convert pixels back to image
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_pixels!);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: _width,
      height: _height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    
    _image = frameInfo.image;
    debugPrint('Undo: restored to history index $_historyIndex');
    return _image;
  }

  /// Redo the last undone fill operation
  Future<ui.Image?> redo() async {
    if (!canRedo) return _image;
    
    _historyIndex++;
    _pixels = Uint8List.fromList(_history[_historyIndex]);
    
    // Convert pixels back to image
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_pixels!);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: _width,
      height: _height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    
    _image = frameInfo.image;
    debugPrint('Redo: restored to history index $_historyIndex');
    return _image;
  }

  /// Clear history (useful when loading a new image)
  void clearHistory() {
    _history.clear();
    _historyIndex = -1;
  }
}
