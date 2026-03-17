import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A premium rounded icon button with shadow and animation
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isPrimary;

  const RoundIconButton({
    super.key,
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
          color: isPrimary
              ? Colors.blueGrey[900]
              : (enabled ? Colors.white : Colors.grey[200]),
          shape: BoxShape.circle,
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isPrimary
              ? Colors.white
              : (enabled ? Colors.blueGrey[800] : Colors.grey[400]),
        ),
      ),
    );
  }
}

/// A glass-morphism style container for controls
class GlassControlBar extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GlassControlBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
