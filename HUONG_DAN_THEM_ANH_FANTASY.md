# Hướng dẫn thêm ảnh Fantasy

Vì AI quota đã hết, bạn có thể tự thêm ảnh fantasy theo các cách sau:

## Cách 1: Tìm ảnh line art miễn phí

### Nguồn tốt để tìm ảnh:
1. **Pixabay** (pixabay.com) - Ảnh miễn phí, không cần credit
2. **Unsplash** (unsplash.com) - Ảnh chất lượng cao
3. **Freepik** (freepik.com) - Có nhiều line art, coloring pages
4. **Coloring Pages** websites - Tìm "dragon coloring page", "unicorn coloring page"

### Từ khóa tìm kiếm:
- "dragon line art"
- "unicorn coloring page"
- "castle line drawing"
- "fantasy coloring book"

## Cách 2: Sử dụng AI tools khác

1. **DALL-E** (openai.com) - Miễn phí một số credits
2. **Bing Image Creator** (bing.com/create) - Miễn phí
3. **Leonardo.ai** - Có free tier
4. **Stable Diffusion** - Miễn phí nếu chạy local

### Prompt gợi ý:
```
Black and white line art coloring page of a [dragon/unicorn/castle], 
simple clean outlines, no shading, suitable for coloring book
```

## Cách 3: Tự vẽ hoặc thuê designer

- Fiverr.com - Thuê designer vẽ từ $5-20
- Upwork.com - Tìm freelancer
- Tự vẽ bằng Procreate, Adobe Illustrator, hoặc Inkscape (free)

## Sau khi có ảnh:

### Bước 1: Chuẩn bị ảnh
- Format: PNG
- Kích thước: Tối thiểu 1000x1000px
- Màu: Đen trắng, chỉ có đường nét đen trên nền trắng
- Tên file: `fantasy_dragon.png`, `fantasy_unicorn.png`, `fantasy_castle.png`

### Bước 2: Copy vào thư mục assets
```bash
cp your_image.png /Users/cuong/Documents/h02_colorfill/assets/images/fantasy_dragon.png
```

### Bước 3: Cập nhật image_repository.dart

Mở file `/Users/cuong/Documents/h02_colorfill/lib/data/repositories/image_repository.dart`

Tìm dòng 193-217 (phần FANTASY) và thay đổi:

```dart
// Thay vì:
svgPath: 'assets/images/test_flower.png',

// Đổi thành:
svgPath: 'assets/images/fantasy_dragon.png',
```

### Bước 4: Hot reload app
Trong terminal đang chạy flutter, nhấn `r` để reload.

## Ví dụ code hoàn chỉnh:

```dart
// ========== FANTASY ==========
ColoringImageModel(
  id: 'fantasy_dragon',
  name: 'Majestic Dragon',
  category: 'Fantasy',
  svgPath: 'assets/images/fantasy_dragon.png',
  thumbnailPath: 'assets/images/fantasy_dragon.png',
  difficulty: 5,
),
ColoringImageModel(
  id: 'fantasy_unicorn',
  name: 'Magical Unicorn',
  category: 'Fantasy',
  svgPath: 'assets/images/fantasy_unicorn.png',
  thumbnailPath: 'assets/images/fantasy_unicorn.png',
  difficulty: 4,
),
ColoringImageModel(
  id: 'fantasy_castle',
  name: 'Fairy Tale Castle',
  category: 'Fantasy',
  svgPath: 'assets/images/fantasy_castle.png',
  thumbnailPath: 'assets/images/fantasy_castle.png',
  difficulty: 4,
),
```

## Lưu ý:
- Đảm bảo ảnh có độ tương phản tốt (đường nét đen rõ ràng)
- Không có gradient hay shading
- Kích thước file không quá lớn (< 1MB mỗi ảnh)
- Test trên app trước khi deploy
