import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailHelper {
  ThumbnailHelper._();

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/thumbnails';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  static Future<File?> getCachedThumbnail(String imageId) async {
    final path = await _localPath;
    final file = File('$path/$imageId.png');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Save a PNG thumbnail bytes to local storage
  static Future<File?> saveThumbnail(String imageId, Uint8List bytes) async {
    try {
      final path = await _localPath;
      final file = File('$path/$imageId.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving thumbnail: $e');
      return null;
    }
  }

  /// Clear all cached thumbnails
  static Future<void> clearAllThumbnails() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        debugPrint('Cleared all thumbnails');
      }
    } catch (e) {
      debugPrint('Error clearing thumbnails: $e');
    }
  }
}
