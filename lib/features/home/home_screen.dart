import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import 'home_controller.dart';
import '../coloring/coloring_screen.dart';

/// Home screen displaying categories and coloring images
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FillColor'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? ErrorDisplayWidget(
                  message: state.error!,
                  onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
                )
              : Column(
                  children: [
                    // Category tabs with improved design
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final isSelected = category == state.selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  ref.read(homeControllerProvider.notifier).selectCategory(category);
                                }
                              },
                              selectedColor: Theme.of(context).primaryColor,
                              checkmarkColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 0 : 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Image grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: state.images.length, // Ads disabled
                        itemBuilder: (context, index) {
                          // Ads disabled - native ads removed
                          // if (index > 0 && index % 5 == 0) {
                          //   return AdsService.instance.createNativeAdWidget(
                          //     height: 200,
                          //     width: double.infinity,
                          //   );
                          // }

                          final image = state.images[index];

                          return _ImageCard(
                            image: image,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ColoringScreen(image: image),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Image card widget
class _ImageCard extends StatelessWidget {
  final dynamic image;
  final VoidCallback onTap;

  const _ImageCard({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder for image with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[100]!,
                    Colors.purple[100]!,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.palette,
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Difficulty indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < image.difficulty ? Icons.star : Icons.star_border,
                      size: 12,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
            // Name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
                child: Text(
                  image.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

