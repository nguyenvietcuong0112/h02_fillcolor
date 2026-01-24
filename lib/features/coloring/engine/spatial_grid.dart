import 'package:flutter/material.dart';
import '../../../data/models/svg_path_data.dart';

/// Spatial grid for optimized hit-testing
/// Divides canvas into grid cells for fast path lookup
class SpatialGrid {
  final List<SvgPathData> _paths;
  final Map<int, List<int>> _grid = {}; // cellId -> list of path indices
  final int _gridWidth;
  final int _gridHeight;
  final Rect _bounds;

  SpatialGrid(this._paths, this._bounds, {int gridSize = 32})
      : _gridWidth = gridSize,
        _gridHeight = gridSize {
    _buildGrid();
  }

  /// Build spatial grid index
  void _buildGrid() {
    _grid.clear();
    
    final cellWidth = _bounds.width / _gridWidth;
    final cellHeight = _bounds.height / _gridHeight;

    for (int i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      final pathBounds = path.bounds;

      // Find which grid cells this path overlaps
      final minX = ((pathBounds.left - _bounds.left) / cellWidth).floor();
      final maxX = ((pathBounds.right - _bounds.left) / cellWidth).ceil();
      final minY = ((pathBounds.top - _bounds.top) / cellHeight).floor();
      final maxY = ((pathBounds.bottom - _bounds.top) / cellHeight).ceil();

      // Add path index to all overlapping cells
      for (int y = minY.clamp(0, _gridHeight - 1); y <= maxY.clamp(0, _gridHeight - 1); y++) {
        for (int x = minX.clamp(0, _gridWidth - 1); x <= maxX.clamp(0, _gridWidth - 1); x++) {
          final cellId = y * _gridWidth + x;
          _grid.putIfAbsent(cellId, () => []).add(i);
        }
      }
    }
  }

  /// Find path at point using spatial grid
  SvgPathData? findPathAtPoint(Offset point) {
    // Check if point is within bounds
    if (!_bounds.contains(point)) return null;

    // Calculate grid cell
    final cellWidth = _bounds.width / _gridWidth;
    final cellHeight = _bounds.height / _gridHeight;
    final cellX = ((point.dx - _bounds.left) / cellWidth).floor().clamp(0, _gridWidth - 1);
    final cellY = ((point.dy - _bounds.top) / cellHeight).floor().clamp(0, _gridHeight - 1);
    final cellId = cellY * _gridWidth + cellX;

    // Get candidate paths from this cell
    final candidateIndices = _grid[cellId];
    if (candidateIndices == null || candidateIndices.isEmpty) return null;

    // Test candidates (check bounds first, then contains)
    for (final index in candidateIndices) {
      final pathData = _paths[index];
      
      // Fast bounds check
      if (!pathData.bounds.contains(point)) continue;
      
      // Precise path contains check
      if (pathData.containsPoint(point)) {
        return pathData;
      }
    }

    return null;
  }

  /// Get all paths (for rendering)
  List<SvgPathData> get paths => _paths;
}

