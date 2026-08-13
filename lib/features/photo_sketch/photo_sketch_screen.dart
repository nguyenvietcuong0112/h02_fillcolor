import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/coloring_widgets.dart';
import 'photo_coloring_canvas_screen.dart';

class PhotoSketchScreen extends ConsumerStatefulWidget {
  const PhotoSketchScreen({super.key});

  @override
  ConsumerState<PhotoSketchScreen> createState() => _PhotoSketchScreenState();
}

class _PhotoSketchScreenState extends ConsumerState<PhotoSketchScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhotoAndNavigate(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (image == null) {
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoColoringCanvasScreen(imageBytes: bytes),
          ),
        );
        EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('photo_sketch'),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey[900],
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ref.tr('photo_sketch_desc'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Vertical Feature List Cards
              _buildVerticalActionCard(
                icon: Icons.camera_alt_rounded,
                title: ref.tr('take_photo'),
                description: ref.tr('take_photo_desc'),
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                onTap: () => _pickPhotoAndNavigate(context, ImageSource.camera),
              ),

              SizedBox(height: 18.h),

              _buildVerticalActionCard(
                icon: Icons.photo_library_rounded,
                title: ref.tr('choose_gallery'),
                description: ref.tr('choose_gallery_desc'),
                gradientColors: const [Color(0xFF4ECDC4), Color(0xFF44BBA4)],
                onTap: () => _pickPhotoAndNavigate(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalActionCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: gradientColors[0].withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
