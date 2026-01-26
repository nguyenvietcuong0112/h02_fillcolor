import 'package:flutter/material.dart';
import '../../../data/models/svg_path_data.dart';
import 'spatial_grid.dart';

/// Engine for handling fill operations
class FillEngine {
  final Map<String, SvgPathData> _paths;
  final Map<String, Color> _fillHistory = {};
  SpatialGrid? _spatialGrid;

  FillEngine(this._paths) {
    _buildSpatialGrid();
  }

  /// Build spatial grid for optimized hit-testing
  void _buildSpatialGrid() {
    if (_paths.isEmpty) return;
    
    // Calculate overall bounds
    Rect? overallBounds;
    for (final pathData in _paths.values) {
      overallBounds = overallBounds == null
          ? pathData.bounds
          : overallBounds.expandToInclude(pathData.bounds);
    }
    
    if (overallBounds != null) {
      // Expand bounds slightly for safety
      final expandedBounds = overallBounds.inflate(10);
      _spatialGrid = SpatialGrid(_paths.values.toList(), expandedBounds);
    }
  }

  /// Find the SVG path that contains the given point (without changing color)
  /// Returns the smallest path (innermost) if multiple paths contain the point
  /// 
  /// IMPORTANT: This only checks SVG paths, NOT brush strokes.
  /// Brush strokes are visual overlays and don't affect path detection.
  SvgPathData? findPathAtPoint(Offset point) {
    // Prefer spatial grid when available
    if (_spatialGrid != null) {
      return _spatialGrid!.findPathAtPoint(point);
    }

    // Fallback: linear search - collect all containing paths and return smallest
    final containingPaths = <SvgPathData>[];
    for (final pathData in _paths.values) {
      // Chỉ check SVG path gốc, bỏ qua brush strokes
      // Brush strokes không tạo "khối" mới, chỉ là visual overlay
      if (pathData.containsPoint(point)) {
        containingPaths.add(pathData);
      }
    }
    
    if (containingPaths.isEmpty) return null;
    if (containingPaths.length == 1) return containingPaths.first;
    
    // Sort by area (smallest first)
    containingPaths.sort((a, b) {
      final areaA = a.bounds.width * a.bounds.height;
      final areaB = b.bounds.width * b.bounds.height;
      return areaA.compareTo(areaB);
    });

    // Tìm path nhỏ nhất (innermost) - path mà point nằm trong và không có path nhỏ hơn chứa point
    // Đi từ nhỏ nhất đến lớn nhất, tìm path đầu tiên chứa point
    for (int i = 0; i < containingPaths.length; i++) {
      final candidatePath = containingPaths[i];
      final candidateCenter = candidatePath.bounds.center;
      
      // Kiểm tra xem có path nhỏ hơn nào chứa center của candidatePath không
      // Nếu có, candidatePath là nested trong path nhỏ hơn → bỏ qua
      bool isNestedInSmaller = false;
      for (int j = 0; j < i; j++) {
        final smallerPath = containingPaths[j];
        if (smallerPath.containsPoint(candidateCenter)) {
          isNestedInSmaller = true;
          break;
        }
      }
      
      // Nếu không nested trong path nhỏ hơn, đây là path innermost
      if (!isNestedInSmaller) {
        return candidatePath;
      }
    }
    
    // Fallback: trả về path nhỏ nhất
    return containingPaths.first;
  }

  /// Fill a path at the given point (optimized with spatial grid)
  /// 
  /// IMPORTANT: This only fills SVG paths, NOT brush strokes.
  /// Brush strokes are visual overlays and don't create fillable regions.
  /// Fill always works on the original SVG path, regardless of brush strokes.
  SvgPathData? fillPathAtPoint(Offset point, Color color) {
    // Use spatial grid or direct find
    // This finds the SVG path, ignoring any brush strokes
    final pathData = findPathAtPoint(point);
    
    if (pathData != null) {
      // Check if path is locked
      if (pathData.isLocked) {
        return null;
      }

      // Store previous color for undo
      if (!_fillHistory.containsKey(pathData.id)) {
        _fillHistory[pathData.id] = pathData.fillColor ?? Colors.transparent;
      }

      // Update fill color of the SVG path
      // Brush strokes don't affect this - they're just visual overlays
      pathData.fillColor = color;
      return pathData;
    }
    
    return null;
  }

  /// Get fill color for a path
  Color? getFillColor(String pathId) {
    return _paths[pathId]?.fillColor;
  }

  /// Set fill color for a path
  void setFillColor(String pathId, Color? color) {
    final pathData = _paths[pathId];
    if (pathData != null) {
      if (!_fillHistory.containsKey(pathId)) {
        _fillHistory[pathId] = pathData.fillColor ?? Colors.transparent;
      }
      pathData.fillColor = color;
    }
  }

  /// Get all filled paths
  Map<String, Color> getFilledPaths() {
    final Map<String, Color> filled = {};
    for (final entry in _paths.entries) {
      if (entry.value.fillColor != null) {
        filled[entry.key] = entry.value.fillColor!;
      }
    }
    return filled;
  }

  /// Clear all fills
  Map<String, Color> clearAllFills() {
    final Map<String, Color> previousFills = {};
    for (final entry in _paths.entries) {
      if (entry.value.fillColor != null) {
        previousFills[entry.key] = entry.value.fillColor!;
        entry.value.fillColor = null;
      }
    }
    return previousFills;
  }

  /// Get fill history for undo
  Map<String, Color> getFillHistory() {
    return Map.from(_fillHistory);
  }

  /// Clear fill history
  void clearFillHistory() {
    _fillHistory.clear();
  }

  /// Get all paths
  List<SvgPathData> getAllPaths() {
    return _paths.values.toList();
  }
}

