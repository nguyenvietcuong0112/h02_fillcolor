import '../models/saved_artwork_model.dart';
import '../../core/utils/storage_utils.dart';

/// Repository for managing saved artworks
class GalleryRepository {
  /// Get all saved artworks
  Future<List<SavedArtworkModel>> getSavedArtworks() async {
    final files = await StorageUtils.getGalleryFiles();
    return files.map((file) {
      // Extract image info from filename if possible
      final fileName = file.path.split('/').last;
      return SavedArtworkModel.fromFile(
        file.path,
        fileName.replaceAll('.png', ''),
        fileName.replaceAll('.png', ''),
      );
    }).toList();
  }

  /// Delete artwork
  Future<bool> deleteArtwork(String filePath) async {
    return await StorageUtils.deleteGalleryFile(filePath);
  }

  /// Get artwork count
  Future<int> getArtworkCount() async {
    final artworks = await getSavedArtworks();
    return artworks.length;
  }
}

