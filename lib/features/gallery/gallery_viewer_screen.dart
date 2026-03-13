import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/app_gallery_service.dart';
import '../../core/localization/app_localizations.dart';
import 'gallery_screen.dart';
import '../coloring/fill_coloring_screen.dart';
import '../coloring/brush_coloring_screen.dart';
import '../../data/repositories/image_repository.dart';
import '../../core/widgets/premium_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GalleryViewerScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const GalleryViewerScreen({super.key, required this.imageFile});

  @override
  ConsumerState<GalleryViewerScreen> createState() =>
      _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends ConsumerState<GalleryViewerScreen> {
  bool _isDownloading = false;

  Future<void> _downloadToDevice() async {
    setState(() => _isDownloading = true);
    try {
      final success = await AppGalleryService.exportToDeviceGallery(
        widget.imageFile,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? ref.tr('download_success') : ref.tr('download_failed'),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareImage() async {
    try {
      await Share.shareXFiles([
        XFile(widget.imageFile.path),
      ], text: 'My colored artwork!');
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _deleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          ref.tr('delete_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(ref.tr('delete_desc')),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              ref.tr('keep_it'),
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              ref.tr('delete'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppGalleryService.deleteImage(widget.imageFile);
      ref.read(galleryImagesProvider.notifier).refresh();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _editImage() async {
    final fileName = path.basenameWithoutExtension(widget.imageFile.path);
    // Format is {id}_{timestamp}
    final lastUnderscoreIndex = fileName.lastIndexOf('_');
    if (lastUnderscoreIndex == -1) return;

    final imageId = fileName.substring(0, lastUnderscoreIndex);
    final repository = ImageRepository();
    final imageModel = repository.getImageById(imageId);

    if (imageModel == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ref.tr('error'))));
      }
      return;
    }

    // Show mode selection
    final mode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              ref.tr('choose_style'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 24.h),
            _ModeListTile(
              iconWidget: PremiumFillIcon(size: 24.sp, color: Colors.blue),
              title: ref.tr('tap_to_fill'),
              subtitle: ref.tr('tap_to_fill_desc'),
              onTap: () => Navigator.pop(context, 'fill'),
            ),
            SizedBox(height: 12.h),
            _ModeListTile(
              iconWidget: PremiumBrushIcon(size: 24.sp, color: Colors.orange),
              title: ref.tr('freehand_brush'),
              subtitle: ref.tr('freehand_brush_desc'),
              onTap: () => Navigator.pop(context, 'brush'),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );

    if (mode == null || !mounted) return;

    final bool? result;
    if (mode == 'fill') {
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => FillColoringScreen(
            image: imageModel,
            savedImageFile: widget.imageFile,
          ),
        ),
      );
    } else {
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => BrushColoringScreen(
            image: imageModel,
            savedImageFile: widget.imageFile,
          ),
        ),
      );
    }

    if (result == true && mounted) {
      setState(
        () {},
      ); // Trigger rebuild to show the updated (and evicted) image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Blurred Background for Depth
          Positioned.fill(
            child: Image.file(widget.imageFile, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),

          // 2. The Image (Hero)
          Center(
            child: Hero(
              tag: widget.imageFile.path,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),
          ),

          // 3. Floating Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: _GlassActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // 4. Action Bar (Glassmorphic)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 40,
            right: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BarButton(
                        icon: Icons.edit_note_rounded,
                        label: ref.tr('edit'),
                        onTap: _editImage,
                      ),
                      _BarButton(
                        icon: Icons.file_download_outlined,
                        label: ref.tr('save'),
                        onTap: _isDownloading ? null : _downloadToDevice,
                        isLoading: _isDownloading,
                      ),
                      _BarButton(
                        icon: Icons.share_rounded,
                        label: ref.tr('share'),
                        onTap: _shareImage,
                      ),
                      _BarButton(
                        icon: Icons.delete_outline_rounded,
                        label: ref.tr('delete'),
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        onTap: _deleteImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ModeListTile extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeListTile({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(child: iconWidget),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blueGrey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.blueGrey[200],
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool isLoading;

  const _BarButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: color ?? Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: (color ?? Colors.white).withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
