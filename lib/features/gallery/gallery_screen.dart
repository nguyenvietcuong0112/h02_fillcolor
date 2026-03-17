import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'gallery_viewer_screen.dart';

import '../../core/services/app_gallery_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_dimens.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimens.space24, AppDimens.space16, AppDimens.space24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('gallery'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    ref.tr('gallery_desc'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppDimens.space24),

            // Image grid
            Expanded(
              child: imagesAsync.when(
                data: (images) => images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_rounded, size: 80, color: Colors.blueGrey[100]),
                            const SizedBox(height: 16),
                            Text(
                              ref.tr('no_images'),
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[300],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.tr('no_images_desc'),
                              style: TextStyle(fontSize: 14, color: Colors.blueGrey[200]),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(AppDimens.space24, 0, AppDimens.space24, AppDimens.space24),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimens.space16,
                          mainAxisSpacing: AppDimens.space24,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final file = images[index];
                          return _GalleryGridItem(file: file);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('${ref.tr('error')}: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryGridItem extends StatelessWidget {
  final File file;
  const _GalleryGridItem({required this.file});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryViewerScreen(imageFile: file),
          ),
        );
      },
      child: Container(
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
          children: [
            Expanded(
              child: Hero(
                tag: file.path,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // SizedBox(height: AppDimens.space12),
            // Text(
            //   file.path.split('/').last,
            //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //     fontWeight: FontWeight.w600,
            //     color: Colors.black87,
            //   ),
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}

