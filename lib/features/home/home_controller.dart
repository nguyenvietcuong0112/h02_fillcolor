import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/image_repository.dart';
import '../../data/models/coloring_image_model.dart';
import 'home_state.dart';

/// Controller for home screen
class HomeController extends StateNotifier<HomeState> {
  final ImageRepository _imageRepository;

  HomeController(this._imageRepository)
      : super(
          HomeState(
            categories: [],
            selectedCategory: '',
            images: [],
            isLoading: true,
          ),
        ) {
    _loadData();
  }

  /// Load categories and images
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = _imageRepository.getCategories();
      final selectedCategory = categories.isNotEmpty ? categories.first : '';
      final images = _imageRepository.getImagesByCategory(selectedCategory);

      state = state.copyWith(
        categories: categories,
        selectedCategory: selectedCategory,
        images: images,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select category
  void selectCategory(String category) {
    final images = _imageRepository.getImagesByCategory(category);
    state = state.copyWith(
      selectedCategory: category,
      images: images,
    );
  }

  /// Check if image is locked (always false now - no premium)
  bool isImageLocked(ColoringImageModel image) {
    return false;
  }

  /// Refresh data
  Future<void> refresh() async {
    await _loadData();
  }
}

/// Provider for home controller
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ImageRepository());
});

