import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart' as xml;
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
  /// Sử dụng xml package để parse SVG theo best practices từ Medium articles
  /// Only parses paths within the "fill-areas" group (coloring book format)
  static List<SvgPathData> _parseSvgString(String svgString) {
    final paths = <SvgPathData>[];
    final seenIds = <String>{};
    
    try {
      // Parse SVG using xml package (theo best practices từ Medium)
      final document = xml.XmlDocument.parse(svgString);
      final root = document.rootElement;
      
      // Tìm group "fill-areas" nếu có
      xml.XmlElement? fillAreasGroup;
      for (final element in root.findAllElements('g')) {
        final id = element.getAttribute('id');
        if (id?.toLowerCase() == 'fill-areas') {
          fillAreasGroup = element;
          debugPrint('Found fill-areas group, parsing only paths within it');
          break;
        }
      }
      
      // Lấy danh sách path elements để parse
      final pathElements = fillAreasGroup != null
          ? fillAreasGroup.findAllElements('path')
          : root.findAllElements('path');
      
      debugPrint('Found ${pathElements.length} path elements in SVG');
      
      for (final pathElement in pathElements) {
        final id = pathElement.getAttribute('id')?.trim() ?? '';
        final d = pathElement.getAttribute('d')?.trim() ?? '';
        
        // Validate path data
        if (id.isEmpty || d.isEmpty) {
          continue;
        }
        
        // Validate: d should start with path command
        final isValidPath = d.isNotEmpty && 
            (d[0] == 'M' || d[0] == 'm' || 
             d[0] == 'L' || d[0] == 'l' ||
             d[0] == 'Q' || d[0] == 'q' ||
             d[0] == 'C' || d[0] == 'c' ||
             d[0] == 'Z' || d[0] == 'z' ||
             d[0] == 'H' || d[0] == 'h' ||
             d[0] == 'V' || d[0] == 'v' ||
             d[0] == 'A' || d[0] == 'a' ||
             d[0] == 'S' || d[0] == 's' ||
             d[0] == 'T' || d[0] == 't');
        
        // Only parse paths with id starting with "area_" (fill areas) or all if no fill-areas group
        final isFillArea = fillAreasGroup != null ? id.startsWith('area_') : true;
        
        if (isValidPath && !seenIds.contains(id) && isFillArea) {
          seenIds.add(id);
          try {
            // Parse SVG path data to Flutter Path using path_drawing
            final path = parseSvgPathData(d);
            final bounds = path.getBounds();
            
            // Chỉ thêm path nếu có bounds hợp lệ
            if (!bounds.isEmpty && bounds.width > 0 && bounds.height > 0) {
              paths.add(
                  SvgPathData(
                    id: id,
                    path: path,
                    bounds: bounds,
                    isLocked: false, // Default to unlocked
                  ),
              );
            } else {
              debugPrint('Skipping path id="$id" - invalid bounds: $bounds');
            }
          } catch (e) {
            debugPrint('Error parsing path id="$id": $e');
            debugPrint('d attribute (first 100 chars): ${d.length > 100 ? d.substring(0, 100) : d}');
            // Skip invalid paths
          }
        } else {
          if (!isValidPath) {
            debugPrint('Skipping path id="$id" - invalid d: starts with "${d.isNotEmpty ? d[0] : 'empty'}"');
          } else if (fillAreasGroup != null && !id.startsWith('area_')) {
            debugPrint('Skipping path id="$id" - not a fill area (should start with "area_")');
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing SVG with xml package: $e');
      debugPrint('Falling back to regex parsing...');
      // Fallback to regex if xml parsing fails
      return _parseSvgStringRegex(svgString);
    }
    
    debugPrint('Successfully parsed ${paths.length} paths from SVG');
    
    // If no paths found, return placeholder
    if (paths.isEmpty) {
      debugPrint('No paths found in SVG, using placeholder');
      return _createPlaceholderPaths();
    }
    
    return paths;
  }
  
  /// Fallback: Parse SVG using regex (for backward compatibility)
  static List<SvgPathData> _parseSvgStringRegex(String svgString) {
    final paths = <SvgPathData>[];
    final seenIds = <String>{};
    
    // Remove comments first
    final cleanSvg = svgString.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    
    // Check if SVG uses coloring book format (has fill-areas group)
    final fillAreasGroupRegex = RegExp(r'<g\s+id\s*=\s*"fill-areas"[^>]*>(.*?)</g>', caseSensitive: false, dotAll: true);
    final fillAreasMatch = fillAreasGroupRegex.firstMatch(cleanSvg);
    
    String svgContentToParse;
    if (fillAreasMatch != null) {
      svgContentToParse = fillAreasMatch.group(1) ?? '';
    } else {
      svgContentToParse = cleanSvg;
    }
    
    final pathTagRegex = RegExp(r'<path\s+[^>]*>', caseSensitive: false, dotAll: true);
    final pathTags = pathTagRegex.allMatches(svgContentToParse);
    
    for (final tagMatch in pathTags) {
      final tag = tagMatch.group(0) ?? '';
      final idRegex = RegExp(r'(?:^|\s)id\s*=\s*"([^"]+)"', caseSensitive: false);
      final dRegex = RegExp(r'(?:^|\s)d\s*=\s*"([^"]+)"', caseSensitive: false);
      final idMatch = idRegex.firstMatch(tag);
      final dMatch = dRegex.firstMatch(tag);
      
      if (idMatch != null && dMatch != null) {
        final id = idMatch.group(1)?.trim() ?? '';
        final d = dMatch.group(1)?.trim() ?? '';
        final isValidPath = d.isNotEmpty && 
            (d[0] == 'M' || d[0] == 'm' || d[0] == 'L' || d[0] == 'l' ||
             d[0] == 'Q' || d[0] == 'q' || d[0] == 'C' || d[0] == 'c' ||
             d[0] == 'Z' || d[0] == 'z');
        final isFillArea = fillAreasMatch != null ? id.startsWith('area_') : true;
        
        if (id.isNotEmpty && isValidPath && !seenIds.contains(id) && isFillArea) {
          seenIds.add(id);
          try {
            final path = parseSvgPathData(d);
            final bounds = path.getBounds();
            if (!bounds.isEmpty && bounds.width > 0 && bounds.height > 0) {
              paths.add(SvgPathData(
                id: id,
                path: path,
                bounds: bounds,
                isLocked: false,
              ));
            }
          } catch (e) {
            debugPrint('Error parsing path id="$id": $e');
          }
        }
      }
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
        isLocked: false,
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

