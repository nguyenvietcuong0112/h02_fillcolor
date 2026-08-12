import 'dart:async';
import 'dart:typed_data';
import 'gemini_sketch_service.dart';

enum SketchStyle {
  pureOutline,     // Pure Outline Drawing (Gemini AI Vision API)
  coloringOutline, // Coloring Outline
  cartoonVector,   // Cartoon Vector Style
}

/// AI-Powered Service for converting photos into clean, leak-proof line art for coloring
class SketchConverterService {
  /// Convert image bytes to clean black-and-white line art via Gemini AI
  static Future<Uint8List?> convertToSketch(
    Uint8List imageBytes, {
    double detailLevel = 0.2,
    double contrast = 0.5,
    SketchStyle style = SketchStyle.pureOutline,
  }) async {
    return GeminiSketchService.convertToSketchWithGemini(
      imageBytes,
      detailLevel: detailLevel,
      contrast: contrast,
    );
  }
}
