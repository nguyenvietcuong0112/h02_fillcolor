import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../core/services/app_gallery_service.dart';

/// Gallery state provider
final galleryImagesProvider = StateNotifierProvider<GalleryNotifier, AsyncValue<List<File>>>((ref) {
  return GalleryNotifier();
});

/// Gallery notifier
class GalleryNotifier extends StateNotifier<AsyncValue<List<File>>> {
  GalleryNotifier() : super(const AsyncValue.loading()) {
    loadImages();
  }

  Future<void> loadImages() async {
    state = const AsyncValue.loading();
    try {
      final images = await AppGalleryService.getAllImages();
      state = AsyncValue.data(images);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadImages();
  }
}

/// Gallery screen using Riverpod
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(galleryImagesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Gallery'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(galleryImagesProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: imagesAsync.when(
        data: (images) => images.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No images yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start coloring to save images here!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final file = images[index];
                  return _GalleryItem(file: file, ref: ref);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(galleryImagesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryItem extends StatefulWidget {
  final File file;
  final WidgetRef ref;

  const _GalleryItem({required this.file, required this.ref});

  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  bool _isDownloading = false;

  Future<void> _downloadToDevice() async {
    setState(() => _isDownloading = true);
    
    try {
      final success = await AppGalleryService.exportToDeviceGallery(widget.file);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Downloaded to device gallery!' : 'Download failed'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      await Share.shareXFiles([XFile(widget.file.path)], text: 'My colored artwork!');
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _deleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppGalleryService.deleteImage(widget.file);
      widget.ref.read(galleryImagesProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              widget.file,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download, size: 20),
                  onPressed: _isDownloading ? null : _downloadToDevice,
                  tooltip: 'Download to device',
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: _shareImage,
                  tooltip: 'Share',
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: _deleteImage,
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
