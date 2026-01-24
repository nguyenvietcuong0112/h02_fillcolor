import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Color palette widget
class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Combine all colors (default + premium)
    final allColors = [
      ...AppConstants.defaultColors,
      ...AppConstants.premiumColors,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...allColors.map((colorValue) {
              final color = Color(colorValue);
              return _ColorButton(
                color: color,
                isSelected: color == selectedColor,
                onTap: () => onColorSelected(color),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Color button widget
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: isSelected ? 48 : 44,
        height: isSelected ? 48 : 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey[400]!,
            width: isSelected ? 3.5 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}

