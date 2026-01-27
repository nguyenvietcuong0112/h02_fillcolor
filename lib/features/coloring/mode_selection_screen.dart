import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/coloring_image_model.dart';
import 'fill_coloring_screen.dart';
import 'brush_coloring_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  final ColoringImageModel image;

  const ModeSelectionScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          image.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image preview
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  image.svgPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            Text(
              'Choose Coloring Mode',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              'Select how you want to color this image',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 40.h),
            
            // Fill Mode Button
            _ModeButton(
              icon: Icons.format_paint,
              title: 'Fill Mode',
              description: 'Tap to fill enclosed regions with color',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FillColoringScreen(image: image),
                  ),
                );
              },
            ),
            
            SizedBox(height: 20.h),
            
            // Brush Mode Button
            _ModeButton(
              icon: Icons.brush,
              title: 'Brush Mode',
              description: 'Draw freely within regions',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrushColoringScreen(image: image),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 32.sp,
                  color: color,
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20.sp,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
