import 'dart:io';

/// Model representing a saved artwork
class SavedArtworkModel {
  final String id;
  final String filePath;
  final String imageId; // Reference to ColoringImageModel
  final String imageName;
  final DateTime createdAt;
  final int fileSize;

  const SavedArtworkModel({
    required this.id,
    required this.filePath,
    required this.imageId,
    required this.imageName,
    required this.createdAt,
    required this.fileSize,
  });

  /// Create from file path
  factory SavedArtworkModel.fromFile(String filePath, String imageId, String imageName) {
    final file = File(filePath);
    return SavedArtworkModel(
      id: filePath.split('/').last.replaceAll('.png', ''),
      filePath: filePath,
      imageId: imageId,
      imageName: imageName,
      createdAt: file.lastModifiedSync(),
      fileSize: file.lengthSync(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'imageId': imageId,
      'imageName': imageName,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
    };
  }
}

