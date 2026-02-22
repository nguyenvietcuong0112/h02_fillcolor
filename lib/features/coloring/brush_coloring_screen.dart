import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/coloring_image_model.dart';
import '../../data/models/brush_stroke.dart';
import '../../core/services/app_gallery_service.dart';
import '../gallery/gallery_screen.dart';
import 'widgets/pixel_coloring_canvas.dart';
import 'widgets/color_palette.dart';
import 'png_coloring_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_constants.dart';

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
  
  bool _isLockMode = true; // Enabled by default as it's a highly requested feature
  
  final GlobalKey<ColorPaletteState> _paletteKey = GlobalKey<ColorPaletteState>();

  // Undo/Redo
  final List<List<BrushStroke>> _undoStack = [];
  final List<List<BrushStroke>> _redoStack = [];
  
  // Eraser mode
  bool _isEraserMode = false;

  @override
  void initState() {
    super.initState();
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


  void _handlePanStartWithMask(Offset point, ui.Image? mask) {
    setState(() {
      _currentStroke = BrushStroke(
        points: [point],
        color: _isEraserMode ? Colors.transparent : _selectedColor, // Eraser uses transparent if mask is handled by painter
        size: _brushSize,
        opacity: 1.0,
        isEraser: _isEraserMode,
        maskImage: mask,
      );
    });
  }

  void _handlePanStart(Offset point) {
    setState(() {
      _currentStroke = BrushStroke(
        points: [point],
        color: _isEraserMode ? Colors.transparent : _selectedColor,
        size: _brushSize,
        opacity: 1.0,
        isEraser: _isEraserMode,
      );
    });
  }

  void _handlePanUpdate(Offset point) {
    if (_currentStroke != null) {
      setState(() {
        _currentStroke = _currentStroke!.copyWith(
          points: [..._currentStroke!.points, point],
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
    if (_canvasKey.currentContext == null) {
      debugPrint('Error: Canvas context is null');
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final RenderRepaintBoundary? boundary = 
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception('RenderObject is not a RenderRepaintBoundary');
      }

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
          SnackBar(
            content: Text(ref.tr('saved_to_gallery')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Save error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ref.tr('save_failed')}: ${e.toString()}'),
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
      body: Stack(
        children: [
          // 1. Full-screen Canvas
          Positioned.fill(
            child: RepaintBoundary(
              key: _canvasKey,
              child: PixelColoringCanvas(
                imagePath: widget.image.svgPath,
                selectedColor: _selectedColor,
                mode: ColoringMode.brush,
                brushStrokes: _allStrokes,
                isLockRegionMode: _isLockMode,
                onPanStart: _handlePanStart,
                onPanStartWithMask: _handlePanStartWithMask,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                onLoading: (loading) {},
              ),
            ),
          ),

          // 2. PRIMARY TOP BAR (Controls)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _GlassControlBar(
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _RoundIconButton(
                        icon: Icons.undo_rounded,
                        onTap: _undoStack.isNotEmpty ? _undo : null,
                        enabled: _undoStack.isNotEmpty,
                      ),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: Icons.redo_rounded,
                        onTap: _redoStack.isNotEmpty ? _redo : null,
                        enabled: _redoStack.isNotEmpty,
                      ),
                      const SizedBox(width: 8),
                      if (_isSaving)
                        const _Loader()
                      else
                        _RoundIconButton(
                          icon: Icons.save_alt_rounded,
                          onTap: _saveToAppGallery,
                          isPrimary: true,
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 3. SECONDARY TOP BAR (Brush Size Slider - Requested Position!)
                _GlassControlBar(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.line_weight_rounded, size: 18, color: Colors.blueGrey[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: _brushSize,
                            min: AppConstants.minBrushSize,
                            max: AppConstants.maxBrushSize,
                            activeColor: Colors.blueGrey[800],
                            onChanged: (value) => setState(() => _brushSize = value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${_brushSize.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. VERTICAL TOOLBAR (Right side)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: 12,
            child: Column(
              children: [
                _GlassControlBar(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                      _ToolButton(
                        icon: Icons.brush_rounded,
                        isSelected: !_isEraserMode,
                        onTap: () => setState(() => _isEraserMode = false),
                      ),
                      const SizedBox(height: 8),
                      _ToolButton(
                        icon: Icons.auto_fix_high_rounded,
                        isSelected: _isEraserMode,
                        activeColor: Colors.orange,
                        onTap: () => setState(() => _isEraserMode = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _GlassControlBar(
                  padding: const EdgeInsets.all(6),
                  child: _ToggleToolButton(
                    icon: _isLockMode ? Icons.format_paint_rounded : Icons.format_paint_outlined,
                    isActive: _isLockMode,
                    activeColor: Colors.blueAccent,
                    onTap: () => setState(() => _isLockMode = !_isLockMode),
                    label: ref.tr('lock_region'),
                  ),
                ),
                const SizedBox(height: 12),
                _GlassControlBar(
                  padding: const EdgeInsets.all(6),
                  child: _ToolButton(
                    icon: Icons.delete_outline_rounded,
                    onTap: () {
                       setState(() {
                        _undoStack.add(List.from(_brushStrokes));
                        _redoStack.clear();
                        _brushStrokes = [];
                        _currentStroke = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. BOTTOM PALETTE TRAY (Integrated!)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorPalette(
              key: _paletteKey,
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                  _isEraserMode = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// --- Premium UI Helper Widgets ---

class _ToggleToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final String label;

  const _ToggleToolButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: isActive ? Colors.white : Colors.blueGrey[700]),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.blueGrey[400])),
          ],
        ),
      ),
    );
  }
}


/// --- Premium UI Helper Widgets ---

class _GlassControlBar extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassControlBar({required this.child, this.padding = const EdgeInsets.all(8)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isPrimary;

  const _RoundIconButton({
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blueGrey[900] : (enabled ? Colors.white : Colors.grey[200]),
          shape: BoxShape.circle,
          boxShadow: [
             if (enabled) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isPrimary ? Colors.white : (enabled ? Colors.blueGrey[800] : Colors.grey[400]),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    this.isSelected = false,
    this.activeColor = const Color(0xFF263238),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)] : [],
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.white : Colors.blueGrey[700],
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
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
