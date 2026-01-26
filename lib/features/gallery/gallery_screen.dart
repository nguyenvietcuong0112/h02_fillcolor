import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../data/models/saved_artwork_model.dart';
import '../../core/theme/app_dimens.dart';
import 'gallery_viewer_screen.dart';

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

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimens.space24, AppDimens.space16, AppDimens.space24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Gallery',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Your masterpiece collection',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => ref.read(galleryControllerProvider.notifier).refresh(),
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.refresh, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimens.space24),

            // Content
            Expanded(
              child: state.isLoading
                  ? const LoadingWidget()
                  : state.error != null
                      ? ErrorDisplayWidget(
                          message: state.error!,
                          onRetry: () => ref.read(galleryControllerProvider.notifier).refresh(),
                        )
                      : state.artworks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.palette_outlined, size: 64, color: Colors.grey[300]),
                                  SizedBox(height: 16),
                                  Text(
                                    'No saved artworks yet',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Start coloring to fill this space!',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.fromLTRB(AppDimens.space24, 0, AppDimens.space24, AppDimens.space24),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppDimens.space16,
                                mainAxisSpacing: AppDimens.space24,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: state.artworks.length,
                              itemBuilder: (context, index) {
                                final artwork = state.artworks[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GalleryViewerScreen(artwork: artwork),
                                      ),
                                    );
                                  },
                                  child: _ArtworkCard(
                                    artwork: artwork,
                                    onDelete: () => _showDeleteDialog(
                                      context,
                                      ref,
                                      artwork,
                                    ),
                                    onShare: () => _shareArtwork(context, artwork),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
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
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Hero(
                    tag: artwork.filePath,
                    child: Image.file(
                      File(artwork.filePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 24, color: Colors.grey[300]),
                        );
                      },
                    ),
                  ),
                ),
                // Actions Overlay (Top Right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _ActionButton(icon: Icons.share_outlined, onTap: onShare),
                      SizedBox(width: 8),
                      _ActionButton(icon: Icons.delete_outline, onTap: onDelete, isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.space12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.imageName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${artwork.createdAt.day}/${artwork.createdAt.month}/${artwork.createdAt.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({required this.icon, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDestructive ? Colors.red[400] : Colors.black87,
        ),
      ),
    );
  }
}

