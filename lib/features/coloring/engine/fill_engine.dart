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
  SvgPathData? findPathAtPoint(Offset point) {
    // Prefer spatial grid when available
    if (_spatialGrid != null) {
      return _spatialGrid!.findPathAtPoint(point);
    }

    // Fallback: linear search
    for (final pathData in _paths.values) {
      if (pathData.containsPoint(point)) {
        return pathData;
      }
    }
    return null;
  }

  /// Fill a path at the given point (optimized with spatial grid)
  SvgPathData? fillPathAtPoint(Offset point, Color color) {
    // Use spatial grid for fast lookup
    final pathData = _spatialGrid?.findPathAtPoint(point);
    
    if (pathData != null) {
      // Store previous color for undo
      if (!_fillHistory.containsKey(pathData.id)) {
        _fillHistory[pathData.id] = pathData.fillColor ?? Colors.transparent;
      }

      // Update fill color
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

