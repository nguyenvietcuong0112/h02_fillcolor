# Kiến Trúc Refactor - Theo Bài Medium

## 📋 Tổng Quan

App đã được refactor theo kiến trúc từ bài viết:
**"Coloring SVG images in Flutter and why I decided to disable Impeller"** (Medium – Ruslan Tsitser)

## 🎯 Mục Tiêu Kiến Trúc

App cần:
- ✅ Load SVG từ assets
- ✅ Tách SVG thành nhiều path độc lập
- ✅ Mỗi path có fillColor và có thể tap
- ✅ Đổi màu realtime
- ✅ Zoom / pan mượt
- ✅ Không lag (tránh Impeller)

## 🧱 Cấu Trúc Tầng (Architecture)

### 1. Data Layer – SVG Parsing

**File:** `lib/features/coloring/engine/svg_parser.dart`

👉 Chỉ làm 1 việc: biến SVG → List<SvgPathData>

```dart
class SvgPathData {
  final Path path;
  Color? fillColor;
  final String id;
  final Rect bounds;
}
```

**Input:** rawSvgString  
**Output:** List<SvgPathData>

- ✅ Không UI, không gesture
- ✅ Dùng: `path_drawing` để parse SVG path data
- ✅ Package `xml` đã được thêm vào `pubspec.yaml` (sẵn sàng cho cải tiến tương lai)

### 2. Render Layer – CustomPainter

**File:** `lib/features/coloring/widgets/coloring_canvas.dart` - `ColoringPainter`

👉 Vẽ toàn bộ path trong **1 CustomPainter duy nhất**

```dart
class ColoringPainter extends CustomPainter {
  final List<SvgPathData> svgPaths;
  final Map<String, Color> filledPaths;
  final List<BrushStroke> brushStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1: Draw filled paths
    // Layer 2: Draw path outlines
    // Layer 3: Draw brush strokes
  }
}
```

**🚫 KHÔNG:**
- ❌ Nhiều CustomPaint
- ❌ Nhiều widget lồng nhau

👉 **Đây là điểm then chốt tránh lag Impeller / Skia.**

**Tối ưu shouldRepaint:**
```dart
@override
bool shouldRepaint(ColoringPainter oldDelegate) {
  // Chỉ repaint khi filledPaths hoặc brushStrokes thay đổi
  // svgPaths không đổi sau khi parse, nên không cần check
  return oldDelegate.filledPaths != filledPaths ||
      oldDelegate.brushStrokes != brushStrokes;
}
```

### 3. Interaction Layer – Hit Test

**File:** `lib/features/coloring/widgets/coloring_canvas.dart` - `ColoringCanvas`

👉 Bắt tap thủ công bằng GestureDetector + transform tọa độ

```dart
// Transform tọa độ từ screen space về SVG space
Offset _transformToSvgSpace(Offset screenPoint) {
  final matrix = _transformationController.value;
  final inverseMatrix = Matrix4.inverted(matrix);
  return inverseMatrix.transformPoint(screenPoint);
}

// Hit test
onTapDown: (details) {
  final svgPoint = _transformToSvgSpace(details.localPosition);
  widget.onTap(svgPoint); // Pass to controller
}
```

**Controller xử lý:**
```dart
void handleTap(Offset point) {
  final filledPath = _fillEngine!.fillPathAtPoint(point, state.selectedColor);
  // FillEngine sử dụng SpatialGrid để tìm path nhanh
}
```

**✔ Không dùng:**
- ❌ hitTest từng widget
- ❌ wrap từng path bằng GestureDetector

### 4. Transform Layer – Zoom & Pan

**File:** `lib/features/coloring/widgets/coloring_canvas.dart`

👉 Sử dụng **InteractiveViewer** thay vì manual gesture handling

```dart
InteractiveViewer(
  transformationController: _transformationController,
  minScale: 0.5,
  maxScale: 8.0,
  panEnabled: !widget.isBrushMode, // Disable pan in brush mode
  scaleEnabled: !widget.isBrushMode, // Disable scale in brush mode
  onInteractionStart: (details) {
    if (widget.isBrushMode && details.pointerCount == 1) {
      final svgPoint = _transformToSvgSpace(details.localFocalPoint);
      widget.onPanStart(svgPoint);
    }
  },
  // ...
)
```

**Ưu điểm:**
- ✅ Zoom/pan mượt mà, native Flutter
- ✅ Tự động xử lý multi-touch
- ✅ Transform tọa độ chính xác với `TransformationController`

### 5. Engine Config

**File:** `android/app/build.gradle.kts`

👉 Disable Impeller, ưu tiên Skia

```kotlin
flutter {
    source = "../.."
    // Disable Impeller to use Skia for better performance with complex SVG paths
    // Impeller can cause lag with many paths. Skia is more stable.
    enableImpeller = false
}
```

**File:** `lib/main.dart`

```dart
// Disable Impeller engine to use Skia for better performance with complex SVG paths
// Impeller can cause lag with many paths. Skia is more stable.
// To disable Impeller, run: flutter run --no-enable-impeller
// Or set environment variable: export FLUTTER_IMPELLER=0
```

## 🧩 Tổng Thể Luồng Hoạt Động

```
assets SVG
   ↓
SVG parser (path_drawing)
   ↓
List<SvgPathData>
   ↓
CustomPainter (1 painter duy nhất)
   ↓
InteractiveViewer (zoom/pan)
   ↓
GestureDetector → transformToSvgSpace() → path.contains()
   ↓
update color → repaint
```

## 📦 Các Thay Đổi Chính

### 1. `pubspec.yaml`
- ✅ Thêm `xml: ^6.5.0` (sẵn sàng cho cải tiến parser)

### 2. `lib/features/coloring/widgets/coloring_canvas.dart`
- ✅ Refactor `ColoringPainter`: Loại bỏ scale/offset (xử lý bởi InteractiveViewer)
- ✅ Refactor `ColoringCanvas`: Thay thế manual gesture bằng `InteractiveViewer`
- ✅ Thêm `_transformToSvgSpace()`: Transform tọa độ chính xác
- ✅ Tối ưu `shouldRepaint()`: Chỉ repaint khi cần

### 3. `android/app/build.gradle.kts`
- ✅ Thêm `enableImpeller = false` để dùng Skia

### 4. `lib/main.dart`
- ✅ Thêm comment hướng dẫn disable Impeller

## 🎯 Kết Quả

### Hiệu Năng
- ✅ **1 CustomPainter duy nhất** → Tránh lag với nhiều path
- ✅ **InteractiveViewer** → Zoom/pan mượt mà, native
- ✅ **Skia engine** → Ổn định hơn Impeller với SVG phức tạp
- ✅ **shouldRepaint tối ưu** → Chỉ repaint khi cần

### Kiến Trúc
- ✅ **Tách biệt rõ ràng**: Data → Render → Interaction → Transform
- ✅ **Dễ mở rộng**: Có thể thêm features mà không ảnh hưởng hiệu năng
- ✅ **Production-ready**: Code clean, có comment, dễ maintain

## 📝 Lưu Ý

1. **Brush Mode**: 
   - Pan và scale bị disable trong brush mode để tránh conflict với drawing
   - Sử dụng `onInteractionStart/Update/End` để handle brush strokes

2. **Hit Testing**:
   - Luôn transform tọa độ từ screen space về SVG space trước khi hit test
   - Sử dụng `SpatialGrid` trong `FillEngine` để tối ưu tìm path

3. **Impeller**:
   - Đã disable trong Android build config
   - Có thể disable khi run: `flutter run --no-enable-impeller`
   - Hoặc set env: `export FLUTTER_IMPELLER=0`

## 🔄 So Sánh Trước/Sau

### Trước:
- ❌ Manual gesture handling (scale, pan)
- ❌ Transform tọa độ thủ công, có thể sai
- ❌ Impeller enabled (có thể lag)
- ❌ shouldRepaint check nhiều thứ không cần

### Sau:
- ✅ InteractiveViewer (native, mượt)
- ✅ Transform tọa độ chính xác với Matrix4
- ✅ Impeller disabled (Skia ổn định)
- ✅ shouldRepaint tối ưu

## 🚀 Next Steps (Tùy Chọn)

1. **Refactor SVG Parser**: Sử dụng `xml` package thay vì regex (hiện tại regex vẫn hoạt động tốt)
2. **Cache Path Bounds**: Cache bounds của paths để tối ưu hit test
3. **Path Clipping Optimization**: Tối ưu clipping cho brush strokes

---

**Refactor hoàn thành!** 🎉

App hiện đã tuân theo kiến trúc bài Medium, tối ưu hiệu năng và dễ mở rộng.

