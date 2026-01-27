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
  /// 1. Tạo file PNG trong thư mục assets/images/
  /// 2. Thêm ColoringImageModel vào list _sampleImages bên dưới
  /// 3. Đảm bảo id là unique
  /// 4. svgPath giờ chứa đường dẫn đến PNG file
  static final List<ColoringImageModel> _sampleImages = [
    // ========== ANIMALS ==========
    ColoringImageModel(
      id: 'animal_1',
      name: 'Cat',
      category: 'Animals',
      svgPath: 'assets/images/animal_cat.png',
      thumbnailPath: 'assets/images/thumbnails/cat.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_2',
      name: 'Dog',
      category: 'Animals',
      svgPath: 'assets/images/animal_dog.png',
      thumbnailPath: 'assets/images/thumbnails/dog.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_3',
      name: 'Lion',
      category: 'Animals',
      svgPath: 'assets/images/animal_lion.png',
      thumbnailPath: 'assets/images/thumbnails/lion.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'animal_4',
      name: 'Bird',
      category: 'Animals',
      svgPath: 'assets/images/animal_bird.png',
      thumbnailPath: 'assets/images/thumbnails/bird.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_5',
      name: 'Butterfly',
      category: 'Animals',
      svgPath: 'assets/images/animal_butterfly.png',
      thumbnailPath: 'assets/images/thumbnails/butterfly.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'animal_6',
      name: 'Peacock',
      category: 'Animals',
      svgPath: 'assets/images/animal_peacock.png',
      thumbnailPath: 'assets/images/thumbnails/peacock.png',
      difficulty: 5,
    ),
    
    // ========== FLOWERS ==========
    ColoringImageModel(
      id: 'flower_1',
      name: 'Rose',
      category: 'Flowers',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual rose image
      thumbnailPath: 'assets/images/thumbnails/rose.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'flower_2',
      name: 'Sunflower',
      category: 'Flowers',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual sunflower image
      thumbnailPath: 'assets/images/thumbnails/sunflower.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'flower_3',
      name: 'Tulip',
      category: 'Flowers',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual tulip image
      thumbnailPath: 'assets/images/thumbnails/tulip.png',
      difficulty: 2,
    ),
    ColoringImageModel(
      id: 'flower_4',
      name: 'Cherry Blossom',
      category: 'Flowers',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual cherry blossom image
      thumbnailPath: 'assets/images/thumbnails/cherry_blossom.png',
      difficulty: 4,
    ),
    
    // ========== MANDALA ==========
    ColoringImageModel(
      id: 'mandala_1',
      name: 'Simple Mandala',
      category: 'Mandala',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual mandala image
      thumbnailPath: 'assets/images/thumbnails/mandala_simple.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'mandala_2',
      name: 'Complex Mandala',
      category: 'Mandala',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual mandala image
      thumbnailPath: 'assets/images/thumbnails/mandala_complex.png',
      difficulty: 5,
    ),
    ColoringImageModel(
      id: 'mandala_3',
      name: 'Ornate Mandala',
      category: 'Mandala',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual mandala image
      thumbnailPath: 'assets/images/thumbnails/ornate_mandala.png',
      difficulty: 5,
    ),
    
    // ========== LANDSCAPE ==========
    ColoringImageModel(
      id: 'landscape_1',
      name: 'Mountain Scene',
      category: 'Landscape',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual landscape image
      thumbnailPath: 'assets/images/thumbnails/mountain.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'landscape_2',
      name: 'Beach Scene',
      category: 'Landscape',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual landscape image
      thumbnailPath: 'assets/images/thumbnails/beach.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'landscape_3',
      name: 'Forest Scene',
      category: 'Landscape',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual landscape image
      thumbnailPath: 'assets/images/thumbnails/forest.png',
      difficulty: 4,
    ),
    
    // ========== ABSTRACT ==========
    ColoringImageModel(
      id: 'abstract_1',
      name: 'Geometric Patterns',
      category: 'Abstract',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual abstract image
      thumbnailPath: 'assets/images/thumbnails/geometric.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'abstract_2',
      name: 'Wave Patterns',
      category: 'Abstract',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual abstract image
      thumbnailPath: 'assets/images/thumbnails/waves.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'abstract_3',
      name: 'Spiral Patterns',
      category: 'Abstract',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual abstract image
      thumbnailPath: 'assets/images/thumbnails/spiral.png',
      difficulty: 4,
    ),
    
    // ========== FANTASY ==========
    ColoringImageModel(
      id: 'fantasy_1',
      name: 'Unicorn',
      category: 'Fantasy',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual fantasy image
      thumbnailPath: 'assets/images/thumbnails/unicorn.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'fantasy_2',
      name: 'Dragon',
      category: 'Fantasy',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual fantasy image
      thumbnailPath: 'assets/images/thumbnails/dragon.png',
      difficulty: 5,
    ),
    ColoringImageModel(
      id: 'fantasy_3',
      name: 'Castle',
      category: 'Fantasy',
      svgPath: 'assets/images/test_flower.png', // Placeholder - replace with actual fantasy image
      thumbnailPath: 'assets/images/thumbnails/castle.png',
      difficulty: 4,
    ),
  ];
}

