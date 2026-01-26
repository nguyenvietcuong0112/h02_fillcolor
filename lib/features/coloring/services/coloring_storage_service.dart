import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/coloring_image_model.dart';
import '../../../data/models/brush_stroke.dart';

/// Service để lưu và load data cho coloring
/// Tách riêng storage cho Fill và Brush mode
class ColoringStorageService {
  static const String _prefixFill = 'coloring_fill_';
  static const String _prefixBrush = 'coloring_brush_';

  /// Lưu fill data cho một image
  static Future<void> saveFillData(
    ColoringImageModel image,
    Map<String, Color> filledPaths,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixFill${image.id}';
      
      // Convert Map<String, Color> to JSON
      final jsonData = <String, String>{};
      for (final entry in filledPaths.entries) {
        jsonData[entry.key] = entry.value.toARGB32().toRadixString(16);
      }
      
      await prefs.setString(key, json.encode(jsonData));
    } catch (e) {
      debugPrint('Error saving fill data: $e');
    }
  }

  /// Load fill data cho một image
  static Future<Map<String, Color>> loadFillData(
    ColoringImageModel image,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixFill${image.id}';
      
      final jsonString = prefs.getString(key);
      if (jsonString == null) return {};
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final filledPaths = <String, Color>{};
      
      for (final entry in jsonData.entries) {
        final colorValue = int.parse(entry.value as String, radix: 16);
        filledPaths[entry.key] = Color(colorValue);
      }
      
      return filledPaths;
    } catch (e) {
      debugPrint('Error loading fill data: $e');
      return {};
    }
  }

  /// Xóa fill data cho một image
  static Future<void> clearFillData(ColoringImageModel image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixFill${image.id}';
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Error clearing fill data: $e');
    }
  }

  /// Lưu brush data cho một image
  static Future<void> saveBrushData(
    ColoringImageModel image,
    List<BrushStroke> brushStrokes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixBrush${image.id}';
      
      // Convert List<BrushStroke> to JSON
      final jsonData = brushStrokes.map((stroke) {
        return {
          'points': stroke.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
          'color': stroke.color.toARGB32().toRadixString(16),
          'size': stroke.size,
          'opacity': stroke.opacity,
          'pathId': stroke.pathId,
        };
      }).toList();
      
      await prefs.setString(key, json.encode(jsonData));
    } catch (e) {
      debugPrint('Error saving brush data: $e');
    }
  }

  /// Load brush data cho một image
  static Future<List<BrushStroke>> loadBrushData(
    ColoringImageModel image,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixBrush${image.id}';
      
      final jsonString = prefs.getString(key);
      if (jsonString == null) return [];
      
      final jsonData = json.decode(jsonString) as List<dynamic>;
      final brushStrokes = <BrushStroke>[];
      
      for (final item in jsonData) {
        final map = item as Map<String, dynamic>;
        final points = (map['points'] as List)
            .map((p) => Offset(
                  (p['x'] as num).toDouble(),
                  (p['y'] as num).toDouble(),
                ))
            .toList();
        final colorValue = int.parse(map['color'] as String, radix: 16);
        
        brushStrokes.add(
          BrushStroke(
            points: points,
            color: Color(colorValue),
            size: (map['size'] as num).toDouble(),
            opacity: (map['opacity'] as num? ?? 1.0).toDouble(),
            pathId: map['pathId'] as String?,
          ),
        );
      }
      
      return brushStrokes;
    } catch (e) {
      debugPrint('Error loading brush data: $e');
      return [];
    }
  }

  /// Xóa brush data cho một image
  static Future<void> clearBrushData(ColoringImageModel image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefixBrush${image.id}';
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Error clearing brush data: $e');
    }
  }

  /// Xóa tất cả data (fill + brush) cho một image
  static Future<void> clearAllData(ColoringImageModel image) async {
    await Future.wait([
      clearFillData(image),
      clearBrushData(image),
    ]);
  }
}

