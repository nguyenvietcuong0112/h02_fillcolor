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
  /// Returns the smallest path (innermost) if multiple paths contain the point
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

    // Collect all paths that contain the point
    final containingPaths = <SvgPathData>[];
    
    for (final index in candidateIndices) {
      final pathData = _paths[index];
      
      // Fast bounds check
      if (!pathData.bounds.contains(point)) continue;
      
      // Precise path contains check
      if (pathData.containsPoint(point)) {
        containingPaths.add(pathData);
      }
    }

    // If no paths contain the point, return null
    if (containingPaths.isEmpty) return null;

    // If only one path contains the point, return it
    if (containingPaths.length == 1) return containingPaths.first;

    // If multiple paths contain the point, we need to find the "most specific" one
    // Strategy: Chọn path nhỏ nhất (innermost) mà KHÔNG nằm trong path nhỏ hơn khác
    // 
    // Logic:
    // 1. Sắp xếp theo area (nhỏ nhất trước)
    // 2. Tìm path nhỏ nhất mà point nằm trong nó
    // 3. Kiểm tra xem path này có nằm trong path nhỏ hơn khác không
    // 4. Nếu có, chọn path nhỏ hơn đó
    // 5. Nếu không, chọn path này
    
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

  /// Get all paths (for rendering)
  List<SvgPathData> get paths => _paths;
}

