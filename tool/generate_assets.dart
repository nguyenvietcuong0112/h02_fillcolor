import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  print('🎨 Generating coloring book assets...');
  
  // Configuration
  const int imageSize = 800; // Reduced from 1024 for better performance
  const String outputDir = 'assets/images';
  
  // Create output directory
  Directory(outputDir).createSync(recursive: true);

  final mandalaDir = Directory('$outputDir/mandala');
  if (!mandalaDir.existsSync()) {
    mandalaDir.createSync(recursive: true);
  }

  // Generate varied mandalas
  generateMandalaFile('${mandalaDir.path}/simple.svg', complexity: 3, layers: 4);
  generateMandalaFile('${mandalaDir.path}/complex.svg', complexity: 6, layers: 8);
  generateMandalaFile('${mandalaDir.path}/ornate.svg', complexity: 8, layers: 12);

  print('Asset generation complete!');
}

void generateMandalaFile(String filePath, {required int complexity, required int layers}) {
  final sb = StringBuffer();
  final width = 800;
  final height = 800;
  final cx = width / 2;
  final cy = height / 2;
  
  sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  sb.writeln('<svg width="$width" height="$height" viewBox="0 0 $width $height" xmlns="http://www.w3.org/2000/svg">');
  
  // Background (optional, but good for context)
  // sb.writeln('<rect width="$width" height="$height" fill="white"/>');

  // Group for fill-areas
  sb.writeln('<g id="fill-areas">');
  
  int pathCount = 0;
  
  // Generate layers from outside to inside
  for (int l = layers; l > 0; l--) {
    final radius = (350.0 / layers) * l;
    final segments = complexity * (l % 2 == 0 ? 2 : 1) + 4; // Vary segments per layer
    
    // Draw a ring of petals/shapes
    for (int i = 0; i < segments; i++) {
        final angle = (2 * pi / segments) * i;
        final pathData = _createPetalPath(cx, cy, radius, angle, 2 * pi / segments);
        
        sb.writeln('  <path id="area_layer${l}_shape${i}" d="$pathData" fill="white" stroke="black" stroke-width="2"/>');
        pathCount++;
    }
    
    // Draw a central circle for this layer to separate it from inner layers
    final innerRadius = radius * 0.8;
    // sb.writeln('  <circle cx="$cx" cy="$cy" r="$innerRadius" fill="none" stroke="black" stroke-width="2"/>');
    // We use path for circle to be consistent with coloring engine which expects paths?
    // Actually current parser handles paths efficiently. Let's make the "separator" a path too.
    // Or just let the petals overlap.
    // Let's create a ring path.
  }
  
  // Central shape
  sb.writeln('  <path id="area_center" d="M $cx ${cy - 20} A 20 20 0 1 0 $cx ${cy + 20} A 20 20 0 1 0 $cx ${cy - 20} Z" fill="white" stroke="black" stroke-width="2"/>');
  
  sb.writeln('</g>'); // End fill-areas
  sb.writeln('</svg>');
  
  File(filePath).writeAsStringSync(sb.toString());
  print('Generated $filePath with $pathCount paths');
}

String _createPetalPath(double cx, double cy, double radius, double angle, double sliceAngle) {
  // A simple petal shape: Start at center-ish, go out, curve back.
  // Converting polar to cartesian
  
  // Start point (inner)
  final rInner = radius * 0.4;
  final x1 = cx + rInner * cos(angle);
  final y1 = cy + rInner * sin(angle);
  
  // Tip point (outer)
  final x2 = cx + radius * cos(angle + sliceAngle / 2);
  final y2 = cy + radius * sin(angle + sliceAngle / 2);
  
  // End point (inner next)
  final x3 = cx + rInner * cos(angle + sliceAngle);
  final y3 = cy + rInner * sin(angle + sliceAngle);
  
  // Control points for bezier
  final cp1x = cx + radius * 0.8 * cos(angle);
  final cp1y = cy + radius * 0.8 * sin(angle);
  
  final cp2x = cx + radius * 0.8 * cos(angle + sliceAngle);
  final cp2y = cy + radius * 0.8 * sin(angle + sliceAngle);

  // Return SVG path d string
  // Curve from 1 to 2, then 2 to 3, then close to 1
  return 'M $x1 $y1 Q $cp1x $cp1y $x2 $y2 Q $cp2x $cp2y $x3 $y3 Z';
}
