import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../palette_selection_screen.dart';
import 'custom_color_picker.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Color palette widget
class ColorPalette extends ConsumerStatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final Function(int)? onPageChanged;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.onPageChanged,
  });

  @override
  ConsumerState<ColorPalette> createState() => ColorPaletteState();
}

class ColorPaletteState extends ConsumerState<ColorPalette> {
  late PageController _pageController;
  int _currentIndex = 0;
  final List<Color> _colorHistory = [];
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = AppConstants.colorPalettes.keys.toList();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateHistory(Color color) {
    if (_colorHistory.isEmpty || _colorHistory.first != color) {
      setState(() {
        _colorHistory.removeWhere((c) => c == color);
        _colorHistory.insert(0, color);
        if (_colorHistory.length > 10) {
          _colorHistory.removeLast();
        }
      });
    }
  }

  Future<void> _showCustomColorPicker(BuildContext context) async {
    Color pickedColor = widget.selectedColor;
    
    final result = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Text(
              ref.tr('custom_color'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            CustomColorPicker(
              initialColor: pickedColor,
              onColorChanged: (color) => pickedColor = color,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, pickedColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text(ref.tr('apply_color'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      widget.onColorSelected(result);
      _updateHistory(result);
    }
  }

  Future<void> _showPaletteSelection(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaletteSelectionScreen(
          currentCategory: _categories[_currentIndex],
          onCategorySelected: (category, colors) {
            final index = _categories.indexOf(category);
            if (index != -1) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 1. Integrated Category Selection & Buttons (NEW POSITION!)
              Row(
                children: [
                   // Palette Controls (Small)
                  _SmallButton(
                    icon: Icons.add_rounded,
                    onTap: () => _showPaletteSelection(context),
                  ),
                  const SizedBox(width: 12),
                  _SmallButton(
                    icon: Icons.colorize_rounded,
                    isRainbow: true,
                    onTap: () => _showCustomColorPicker(context),
                  ),
                  const SizedBox(width: 12),
                  // _SmallButton(
                  //   icon: Icons.history_rounded,
                  //   onTap: () {
                  //     if (_colorHistory.isNotEmpty) {
                  //       widget.onColorSelected(_colorHistory.first);
                  //     }
                  //   },
                  //   showBadge: _colorHistory.isNotEmpty,
                  // ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(height: 20, child: VerticalDivider(color: Colors.black12, width: 1)),
                  ),
                  // Categories Chips
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 4),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = _currentIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blueGrey[900] : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(18),
                                border: isSelected ? null : Border.all(color: Colors.blueGrey[100]!),
                              ),
                              child: Text(
                                ref.tr(_categories[index].toLowerCase()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.blueGrey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 2. COLOR GRID
              SizedBox(
                height: 140,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    widget.onPageChanged?.call(index);
                  },
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final colors = AppConstants.colorPalettes[category]!.map((c) => Color(c)).toList();
                    
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 50,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: colors.length,
                      itemBuilder: (context, idx) {
                        final color = colors[idx];
                        return _ColorButton(
                          color: color,
                          isSelected: color == widget.selectedColor,
                          onTap: () {
                            widget.onColorSelected(color);
                            _updateHistory(color);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isRainbow;
  final bool showBadge;

  const _SmallButton({
    required this.icon,
    required this.onTap,
    this.isRainbow = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          gradient: isRainbow ? const SweepGradient(
            colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
          ) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 16, color: isRainbow ? Colors.white : Colors.blueGrey[700]),
            if (showBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVeryLight = color.computeLuminance() > 0.9;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.15 : 1.0,
        curve: Curves.elasticOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected 
                ? Colors.black87 
                : (isVeryLight ? Colors.grey[300]! : Colors.transparent),
              width: isSelected ? 3.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              if (isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }
}


