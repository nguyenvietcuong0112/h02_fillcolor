import '../models/coloring_image_model.dart';

/// Repository for managing coloring images
class ImageRepository {
  /// Get all categories
  List<String> getCategories() {
    return ['Animals', 'Flowers', 'Mandala', 'Landscape', 'Abstract', 'Fantasy'];
  }

  /// Get images by category
  List<ColoringImageModel> getImagesByCategory(String category) {
    // In production, this would fetch from a database or API
    // For now, return sample data
    return _sampleImages.where((img) => img.category == category).toList();
  }

  /// Get all images
  List<ColoringImageModel> getAllImages() {
    return _sampleImages;
  }

  /// Get image by ID
  ColoringImageModel? getImageById(String id) {
    try {
      return _sampleImages.firstWhere((img) => img.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sample images data
  /// 
  /// Để thêm image mới:
  /// 1. Tạo file SVG trong thư mục assets/svgs/[category]/
  /// 2. Thêm ColoringImageModel vào list _sampleImages bên dưới
  /// 3. Đảm bảo id là unique
  /// 4. ThumbnailPath có thể là placeholder, app sẽ hiển thị icon mặc định nếu không có
  static final List<ColoringImageModel> _sampleImages = [
    // ========== ANIMALS ==========
    ColoringImageModel(
      id: 'animal_1',
      name: 'Cat',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/cat.svg',
      thumbnailPath: 'assets/images/thumbnails/cat.png',
      difficulty: 4, // Updated - now has 30+ paths
    ),
    ColoringImageModel(
      id: 'animal_2',
      name: 'Dog',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/dog.svg',
      thumbnailPath: 'assets/images/thumbnails/dog.png',
      difficulty: 4, // Updated - now has 35+ paths
    ),
    ColoringImageModel(
      id: 'animal_3',
      name: 'Lion',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/lion.svg',
      thumbnailPath: 'assets/images/thumbnails/lion.png',
      difficulty: 5, // Updated - now has 35+ paths with mane details
    ),
    
    // ========== FLOWERS ==========
    ColoringImageModel(
      id: 'flower_1',
      name: 'Rose',
      category: 'Flowers',
      svgPath: 'assets/svgs/flowers/rose.svg',
      thumbnailPath: 'assets/images/thumbnails/rose.png',
      difficulty: 4, // Updated - now has 25+ paths
    ),
    ColoringImageModel(
      id: 'flower_2',
      name: 'Sunflower',
      category: 'Flowers',
      svgPath: 'assets/svgs/flowers/sunflower.svg',
      thumbnailPath: 'assets/images/thumbnails/sunflower.png',
      difficulty: 2,
    ),
    
    // ========== MANDALA ==========
    ColoringImageModel(
      id: 'mandala_1',
      name: 'Simple Mandala',
      category: 'Mandala',
      svgPath: 'assets/svgs/mandala/simple.svg',
      thumbnailPath: 'assets/images/thumbnails/mandala_simple.png',
      difficulty: 4, // Updated - now has 30+ paths
    ),
    ColoringImageModel(
      id: 'mandala_2',
      name: 'Complex Mandala',
      category: 'Mandala',
      svgPath: 'assets/svgs/mandala/complex.svg',
      thumbnailPath: 'assets/images/thumbnails/mandala_complex.png',
      difficulty: 5, // Updated - now has 40+ paths with intricate patterns
    ),
    
    // ========== TEST EXAMPLES - Bạn có thể xóa hoặc thay thế ==========
    ColoringImageModel(
      id: 'animal_4',
      name: 'Bird',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/bird.svg',
      thumbnailPath: 'assets/images/thumbnails/bird.png',
      difficulty: 2,
    ),
    ColoringImageModel(
      id: 'flower_3',
      name: 'Tulip',
      category: 'Flowers',
      svgPath: 'assets/svgs/flowers/tulip.svg',
      thumbnailPath: 'assets/images/thumbnails/tulip.png',
      difficulty: 2,
    ),
    ColoringImageModel(
      id: 'flower_4',
      name: 'Cherry Blossom',
      category: 'Flowers',
      svgPath: 'assets/svgs/flowers/cherry_blossom.svg',
      thumbnailPath: 'assets/images/thumbnails/cherry_blossom.png',
      difficulty: 5, // Complex with many flowers and branches
    ),
    
    // ========== NEW COMPLEX ANIMALS ==========
    ColoringImageModel(
      id: 'animal_5',
      name: 'Butterfly',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/butterfly.svg',
      thumbnailPath: 'assets/images/thumbnails/butterfly.png',
      difficulty: 5, // Complex with detailed wing patterns
    ),
    ColoringImageModel(
      id: 'animal_6',
      name: 'Peacock',
      category: 'Animals',
      svgPath: 'assets/svgs/animals/peacock.svg',
      thumbnailPath: 'assets/images/thumbnails/peacock.png',
      difficulty: 5, // Very complex with ornate tail feathers
    ),
    
    // ========== NEW COMPLEX MANDALA ==========
    ColoringImageModel(
      id: 'mandala_3',
      name: 'Ornate Mandala',
      category: 'Mandala',
      svgPath: 'assets/svgs/mandala/ornate.svg',
      thumbnailPath: 'assets/images/thumbnails/ornate_mandala.png',
      difficulty: 5, // Very intricate patterns
    ),
  ];
}

