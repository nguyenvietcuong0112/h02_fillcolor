import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaletteSelectionScreen extends ConsumerWidget {
  final String currentCategory;
  final Function(String, List<Color>) onCategorySelected;

  const PaletteSelectionScreen({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.blueGrey, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ref.tr('pro_swatches'),
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: AppConstants.colorPalettes.length,
        itemBuilder: (context, index) {
          final entry = AppConstants.colorPalettes.entries.elementAt(index);
          final isSelected = entry.key == currentCategory;
          
          return _PaletteCategoryItem(
            title: ref.tr(entry.key.toLowerCase()),
            colors: entry.value.map((c) => Color(c)).toList(),
            isSelected: isSelected,
            onTap: () {
              onCategorySelected(entry.key, entry.value.map((c) => Color(c)).toList());
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class _PaletteCategoryItem extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCategoryItem({
    required this.title,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? Colors.orange.withValues(alpha: 0.15) 
                : Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: isSelected ? Colors.orange[400]! : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.orange[800] : Colors.blueGrey[900],
                    letterSpacing: 0.2,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.stars_rounded, color: Colors.orange, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 14,
              runSpacing: 14,
              children: colors.map((color) {
                return Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.computeLuminance() > 0.8 
                        ? Colors.grey[200]! 
                        : Colors.transparent, 
                      width: 1
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

