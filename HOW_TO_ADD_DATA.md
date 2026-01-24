# Hướng Dẫn Thêm Dữ Liệu Mới (Coloring Images)

Tài liệu này hướng dẫn cách thêm coloring images mới vào app.

## 📁 Cấu Trúc Thư Mục

```
assets/
├── images/
│   └── thumbnails/          # Thumbnail images (PNG/JPG) - optional
└── svgs/
    ├── animals/             # SVG files cho category Animals
    ├── flowers/             # SVG files cho category Flowers
    ├── mandala/             # SVG files cho category Mandala
    ├── landscape/           # SVG files cho category Landscape
    ├── abstract/            # SVG files cho category Abstract
    └── fantasy/             # SVG files cho category Fantasy
```

## 🎨 Các Bước Thêm Image Mới

### Bước 1: Tạo File SVG

1. Tạo file SVG trong thư mục phù hợp với category:
   ```
   assets/svgs/[category]/[tên_file].svg
   ```

2. **Yêu cầu cho SVG file:**
   - Mỗi path cần có `id` unique
   - Path phải có `fill="none"` và `stroke="black"` để có thể fill màu
   - Ví dụ:
   ```xml
   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
     <path id="path_1" d="M 100 50 L 150 100 L 100 150 Z" 
           fill="none" stroke="black" stroke-width="2"/>
     <path id="path_2" d="M 50 100 L 100 100 L 150 100 Z" 
           fill="none" stroke="black" stroke-width="2"/>
   </svg>
   ```

### Bước 2: Thêm Vào ImageRepository

Mở file: `lib/data/repositories/image_repository.dart`

Thêm entry mới vào list `_sampleImages`:

```dart
ColoringImageModel(
  id: 'unique_id',                    // ID duy nhất (ví dụ: 'animal_4')
  name: 'Tên Hiển Thị',              // Tên hiển thị trong app
  category: 'Animals',                // Category (phải match với category trong getCategories())
  svgPath: 'assets/svgs/animals/your_file.svg',  // Đường dẫn đến SVG file
  thumbnailPath: 'assets/images/thumbnails/your_thumbnail.png',  // Optional
  isPremium: false,                   // true = Premium, false = Free
  difficulty: 3,                     // Độ khó: 1-5 (1=dễ, 5=khó)
),
```

### Bước 3: Thêm Category Mới (Nếu Cần)

Nếu bạn muốn thêm category mới:

1. Thêm vào method `getCategories()`:
   ```dart
   List<String> getCategories() {
     return ['Animals', 'Flowers', 'Mandala', 'YourNewCategory', ...];
   }
   ```

2. Tạo thư mục SVG tương ứng:
   ```bash
   mkdir -p assets/svgs/your_new_category
   ```

### Bước 4: Thêm Thumbnail (Optional)

Thumbnail là hình ảnh nhỏ hiển thị trong grid. Nếu không có thumbnail, app sẽ hiển thị icon mặc định.

1. Tạo file thumbnail (PNG/JPG):
   ```
   assets/images/thumbnails/your_thumbnail.png
   ```

2. Kích thước khuyến nghị: 300x300px hoặc 400x400px

## 📝 Ví Dụ Hoàn Chỉnh

### Ví dụ 1: Thêm một con chim mới

**Bước 1:** Tạo file `assets/svgs/animals/bird.svg`:
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <path id="body" d="M 100 80 Q 120 100 100 120 Q 80 100 100 80 Z" 
        fill="none" stroke="black" stroke-width="2"/>
  <path id="head" d="M 100 60 Q 110 50 120 60 Q 115 70 100 70 Q 85 70 80 60 Q 90 50 100 60 Z" 
        fill="none" stroke="black" stroke-width="2"/>
  <path id="wing" d="M 100 100 Q 85 90 80 100 Q 85 110 100 100 Z" 
        fill="none" stroke="black" stroke-width="2"/>
  <path id="beak" d="M 120 60 L 130 65 L 120 70 Z" 
        fill="none" stroke="black" stroke-width="2"/>
</svg>
```

**Bước 2:** Thêm vào `image_repository.dart`:
```dart
ColoringImageModel(
  id: 'animal_4',
  name: 'Bird',
  category: 'Animals',
  svgPath: 'assets/svgs/animals/bird.svg',
  thumbnailPath: 'assets/images/thumbnails/bird.png',
  isPremium: false,
  difficulty: 2,
),
```

### Ví dụ 2: Thêm một bông hoa tulip

**Bước 1:** Tạo file `assets/svgs/flowers/tulip.svg`

**Bước 2:** Thêm vào `image_repository.dart`:
```dart
ColoringImageModel(
  id: 'flower_3',
  name: 'Tulip',
  category: 'Flowers',
  svgPath: 'assets/svgs/flowers/tulip.svg',
  thumbnailPath: 'assets/images/thumbnails/tulip.png',
  isPremium: false,
  difficulty: 2,
),
```

## 🎯 Best Practices

1. **ID Naming Convention:**
   - Format: `[category]_[number]`
   - Ví dụ: `animal_1`, `flower_2`, `mandala_3`
   - Đảm bảo ID là unique

2. **SVG Design Tips:**
   - Mỗi vùng muốn fill màu riêng → tạo path riêng với id riêng
   - Path phải đóng (closed path) để fill hoạt động tốt
   - Sử dụng `viewBox` để scale tốt trên mọi kích thước màn hình
   - Stroke width: 1-3px là tốt nhất

3. **Difficulty Levels:**
   - 1: Rất dễ (1-3 paths)
   - 2: Dễ (4-6 paths)
   - 3: Trung bình (7-10 paths)
   - 4: Khó (11-20 paths)
   - 5: Rất khó (20+ paths)

4. **Premium vs Free:**
   - Free: Các hình đơn giản, phổ biến
   - Premium: Các hình phức tạp, độc đáo, đặc biệt

## 🔍 Kiểm Tra Sau Khi Thêm

1. Chạy app:
   ```bash
   flutter run
   ```

2. Kiểm tra:
   - Image xuất hiện trong category đúng
   - Có thể mở và coloring được
   - Fill mode hoạt động (tap vào các vùng)
   - Brush mode hoạt động

3. Nếu có lỗi:
   - Kiểm tra đường dẫn SVG file
   - Kiểm tra format SVG (phải có id cho mỗi path)
   - Kiểm tra category name phải match

## 📚 Tài Liệu Tham Khảo

- SVG Path Tutorial: https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
- Flutter SVG Package: https://pub.dev/packages/flutter_svg

## 💡 Tips

- Bạn có thể tìm SVG miễn phí tại:
  - https://www.flaticon.com/
  - https://www.svgrepo.com/
  - https://undraw.co/illustrations

- Để convert PNG/JPG sang SVG, có thể dùng:
  - Adobe Illustrator
  - Inkscape (free)
  - Online tools: Vectorizer.io

- Test SVG trước khi thêm vào app bằng cách mở file trong browser

