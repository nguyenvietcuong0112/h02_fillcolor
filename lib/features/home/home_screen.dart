import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/thumbnail_helper.dart';
import 'dart:io';
import 'home_controller.dart';
import '../coloring/mode_selection_screen.dart';

/// Home screen displaying categories and coloring images
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimens.space24, AppDimens.space16, AppDimens.space24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Discover',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Choose your favorite art to color',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppDimens.space24),

            // Category tabs
            state.isLoading 
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 48.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: AppDimens.space24),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected = category == state.selectedCategory;
                      return Padding(
                        padding: EdgeInsets.only(right: AppDimens.space12),
                        child: GestureDetector(
                          onTap: () {
                             ref.read(homeControllerProvider.notifier).selectCategory(category);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: AppDimens.space20, vertical: 0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black87 : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                                width: 1.5,
                              ),
                              boxShadow: isSelected 
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

            SizedBox(height: AppDimens.space24),

            // Image grid
            Expanded(
              child: state.isLoading
                ? const LoadingWidget()
                : state.error != null
                    ? ErrorDisplayWidget(
                        message: state.error!,
                        onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(AppDimens.space24, 0, AppDimens.space24, AppDimens.space24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimens.space16,
                          mainAxisSpacing: AppDimens.space24,
                          childAspectRatio: 0.75, // Taller cards
                        ),
                        itemCount: state.images.length,
                        itemBuilder: (context, index) {
                          final image = state.images[index];

                          return _ImageCard(
                            image: image,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ModeSelectionScreen(image: image),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatefulWidget {
  final dynamic image;
  final VoidCallback onTap;

  const _ImageCard({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  File? _thumbnailFile;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Temporarily disable thumbnail caching to debug
    // _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (!mounted) return;
    
    final file = await ThumbnailHelper.getCachedThumbnail(widget.image.id);
    if (file != null) {
      if (mounted) {
        setState(() {
          _thumbnailFile = file;
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateThumbnail();
      });
    }
  }

  Future<void> _generateThumbnail() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
         final image = await boundary.toImage(pixelRatio: 1.5);
         final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
         if (byteData != null) {
           final bytes = byteData.buffer.asUint8List();
           final file = await ThumbnailHelper.saveThumbnail(widget.image.id, bytes);
           if (file != null && mounted) {
             setState(() {
               _thumbnailFile = file;
             });
           }
         }
      }
    } catch (e) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), // Subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppDimens.space12), // Inner padding
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: widget.image.id,
                child: _thumbnailFile != null
                    ? Image.file(
                        _thumbnailFile!,
                        fit: BoxFit.contain,
                      )
                    : FutureBuilder(
                        future: rootBundle.load(widget.image.svgPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return RepaintBoundary(
                              key: _repaintKey,
                              child: Image.memory(
                                snapshot.data!.buffer.asUint8List(),
                                fit: BoxFit.contain,
                              ),
                            );
                          }
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                      ),
              ),
            ),
            SizedBox(height: AppDimens.space12),
            Text(
              widget.image.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

