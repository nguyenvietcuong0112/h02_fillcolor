import 'package:flutter/material.dart';

class PremiumFillIcon extends StatelessWidget {
  final double size;
  final Color color;

  const PremiumFillIcon({super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FillIconPainter(color: color)),
    );
  }
}

class _FillIconPainter extends CustomPainter {
  final Color color;

  _FillIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw a subtle background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, glowPaint);

    final bucketPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, color.withValues(alpha: 0.7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    // More realistic tilted bucket
    path.moveTo(size.width * 0.15, size.height * 0.45);
    path.lineTo(size.width * 0.45, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.55);
    path.lineTo(size.width * 0.55, size.height * 0.85);
    path.close();

    // Shadow for the bucket
    canvas.drawPath(
      path.shift(const Offset(2, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(path, bucketPaint);

    // Liquid spill effect
    final liquidPaint = Paint()
      ..shader = LinearGradient(colors: [color.withValues(alpha: 0.9), color])
          .createShader(
            Rect.fromLTWH(
              size.width * 0.6,
              size.height * 0.6,
              size.width * 0.3,
              size.height * 0.3,
            ),
          );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 0.75),
        width: size.width * 0.35,
        height: size.width * 0.45,
      ),
      liquidPaint,
    );

    // Rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, rimPaint);

    // Glossy shine
    final shinePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.5), Colors.transparent],
          ).createShader(
            Rect.fromLTWH(
              size.width * 0.2,
              size.height * 0.2,
              size.width * 0.3,
              size.height * 0.3,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.35),
      size.width * 0.1,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PremiumBrushIcon extends StatelessWidget {
  final double size;
  final Color color;

  const PremiumBrushIcon({super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrushIconPainter(color: color)),
    );
  }
}

class _BrushIconPainter extends CustomPainter {
  final Color color;

  _BrushIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background paint splash
    final splashPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.15), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 1.5));
    canvas.drawCircle(center, size.width / 2, splashPaint);

    // Handle (Wooden texture look)
    final handlePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown[400]!, Colors.brown[700]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final handlePath = Path();
    handlePath.moveTo(size.width * 0.1, size.height * 0.9);
    handlePath.lineTo(size.width * 0.4, size.height * 0.6);
    handlePath.lineTo(size.width * 0.5, size.height * 0.7);
    handlePath.lineTo(size.width * 0.2, size.height * 1.0);
    handlePath.close();
    canvas.drawPath(handlePath, handlePaint);

    // Ferrule (Metallic look)
    final ferrulePaint = Paint()
      ..shader =
          LinearGradient(
            colors: [Colors.grey[200]!, Colors.grey[500]!, Colors.grey[300]!],
          ).createShader(
            Rect.fromLTWH(
              size.width * 0.3,
              size.height * 0.4,
              size.width * 0.3,
              size.height * 0.3,
            ),
          );

    final ferrulePath = Path();
    ferrulePath.moveTo(size.width * 0.4, size.height * 0.6);
    ferrulePath.lineTo(size.width * 0.55, size.height * 0.45);
    ferrulePath.lineTo(size.width * 0.65, size.height * 0.55);
    ferrulePath.lineTo(size.width * 0.5, size.height * 0.7);
    ferrulePath.close();
    canvas.drawPath(ferrulePath, ferrulePaint);

    // Bristles (Wet paint look)
    final bristlesPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [color, color.withValues(alpha: 0.6)],
          ).createShader(
            Rect.fromLTWH(
              size.width * 0.5,
              size.height * 0.1,
              size.width * 0.4,
              size.height * 0.4,
            ),
          );

    final bristlePath = Path();
    bristlePath.moveTo(size.width * 0.55, size.height * 0.45);
    bristlePath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.1,
    );
    bristlePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width * 0.65,
      size.height * 0.55,
    );
    bristlePath.close();
    canvas.drawPath(bristlePath, bristlesPaint);

    // Glossy streak on bristles
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.25),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
