/// Model representing a coloring image
class ColoringImageModel {
  final String id;
  final String name;
  final String category;
  final String svgPath;
  final String thumbnailPath;
  final int difficulty; // 1-5

  const ColoringImageModel({
    required this.id,
    required this.name,
    required this.category,
    required this.svgPath,
    required this.thumbnailPath,
    this.difficulty = 3,
  });

  /// Create from JSON
  factory ColoringImageModel.fromJson(Map<String, dynamic> json) {
    return ColoringImageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      svgPath: json['svgPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      difficulty: json['difficulty'] as int? ?? 3,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'svgPath': svgPath,
      'thumbnailPath': thumbnailPath,
      'difficulty': difficulty,
    };
  }
}

