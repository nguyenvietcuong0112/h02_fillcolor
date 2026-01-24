# Giải Thích Chi Tiết: Cách Xử Lý SVG và Nhận Biết Các Khối

## 📋 Tổng Quan

App FillColor sử dụng **SVG (Scalable Vector Graphics)** để tạo các hình vẽ có thể tô màu. Mỗi SVG chứa nhiều **path** (đường dẫn), mỗi path là một **khối fillable** (có thể tô màu).

---

## 🔍 Bước 1: Parse SVG - Nhận Biết Các Khối

### File: `lib/features/coloring/engine/svg_parser.dart`

### Quy trình:

#### 1.1. Load SVG File
```dart
// Load SVG từ assets như một string
final String svgString = await rootBundle.loadString(assetPath);
```

**Ví dụ SVG:**
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300">
  <path id="head" d="M 150 80 Q 180 70 200 85 ... Z" fill="none" stroke="black"/>
  <path id="ear_left" d="M 120 90 L 110 60 L 130 80 Z" fill="none" stroke="black"/>
  <path id="eye_left" d="M 130 100 Q 135 95 140 100 ... Z" fill="none" stroke="black"/>
  <!-- ... nhiều path khác ... -->
</svg>
```

#### 1.2. Tìm Tất Cả Thẻ `<path>`
```dart
// Regex để tìm tất cả thẻ <path>
final pathTagRegex = RegExp(r'<path\s+[^>]*>', caseSensitive: false);
final pathTags = pathTagRegex.allMatches(cleanSvg);
```

**Kết quả:** Tìm được 30 path tags trong file `cat.svg`

#### 1.3. Trích Xuất `id` và `d` Attribute

Mỗi `<path>` có 2 thuộc tính quan trọng:
- **`id`**: Tên định danh duy nhất (ví dụ: "head", "ear_left", "eye_left")
- **`d`**: Dữ liệu đường dẫn SVG (ví dụ: "M 150 80 Q 180 70 200 85 ... Z")

```dart
// Extract id: id="head" → "head"
final idRegex = RegExp(r'(?:^|\s)id\s*=\s*"([^"]+)"');
final idMatch = idRegex.firstMatch(tag);

// Extract d: d="M 150 80 ..." → "M 150 80 ..."
final dRegex = RegExp(r'(?:^|\s)d\s*=\s*"([^"]+)"');
final dMatch = dRegex.firstMatch(tag);
```

#### 1.4. Convert SVG Path Data → Flutter Path

```dart
// Sử dụng package path_drawing để parse SVG path data
final path = parseSvgPathData(d);  // "M 150 80 Q 180 70..." → Flutter Path object
final bounds = path.getBounds();    // Tính toán bounding box
```

**Kết quả:** Mỗi path được chuyển thành một `Path` object của Flutter, có thể:
- Vẽ trên Canvas
- Kiểm tra điểm có nằm trong path không (`path.contains(point)`)
- Tính toán bounds (hình chữ nhật bao quanh)

#### 1.5. Tạo SvgPathData Objects

```dart
paths.add(
  SvgPathData(
    id: id,              // "head"
    path: path,          // Flutter Path object
    bounds: bounds,      // Rect bao quanh path
  ),
);
```

**Kết quả:** Danh sách `List<SvgPathData>` - mỗi object đại diện cho 1 khối fillable.

---

## 🗂️ Bước 2: Lưu Trữ Các Khối

### File: `lib/data/models/svg_path_data.dart`

```dart
class SvgPathData {
  final String id;        // "head", "ear_left", etc.
  final Path path;       // Flutter Path để vẽ và hit-test
  final Rect bounds;     // Bounding box để tối ưu hit-test
  Color? fillColor;      // Màu đã tô (null = chưa tô)
  
  // Kiểm tra điểm có nằm trong path không
  bool containsPoint(Offset point) {
    return path.contains(point);
  }
}
```

**Trong ColoringController:**
```dart
final Map<String, SvgPathData> _pathsMap = {};
// Key = path id ("head"), Value = SvgPathData object
```

---

## 🎯 Bước 3: Tối Ưu Hit-Test (Tìm Khối Tại Điểm Chạm)

### File: `lib/features/coloring/engine/spatial_grid.dart`

### Vấn đề:
- Nếu có 100+ paths, kiểm tra từng path (`path.contains(point)`) sẽ **chậm** (O(n))
- Cần tối ưu để tìm nhanh path tại điểm chạm

### Giải pháp: **Spatial Grid**

#### 3.1. Chia Canvas Thành Grid 32x32
```dart
class SpatialGrid {
  final int _gridWidth = 32;   // 32 cột
  final int _gridHeight = 32;  // 32 hàng
  final Map<int, List<int>> _grid = {};  // cellId → danh sách path indices
}
```

**Ví dụ:** Canvas 300x300 → mỗi cell = 9.375x9.375 pixels

#### 3.2. Build Grid Index
```dart
void _buildGrid() {
  for (int i = 0; i < _paths.length; i++) {
    final path = _paths[i];
    final pathBounds = path.bounds;
    
    // Tìm các cells mà path này overlap
    final minX = ((pathBounds.left - _bounds.left) / cellWidth).floor();
    final maxX = ((pathBounds.right - _bounds.left) / cellWidth).ceil();
    final minY = ((pathBounds.top - _bounds.top) / cellHeight).floor();
    final maxY = ((pathBounds.bottom - _bounds.top) / cellHeight).ceil();
    
    // Thêm path index vào tất cả cells overlap
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final cellId = y * _gridWidth + x;
        _grid.putIfAbsent(cellId, () => []).add(i);
      }
    }
  }
}
```

**Kết quả:** Mỗi cell chứa danh sách các paths có thể nằm trong cell đó.

#### 3.3. Tìm Path Tại Điểm (O(1) → O(k), k << n)
```dart
SvgPathData? findPathAtPoint(Offset point) {
  // 1. Tính cell chứa point
  final cellX = ((point.dx - _bounds.left) / cellWidth).floor();
  final cellY = ((point.dy - _bounds.top) / cellHeight).floor();
  final cellId = cellY * _gridWidth + cellX;
  
  // 2. Lấy candidates từ cell đó (thường chỉ 1-5 paths)
  final candidateIndices = _grid[cellId];
  
  // 3. Kiểm tra bounds trước (nhanh)
  // 4. Kiểm tra containsPoint (chính xác)
  for (final index in candidateIndices) {
    final pathData = _paths[index];
    if (pathData.bounds.contains(point) && pathData.containsPoint(point)) {
      return pathData;
    }
  }
  return null;
}
```

**Hiệu quả:**
- Thay vì kiểm tra 100 paths → chỉ kiểm tra 1-5 paths trong cell
- **Từ O(n) → O(k)** với k << n

---

## 🎨 Bước 4: Xử Lý Fill (Tap-to-Fill)

### File: `lib/features/coloring/engine/fill_engine.dart`

### Quy trình:

#### 4.1. User Tap Vào Canvas
```dart
void handleTap(Offset point) {
  // Tìm path tại điểm chạm (sử dụng SpatialGrid)
  final filledPath = _fillEngine!.fillPathAtPoint(point, state.selectedColor);
}
```

#### 4.2. FillEngine Tìm Path
```dart
SvgPathData? fillPathAtPoint(Offset point, Color color) {
  // Sử dụng SpatialGrid để tìm nhanh
  final pathData = _spatialGrid?.findPathAtPoint(point);
  
  if (pathData != null) {
    // Lưu màu cũ cho undo
    if (!_fillHistory.containsKey(pathData.id)) {
      _fillHistory[pathData.id] = pathData.fillColor ?? Colors.transparent;
    }
    
    // Đặt màu mới
    pathData.fillColor = color;
    return pathData;
  }
  return null;
}
```

#### 4.3. Update State
```dart
final newFills = _fillEngine!.getFilledPaths();
// newFills = {"head": Colors.red, "ear_left": Colors.blue, ...}
state = state.copyWith(filledPaths: newFills);
```

---

## 🖌️ Bước 5: Xử Lý Brush (Freehand Drawing)

### File: `lib/features/coloring/coloring_controller.dart`

### Quy trình:

#### 5.1. User Bắt Đầu Vẽ (Pan Start)
```dart
void handlePanStart(Offset point) {
  // Tìm và "lock" vào region tại điểm đầu tiên
  _activeBrushPath = _fillEngine?.findPathAtPoint(point);
  
  if (_activeBrushPath == null) {
    // Nếu chạm ngoài mọi region → bỏ qua
    return;
  }
  
  // Bắt đầu stroke với pathId
  _brushEngine!.addPointToStroke(
    point,
    state.selectedColor,
    state.brushSize,
    1.0,
    pathId: _activeBrushPath!.id,  // Gắn chặt với region này
  );
}
```

#### 5.2. User Kéo Tay (Pan Update)
```dart
void handlePanUpdate(Offset point) {
  // Chỉ add point nếu vẫn trong region đã lock
  if (_activeBrushPath == null) return;
  
  if (!_activeBrushPath!.containsPoint(point)) {
    // Nếu ra ngoài region → bỏ qua điểm này
    return;
  }
  
  // Add point vào stroke
  _brushEngine!.addPointToStroke(point, ...);
}
```

**Kết quả:** Stroke chỉ chứa các điểm nằm trong region đã lock.

#### 5.3. User Nhả Tay (Pan End)
```dart
void handlePanEnd() {
  _activeBrushPath = null;  // Unlock region
  _brushEngine!.completeStroke();
}
```

---

## 🖼️ Bước 6: Render (Vẽ Lên Canvas)

### File: `lib/features/coloring/widgets/coloring_canvas.dart`

### ColoringPainter Vẽ 3 Layers:

#### Layer 1: Filled Paths (Màu đã tô)
```dart
for (final pathData in svgPaths) {
  final fillColor = filledPaths[pathData.id];
  if (fillColor != null) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathData.path, paint);
  }
}
```

#### Layer 2: Path Outlines (Viền đen)
```dart
final outlinePaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.0 / scale;

for (final pathData in svgPaths) {
  canvas.drawPath(pathData.path, outlinePaint);
}
```

#### Layer 3: Brush Strokes (Nét vẽ tự do)
```dart
for (final stroke in brushStrokes) {
  final path = stroke.toPath();
  
  if (stroke.pathId != null) {
    // Tìm region tương ứng
    final region = svgPaths.firstWhere((p) => p.id == stroke.pathId);
    
    // Clip cứng theo region boundary
    canvas.save();
    canvas.clipPath(region.path);  // ← Không thể vẽ ra ngoài
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
```

**Clip Path:** Đảm bảo brush stroke **không bao giờ** vượt qua viền region, kể cả khi có điểm lệch nhẹ.

---

## 📊 Tóm Tắt Flow

```
1. SVG File (assets/svgs/cat.svg)
   ↓
2. SvgParser.parseSvg()
   → Tìm <path> tags
   → Extract id + d attributes
   → Convert d → Flutter Path
   → Tạo List<SvgPathData>
   ↓
3. FillEngine + SpatialGrid
   → Build spatial grid index
   → Map<String, SvgPathData> _pathsMap
   ↓
4. User Interaction:
   
   A. Tap (Fill Mode):
      → findPathAtPoint(point) [SpatialGrid]
      → pathData.fillColor = color
      → Update state.filledPaths
   
   B. Pan (Brush Mode):
      → handlePanStart: lock _activeBrushPath
      → handlePanUpdate: chỉ add point nếu trong _activeBrushPath
      → handlePanEnd: unlock
   ↓
5. ColoringPainter.paint()
   → Layer 1: Draw filled paths
   → Layer 2: Draw outlines
   → Layer 3: Draw brush strokes (clipped)
```

---

## 🔑 Điểm Quan Trọng

### 1. **Mỗi Path = 1 Khối Fillable**
- Mỗi `<path id="...">` trong SVG = 1 khối độc lập
- Có thể tô màu riêng biệt
- Có thể kiểm tra hit-test riêng

### 2. **Spatial Grid Tối Ưu Hit-Test**
- Chia canvas thành grid 32x32
- Chỉ kiểm tra paths trong cell chứa điểm chạm
- **Từ O(n) → O(k)** với k << n

### 3. **Brush Locked to Region**
- Khi bắt đầu vẽ, lock vào 1 region (`_activeBrushPath`)
- Chỉ add points nằm trong region đó
- Render với `canvas.clipPath()` để đảm bảo không tràn

### 4. **Layered Rendering**
- Layer 1: Fills (màu nền)
- Layer 2: Outlines (viền đen)
- Layer 3: Brush strokes (nét vẽ, có clip)

---

## 💡 Ví Dụ Cụ Thể

**SVG File: `cat.svg`**
```xml
<path id="head" d="M 150 80 Q 180 70 ... Z"/>
<path id="ear_left" d="M 120 90 L 110 60 ... Z"/>
<path id="eye_left" d="M 130 100 Q 135 95 ... Z"/>
```

**Sau khi parse:**
```dart
List<SvgPathData> = [
  SvgPathData(id: "head", path: Path(...), bounds: Rect(90, 70, 120, 60)),
  SvgPathData(id: "ear_left", path: Path(...), bounds: Rect(110, 60, 20, 30)),
  SvgPathData(id: "eye_left", path: Path(...), bounds: Rect(130, 95, 10, 10)),
  // ... 27 paths khác
]
```

**User tap tại (135, 100):**
1. SpatialGrid tìm cell chứa (135, 100)
2. Cell đó có candidates: ["head", "eye_left", "pupil_left"]
3. Kiểm tra bounds: cả 3 đều chứa điểm
4. Kiểm tra `containsPoint()`: chỉ "eye_left" chứa điểm chính xác
5. → Fill "eye_left" với màu đã chọn

**User vẽ brush trong "head":**
1. `handlePanStart(150, 100)` → lock `_activeBrushPath = "head"`
2. `handlePanUpdate(155, 105)` → trong "head" → add point
3. `handlePanUpdate(200, 200)` → ngoài "head" → bỏ qua
4. `handlePanUpdate(160, 110)` → trong "head" → add point
5. Render: stroke chỉ hiển thị trong vùng "head" (nhờ clipPath)

---

## 🎯 Kết Luận

App sử dụng:
- **SVG parsing** để nhận biết các khối từ file SVG
- **Spatial Grid** để tối ưu hit-test
- **Path clipping** để đảm bảo brush không tràn viền
- **Layered rendering** để vẽ hiệu quả

Tất cả đều được tối ưu để chạy mượt với hàng trăm khối!

