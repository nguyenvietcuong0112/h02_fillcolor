import '../../data/models/coloring_image_model.dart';

/// State for home screen
class HomeState {
  final List<String> categories;
  final String selectedCategory;
  final List<ColoringImageModel> images;
  final bool isLoading;
  final String? error;

  const HomeState({
    required this.categories,
    required this.selectedCategory,
    required this.images,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<String>? categories,
    String? selectedCategory,
    List<ColoringImageModel>? images,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

