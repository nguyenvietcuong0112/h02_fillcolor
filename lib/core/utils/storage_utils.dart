import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Storage utility for local file system and preferences
class StorageUtils {
  StorageUtils._();

  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get shared preferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageUtils not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Get gallery directory
  static Future<Directory> getGalleryDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final galleryDir = Directory('${directory.path}/${AppConstants.galleryFolderName}');
    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }
    return galleryDir;
  }

  /// Save file to gallery
  static Future<File> saveToGallery(String fileName, List<int> bytes) async {
    final galleryDir = await getGalleryDirectory();
    final file = File('${galleryDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Get all gallery files
  static Future<List<File>> getGalleryFiles() async {
    final galleryDir = await getGalleryDirectory();
    if (!await galleryDir.exists()) {
      return [];
    }
    final files = galleryDir.listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Delete gallery file
  static Future<bool> deleteGalleryFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is premium
  static bool get isPremium {
    return prefs.getBool(AppConstants.keyIsPremium) ?? false;
  }

  /// Set premium status
  static Future<void> setPremium(bool value) async {
    await prefs.setBool(AppConstants.keyIsPremium, value);
  }

  /// Get save count
  static int get saveCount {
    return prefs.getInt(AppConstants.keySaveCount) ?? 0;
  }

  /// Increment save count
  static Future<void> incrementSaveCount() async {
    final count = saveCount;
    await prefs.setInt(AppConstants.keySaveCount, count + 1);
  }

  /// Reset save count
  static Future<void> resetSaveCount() async {
    await prefs.setInt(AppConstants.keySaveCount, 0);
  }
}

