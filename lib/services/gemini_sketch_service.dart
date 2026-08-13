import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;

import 'remote_config_service.dart';
import 'sketch_converter_service.dart';

/// Pure Gemini AI Service for converting photos to clean coloring book outline drawings
class GeminiSketchService {
  /// Convert photo to clean coloring outline using Gemini AI Vision API with Retry & Local Fallback
  static Future<Uint8List?> convertToSketchWithGemini(
    Uint8List originalBytes, {
    double detailLevel = 0.2,
    double contrast = 0.5,
    SketchStyle style = SketchStyle.pureOutline,
    String? customApiKey,
  }) async {
    final String apiKey = customApiKey ?? RemoteConfigService.instance.geminiApiKey;

    if (apiKey.isEmpty) {
      debugPrint('Gemini API Key is empty -> Using local sketch engine fallback.');
      return _generateLocalSketchFallback(
        originalBytes,
        detailLevel: detailLevel,
        contrast: contrast,
      );
    }

    final String modelName = RemoteConfigService.instance.geminiModelName;
    final Uri uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final String base64Image = base64Encode(originalBytes);

    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': '''
You are a world-class professional coloring book illustrator. Analyze the attached input photo and generate a high-quality, clean vector SVG coloring book page line art.

STRICT COLORING BOOK OUTLINE SPECIFICATIONS:

1. FULLY ENCLOSED CLOSED LOOPS (CRITICAL FOR BUCKET FILL):
   - Every single shape (face, eyes, ears, hair sections, body contour, clothes, leaves, background elements) MUST form 100% fully closed, leak-proof outline boundaries.
   - Do NOT leave any open lines, broken gaps, or disconnected line segments. Every region must be a complete closed polygon loop.

2. ZERO INTERIOR NOISE & SHADING:
   - REMOVE ALL: fur grain, skin pores, wrinkles, fabric pattern noise, shadows, cross-hatching, shading lines, and background clutter.
   - Every region interior MUST be pure white (#FFFFFF) empty fillable space.

3. CRISP VECTOR LINE ARTWORK:
   - Draw bold, smooth, continuous charcoal outlines (#111827) with uniform 3.5px stroke width.
   - Maintain the recognizable core identity and silhouette of the input photo.
   - Output ONLY clean SVG vector code enclosed in <svg>...</svg> tags.
'''
            },
            {
              'inline_data': {
                'mime_type': 'image/png',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
      }
    };

    const int maxRetries = 2;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final HttpClient client = HttpClient();
        final HttpClientRequest request = await client.postUrl(uri);
        request.headers.set('content-type', 'application/json');
        request.add(utf8.encode(jsonEncode(requestBody)));

        final HttpClientResponse response = await request.close();
        final String responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(responseBody);
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']['parts'] as List?;
            if (parts != null) {
              for (final part in parts) {
                if (part is Map) {
                  // Case 1: Direct binary image data returned
                  if (part.containsKey('inline_data')) {
                    final String imgData = part['inline_data']['data'];
                    return base64Decode(imgData);
                  }

                  // Case 2: SVG vector XML code returned in text
                  if (part.containsKey('text')) {
                    final String text = part['text'].toString();
                    if (text.contains('<svg')) {
                      final Uint8List? pngBytes = await _rasterizeSvgToPng(text);
                      if (pngBytes != null) return pngBytes;
                    }
                  }
                }
              }
            }
          }
        }

        if ((response.statusCode == 503 || response.statusCode == 429) && attempt < maxRetries) {
          debugPrint('⚠️ Gemini API status ${response.statusCode} (High demand) -> retrying attempt ${attempt + 1}/$maxRetries in 1.5s...');
          await Future.delayed(const Duration(milliseconds: 1500));
          continue;
        }

        debugPrint('Gemini API call returned status ${response.statusCode}: $responseBody');
        break;
      } catch (e) {
        debugPrint('Gemini API call failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 1500));
          continue;
        }
        break;
      }
    }

    debugPrint('⚡ Gemini API unavailable (503/error) -> Generating local sketch fallback...');
    return _generateLocalSketchFallback(
      originalBytes,
      detailLevel: detailLevel,
      contrast: contrast,
    );
  }

  /// High-speed local sketch engine fallback when Gemini API is unavailable
  static Uint8List _generateLocalSketchFallback(
    Uint8List originalBytes, {
    double detailLevel = 0.2,
    double contrast = 0.5,
  }) {
    try {
      final img.Image? srcImage = img.decodeImage(originalBytes);
      if (srcImage == null) return originalBytes;

      final img.Image resized = srcImage.width > 1024
          ? img.copyResize(srcImage, width: 1024)
          : srcImage;

      final img.Image grayscale = img.grayscale(resized);
      final img.Image inverted = img.invert(grayscale.clone());

      final int blurRadius = (3 + (1.0 - detailLevel) * 6).round().clamp(1, 15);
      final img.Image blurred = img.gaussianBlur(inverted, radius: blurRadius);

      final int width = grayscale.width;
      final int height = grayscale.height;
      final img.Image sketch = img.Image(width: width, height: height);

      final double threshold = 230 - (contrast * 40);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pBase = grayscale.getPixel(x, y);
          final pBlur = blurred.getPixel(x, y);

          final gBase = pBase.r.toInt();
          final gBlur = pBlur.r.toInt();

          int dodge = gBlur == 255 ? 255 : ((gBase * 255) ~/ (255 - gBlur)).clamp(0, 255);
          final finalVal = dodge < threshold ? 0 : 255;
          sketch.setPixelRgb(x, y, finalVal, finalVal, finalVal);
        }
      }

      return Uint8List.fromList(img.encodePng(sketch));
    } catch (e) {
      debugPrint('Local sketch fallback error: $e');
      return originalBytes;
    }
  }

  /// Rasterize SVG XML text from Gemini into high quality PNG byte array
  static Future<Uint8List?> _rasterizeSvgToPng(String svgXml) async {
    try {
      const int width = 800;
      const int height = 1200;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw pure white background
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, width + 0.0, height + 0.0),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Extract all d="..." path attributes from SVG XML
      final RegExp pathRegExp = RegExp(r'd="([^"]+)"');
      final Iterable<RegExpMatch> pathMatches = pathRegExp.allMatches(svgXml);

      final Paint strokePaint = Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final match in pathMatches) {
        final String? d = match.group(1);
        if (d != null && d.isNotEmpty) {
          final Path path = _parseSvgPathData(d);
          canvas.drawPath(path, strokePaint);
        }
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width, height);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error rasterizing SVG to PNG: $e');
      return null;
    }
  }

  /// Parse SVG path data command string into a Flutter Path object
  static Path _parseSvgPathData(String svgPath) {
    final Path path = Path();
    final RegExp regExp = RegExp(r'([a-zA-Z])|([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)');
    final Iterable<RegExpMatch> matches = regExp.allMatches(svgPath);

    String currentCmd = 'M';
    final List<double> args = [];

    void executeCmd() {
      if (args.isEmpty && currentCmd.toUpperCase() != 'Z') return;
      switch (currentCmd) {
        case 'M':
          if (args.length >= 2) path.moveTo(args[0], args[1]);
          for (int i = 2; i + 1 < args.length; i += 2) {
            path.lineTo(args[i], args[i + 1]);
          }
          break;
        case 'm':
          if (args.length >= 2) path.relativeMoveTo(args[0], args[1]);
          for (int i = 2; i + 1 < args.length; i += 2) {
            path.relativeLineTo(args[i], args[i + 1]);
          }
          break;
        case 'L':
          for (int i = 0; i + 1 < args.length; i += 2) {
            path.lineTo(args[i], args[i + 1]);
          }
          break;
        case 'l':
          for (int i = 0; i + 1 < args.length; i += 2) {
            path.relativeLineTo(args[i], args[i + 1]);
          }
          break;
        case 'C':
          for (int i = 0; i + 5 < args.length; i += 6) {
            path.cubicTo(args[i], args[i + 1], args[i + 2], args[i + 3], args[i + 4], args[i + 5]);
          }
          break;
        case 'c':
          for (int i = 0; i + 5 < args.length; i += 6) {
            path.relativeCubicTo(args[i], args[i + 1], args[i + 2], args[i + 3], args[i + 4], args[i + 5]);
          }
          break;
        case 'Q':
          for (int i = 0; i + 3 < args.length; i += 4) {
            path.quadraticBezierTo(args[i], args[i + 1], args[i + 2], args[i + 3]);
          }
          break;
        case 'q':
          for (int i = 0; i + 3 < args.length; i += 4) {
            path.relativeQuadraticBezierTo(args[i], args[i + 1], args[i + 2], args[i + 3]);
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
      }
      args.clear();
    }

    for (final match in matches) {
      final String str = match.group(0)!;
      if (RegExp(r'^[a-zA-Z]$').hasMatch(str)) {
        executeCmd();
        currentCmd = str;
      } else {
        final double? val = double.tryParse(str);
        if (val != null) args.add(val);
      }
    }
    executeCmd();
    return path;
  }
}
