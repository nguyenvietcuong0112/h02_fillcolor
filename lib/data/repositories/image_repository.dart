import '../models/coloring_image_model.dart';

/// Repository for managing coloring images
class ImageRepository {
  /// Get all categories
  List<String> getCategories() {
    return [
      'Animals',
      'Sea Life',
      'Flowers',
      'Mandala',
      'Landscape',
      'Abstract',
      'Fantasy',
      'Vehicles',
      'Food',
    ];
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
      thumbnailPath: 'assets/images/animal_cat.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_2',
      name: 'Dog',
      category: 'Animals',
      svgPath: 'assets/images/animal_dog.png',
      thumbnailPath: 'assets/images/animal_dog.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_3',
      name: 'Lion',
      category: 'Animals',
      svgPath: 'assets/images/animal_lion.png',
      thumbnailPath: 'assets/images/animal_lion.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'animal_4',
      name: 'Bird',
      category: 'Animals',
      svgPath: 'assets/images/animal_bird.png',
      thumbnailPath: 'assets/images/animal_bird.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'animal_5',
      name: 'Butterfly',
      category: 'Animals',
      svgPath: 'assets/images/animal_butterfly.png',
      thumbnailPath: 'assets/images/animal_butterfly.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'animal_6',
      name: 'Elephant',
      category: 'Animals',
      svgPath: 'assets/images/animal_elephant.png',
      thumbnailPath: 'assets/images/animal_elephant.png',
      difficulty: 5,
    ),
    ColoringImageModel(
      id: 'animal_7',
      name: 'Pig',
      category: 'Animals',
      svgPath: 'assets/images/animal_pig.png',
      thumbnailPath: 'assets/images/animal_pig.png',
      difficulty: 2,
    ),
    ColoringImageModel(
      id: 'animal_tiger',
      name: 'Majestic Tiger',
      category: 'Animals',
      svgPath: 'assets/images/animal_tiger.png',
      thumbnailPath: 'assets/images/animal_tiger.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'animal_panda',
      name: 'Cute Panda',
      category: 'Animals',
      svgPath: 'assets/images/animal_panda.png',
      thumbnailPath: 'assets/images/animal_panda.png',
      difficulty: 3,
    ),

    // ========== SEA LIFE ==========
    ColoringImageModel(
      id: 'sealife_turtle',
      name: 'Sea Turtle',
      category: 'Sea Life',
      svgPath: 'assets/images/sealife_turtle.png',
      thumbnailPath: 'assets/images/sealife_turtle.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'sealife_octopus',
      name: 'Happy Octopus',
      category: 'Sea Life',
      svgPath: 'assets/images/sealife_octopus.png',
      thumbnailPath: 'assets/images/sealife_octopus.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'sealife_clownfish',
      name: 'Clownfish',
      category: 'Sea Life',
      svgPath: 'assets/images/sealife_clownfish.png',
      thumbnailPath: 'assets/images/sealife_clownfish.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'sealife_dolphin',
      name: 'Playful Dolphin',
      category: 'Sea Life',
      svgPath: 'assets/images/sealife_dolphin.png',
      thumbnailPath: 'assets/images/sealife_dolphin.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'sealife_whale',
      name: 'Blue Whale',
      category: 'Sea Life',
      svgPath: 'assets/images/sealife_whale.png',
      thumbnailPath: 'assets/images/sealife_whale.png',
      difficulty: 4,
    ),

    // ========== FLOWERS ==========
    ColoringImageModel(
      id: 'flower_rose',
      name: 'Rose',
      category: 'Flowers',
      svgPath: 'assets/images/flower_rose.png',
      thumbnailPath: 'assets/images/flower_rose.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'flower_sunflower',
      name: 'Sunflower',
      category: 'Flowers',
      svgPath: 'assets/images/flower_sunflower.png',
      thumbnailPath: 'assets/images/flower_sunflower.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'flower_tulip',
      name: 'Tulip',
      category: 'Flowers',
      svgPath: 'assets/images/flower_tulip.png',
      thumbnailPath: 'assets/images/flower_tulip.png',
      difficulty: 2,
    ),
    ColoringImageModel(
      id: 'flower_cherry',
      name: 'Cherry Blossom',
      category: 'Flowers',
      svgPath: 'assets/images/flower_cherry_blossom.png',
      thumbnailPath: 'assets/images/flower_cherry_blossom.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'flower_ly',
      name: 'Lilium',
      category: 'Flowers',
      svgPath: 'assets/images/flower_ly.png',
      thumbnailPath: 'assets/images/flower_ly.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'flower_orchid',
      name: 'Orchid Flower',
      category: 'Flowers',
      svgPath: 'assets/images/flower_orchid.png',
      thumbnailPath: 'assets/images/flower_orchid.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'flower_lotus',
      name: 'Lotus Blossom',
      category: 'Flowers',
      svgPath: 'assets/images/flower_lotus.png',
      thumbnailPath: 'assets/images/flower_lotus.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'flower_test',
      name: 'Wild Flower',
      category: 'Flowers',
      svgPath: 'assets/images/test_flower.png',
      thumbnailPath: 'assets/images/test_flower.png',
      difficulty: 2,
    ),

    // ========== MANDALA ==========
    ColoringImageModel(
      id: 'mandala_1',
      name: 'Simple Mandala',
      category: 'Mandala',
      svgPath: 'assets/images/mandala_simple.png',
      thumbnailPath: 'assets/images/mandala_simple.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'mandala_2',
      name: 'Complex Mandala',
      category: 'Mandala',
      svgPath: 'assets/images/mandala_complex.png',
      thumbnailPath: 'assets/images/mandala_complex.png',
      difficulty: 5,
    ),
    ColoringImageModel(
      id: 'mandala_3',
      name: 'Ornate Mandala',
      category: 'Mandala',
      svgPath:
          'assets/images/mandala_ornade.png', // Placeholder - replace with actual mandala image
      thumbnailPath: 'assets/images/mandala_ornade.png',
      difficulty: 5,
    ),

    // ========== LANDSCAPE ==========
    ColoringImageModel(
      id: 'landscape_mountains',
      name: 'Mountain Lake Escape',
      category: 'Landscape',
      svgPath: 'assets/images/landscape_mountains.png',
      thumbnailPath: 'assets/images/landscape_mountains.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'landscape_beach',
      name: 'Tropical Beach Sunset',
      category: 'Landscape',
      svgPath: 'assets/images/landscape_beach.png',
      thumbnailPath: 'assets/images/landscape_beach.png',
      difficulty: 3,
    ),

    // ========== ABSTRACT ==========
    ColoringImageModel(
      id: 'abstract_swirls',
      name: 'Swirling Patterns',
      category: 'Abstract',
      svgPath: 'assets/images/abstract_swirls.png',
      thumbnailPath: 'assets/images/abstract_swirls.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'abstract_waves',
      name: 'Ocean Wave Patterns',
      category: 'Abstract',
      svgPath: 'assets/images/abstract_waves.png',
      thumbnailPath: 'assets/images/abstract_waves.png',
      difficulty: 4,
    ),

    // ========== FANTASY ==========
    ColoringImageModel(
      id: 'fantasy_unicorn',
      name: 'Unicorn Garden',
      category: 'Fantasy',
      svgPath: 'assets/images/fantasy_unicorn.png',
      thumbnailPath: 'assets/images/fantasy_unicorn.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'fantasy_castle',
      name: 'Dragon Castle',
      category: 'Fantasy',
      svgPath: 'assets/images/fantasy_castle.png',
      thumbnailPath: 'assets/images/fantasy_castle.png',
      difficulty: 5,
    ),
    ColoringImageModel(
      id: 'fantasy_phoenix',
      name: 'Mystical Phoenix',
      category: 'Fantasy',
      svgPath: 'assets/images/fantasy_phoenix.png',
      thumbnailPath: 'assets/images/fantasy_phoenix.png',
      difficulty: 5,
    ),

    // ========== VEHICLES ==========
    ColoringImageModel(
      id: 'vehicle_rocket',
      name: 'Space Rocket',
      category: 'Vehicles',
      svgPath: 'assets/images/vehicle_rocket.png',
      thumbnailPath: 'assets/images/vehicle_rocket.png',
      difficulty: 4,
    ),
    ColoringImageModel(
      id: 'vehicle_car',
      name: 'Vintage Car',
      category: 'Vehicles',
      svgPath: 'assets/images/vehicle_car.png',
      thumbnailPath: 'assets/images/vehicle_car.png',
      difficulty: 3,
    ),
    ColoringImageModel(
      id: 'vehicle_ship',
      name: 'Pirate Ship',
      category: 'Vehicles',
      svgPath: 'assets/images/vehicle_ship.png',
      thumbnailPath: 'assets/images/vehicle_ship.png',
      difficulty: 4,
    ),

    // ========== FOOD ==========
    ColoringImageModel(
      id: 'food_cupcake',
      name: 'Sweet Cupcake',
      category: 'Food',
      svgPath: 'assets/images/food_cupcake.png',
      thumbnailPath: 'assets/images/food_cupcake.png',
      difficulty: 2,
    ),
  ];
}
