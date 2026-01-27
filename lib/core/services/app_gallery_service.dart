import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_gallery_saver/image_gallery_saver.dart';

/// Service to manage app-specific gallery storage
class AppGalleryService {
  /// Get app gallery directory
  static Future<Directory> getGalleryDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final galleryDir = Directory(path.join(appDir.path, 'gallery'));
    
    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }
    
    return galleryDir;
  }

  /// Save image to app gallery
  static Future<File> saveToAppGallery(Uint8List imageBytes, String imageName) async {
    final galleryDir = await getGalleryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${imageName}_$timestamp.png';
    final filePath = path.join(galleryDir.path, fileName);
    
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    return file;
  }

  /// Get all images from app gallery
  static Future<List<File>> getAllImages() async {
    final galleryDir = await getGalleryDirectory();
    
    if (!await galleryDir.exists()) {
      return [];
    }
    
    final files = galleryDir.listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .toList();
    
    // Sort by modification time (newest first)
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    
    return files;
  }

  /// Delete image from app gallery
  static Future<void> deleteImage(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Export image to device gallery
  static Future<bool> exportToDeviceGallery(File file) async {
    try {
      final bytes = await file.readAsBytes();
      // Use image_gallery_saver to save to device
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: path.basenameWithoutExtension(file.path),
      );
      return result['isSuccess'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
