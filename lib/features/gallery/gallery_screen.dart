import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../data/models/saved_artwork_model.dart';

/// Gallery screen state
class GalleryState {
  final List<SavedArtworkModel> artworks;
  final bool isLoading;
  final String? error;

  const GalleryState({
    required this.artworks,
    this.isLoading = false,
    this.error,
  });

  GalleryState copyWith({
    List<SavedArtworkModel>? artworks,
    bool? isLoading,
    String? error,
  }) {
    return GalleryState(
      artworks: artworks ?? this.artworks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Gallery controller
class GalleryController extends StateNotifier<GalleryState> {
  final GalleryRepository _repository;

  GalleryController(this._repository)
      : super(
          const GalleryState(
            artworks: [],
            isLoading: true,
          ),
        ) {
    _loadArtworks();
  }

  Future<void> _loadArtworks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final artworks = await _repository.getSavedArtworks();
      state = state.copyWith(
        artworks: artworks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteArtwork(String filePath) async {
    try {
      final success = await _repository.deleteArtwork(filePath);
      if (success) {
        await _loadArtworks();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    await _loadArtworks();
  }
}

/// Provider for gallery controller
final galleryControllerProvider = StateNotifierProvider<GalleryController, GalleryState>((ref) {
  return GalleryController(GalleryRepository());
});

/// Gallery screen
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(galleryControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? ErrorDisplayWidget(
                  message: state.error!,
                  onRetry: () => ref.read(galleryControllerProvider.notifier).refresh(),
                )
              : state.artworks.isEmpty
                  ? const Center(
                      child: Text('No saved artworks yet. Start coloring to save your masterpieces!'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.artworks.length,
                      itemBuilder: (context, index) {
                        final artwork = state.artworks[index];
                        return _ArtworkCard(
                          artwork: artwork,
                          onDelete: () => _showDeleteDialog(
                            context,
                            ref,
                            artwork,
                          ),
                          onShare: () => _shareArtwork(context, artwork),
                        );
                      },
                    ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, SavedArtworkModel artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: const Text('Are you sure you want to delete this artwork?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(galleryControllerProvider.notifier).deleteArtwork(artwork.filePath);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareArtwork(BuildContext context, SavedArtworkModel artwork) async {
    try {
      await Share.shareXFiles([XFile(artwork.filePath)], text: 'Check out my coloring!');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing artwork: $e')),
        );
      }
    }
  }
}

/// Artwork card widget
class _ArtworkCard extends StatelessWidget {
  final SavedArtworkModel artwork;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _ArtworkCard({
    required this.artwork,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image placeholder
          Container(
            color: Colors.grey[200],
            child: Image.file(
              File(artwork.filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 48),
                );
              },
            ),
          ),
          // Actions overlay
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: onShare,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.imageName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${artwork.createdAt.day}/${artwork.createdAt.month}/${artwork.createdAt.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

