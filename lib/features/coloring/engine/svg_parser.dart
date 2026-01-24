import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../data/models/svg_path_data.dart';

/// Parser for SVG files to extract fillable paths
class SvgParser {
  /// Parse SVG file and extract paths
  static Future<List<SvgPathData>> parseSvg(String assetPath) async {
    try {
      debugPrint('Loading SVG from: $assetPath');
      // Load SVG file as string
      final String svgString = await rootBundle.loadString(assetPath);
      debugPrint('SVG loaded, length: ${svgString.length}');
      debugPrint('First 200 chars: ${svgString.substring(0, svgString.length > 200 ? 200 : svgString.length)}');
      
      // Parse SVG and extract paths
      final paths = _parseSvgString(svgString);
      debugPrint('Successfully parsed ${paths.length} paths');
      return paths;
    } catch (e, stackTrace) {
      debugPrint('Error parsing SVG $assetPath: $e');
      debugPrint('Stack trace: $stackTrace');
      // Return placeholder paths if parsing fails
      return _createPlaceholderPaths();
    }
  }

  /// Parse SVG string and extract all path elements
  static List<SvgPathData> _parseSvgString(String svgString) {
    final paths = <SvgPathData>[];
    final seenIds = <String>{};
    
    // Remove comments first
    final cleanSvg = svgString.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    
    // Find all path tags - match complete path element
    final pathTagRegex = RegExp(r'<path\s+[^>]*>', caseSensitive: false, dotAll: true);
    final pathTags = pathTagRegex.allMatches(cleanSvg);
    
    debugPrint('Found ${pathTags.length} path tags in SVG');
    
    for (final tagMatch in pathTags) {
      final tag = tagMatch.group(0) ?? '';
      
      // Extract id attribute - must be standalone word 'id'
      // Use lookbehind/lookahead to ensure 'id' is not part of another word
      final idRegex = RegExp(r'(?:^|\s)id\s*=\s*"([^"]+)"', caseSensitive: false);
      final idMatch = idRegex.firstMatch(tag);
      
      // Extract d attribute - must be standalone word 'd'  
      final dRegex = RegExp(r'(?:^|\s)d\s*=\s*"([^"]+)"', caseSensitive: false);
      final dMatch = dRegex.firstMatch(tag);
      
      if (idMatch != null && dMatch != null) {
        final id = idMatch.group(1)?.trim() ?? '';
        final d = dMatch.group(1)?.trim() ?? '';
        
        // Validate: d should start with path command, not be an id value
        final isValidPath = d.isNotEmpty && 
            d.length > 5 && // Path data should be longer than just an id
            (d[0] == 'M' || d[0] == 'm' || 
             d[0] == 'L' || d[0] == 'l' ||
             d[0] == 'Q' || d[0] == 'q' ||
             d[0] == 'C' || d[0] == 'c' ||
             d[0] == 'Z' || d[0] == 'z');
        
        if (id.isNotEmpty && isValidPath && !seenIds.contains(id)) {
          seenIds.add(id);
          try {
            // Parse SVG path data to Flutter Path using path_drawing
            final path = parseSvgPathData(d);
            final bounds = path.getBounds();
            
            paths.add(
              SvgPathData(
                id: id,
                path: path,
                bounds: bounds,
              ),
            );
          } catch (e) {
            debugPrint('Error parsing path id="$id": $e');
            debugPrint('d attribute (first 100 chars): ${d.substring(0, d.length > 100 ? 100 : d.length)}');
            // Skip invalid paths
          }
        } else {
          if (!isValidPath && d.isNotEmpty) {
            debugPrint('Skipping path id="$id" - invalid d: starts with "${d[0]}" (length: ${d.length})');
          }
        }
      } else {
        if (idMatch == null) debugPrint('No id found in tag: ${tag.substring(0, tag.length > 100 ? 100 : tag.length)}');
        if (dMatch == null) debugPrint('No d attribute found in tag: ${tag.substring(0, tag.length > 100 ? 100 : tag.length)}');
      }
    }
    
    debugPrint('Successfully parsed ${paths.length} paths from SVG');
    
    // If no paths found, return placeholder
    if (paths.isEmpty) {
      debugPrint('No paths found in SVG, using placeholder');
      debugPrint('SVG preview: ${cleanSvg.substring(0, cleanSvg.length > 200 ? 200 : cleanSvg.length)}...');
      return _createPlaceholderPaths();
    }
    
    return paths;
  }

  /// Create placeholder paths for testing
  static List<SvgPathData> _createPlaceholderPaths() {
    final paths = <SvgPathData>[];
    
    // Create a simple rectangle path as placeholder
    final path = Path()
      ..moveTo(50, 50)
      ..lineTo(200, 50)
      ..lineTo(200, 200)
      ..lineTo(50, 200)
      ..close();
    
    paths.add(
      SvgPathData(
        id: 'path_0',
        path: path,
        bounds: path.getBounds(),
      ),
    );
    
    return paths;
  }

  /// Create a simplified SVG string from paths with fills
  static String createSvgWithFills(
    List<SvgPathData> paths,
    Size canvasSize,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('<svg width="${canvasSize.width}" height="${canvasSize.height}" xmlns="http://www.w3.org/2000/svg">');

    for (final pathData in paths) {
      if (pathData.fillColor != null) {
        final color = pathData.fillColor!;
        // Use toARGB32 for explicit conversion instead of deprecated .value
        final hexValue = color.toARGB32().toRadixString(16).padLeft(8, '0');
        final hexColor = '#${hexValue.substring(2)}';
        buffer.writeln(
          '<path id="${pathData.id}" d="${_pathToSvgD(pathData.path)}" fill="$hexColor" stroke="none"/>',
        );
      } else {
        buffer.writeln(
          '<path id="${pathData.id}" d="${_pathToSvgD(pathData.path)}" fill="none" stroke="black" stroke-width="1"/>',
        );
      }
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  /// Convert Path to SVG d attribute
  static String _pathToSvgD(Path path) {
    // This is a simplified conversion
    // For production, use a proper path-to-SVG converter
    final pathMetrics = path.computeMetrics();
    final buffer = StringBuffer();

    for (final metric in pathMetrics) {
      for (double distance = 0.0; distance < metric.length; distance += 1.0) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          if (distance == 0.0) {
            buffer.write('M ${tangent.position.dx} ${tangent.position.dy} ');
          } else {
            buffer.write('L ${tangent.position.dx} ${tangent.position.dy} ');
          }
        }
      }
      buffer.write('Z ');
    }

    return buffer.toString();
  }
}

