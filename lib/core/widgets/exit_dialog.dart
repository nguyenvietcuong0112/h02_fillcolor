import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';

/// Exit Confirmation Dialog shown when user pops/swipes back from Main Screen
class ExitDialog extends ConsumerWidget {
  const ExitDialog({super.key});

  /// Static helper to display the exit dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const ExitDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Artistic Exit Badge Illustration
            SizedBox(
              height: 96.h,
              width: 96.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  Container(
                    width: 92.w,
                    height: 92.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B6B).withValues(alpha: 0.18),
                          const Color(0xFFFF8E53).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Middle Gradient Circle
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF8E53),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 38.sp,
                    ),
                  ),

                  // Sparkle Accent 1
                  Positioned(
                    top: 2.h,
                    right: 6.w,
                    child: Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFFFC107),
                      size: 22.sp,
                    ),
                  ),

                  // Sparkle Accent 2
                  Positioned(
                    bottom: 6.h,
                    left: 8.w,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Title
            Text(
              ref.tr('exit_dialog_title'),
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey[900],
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            // Description
            Text(
              ref.tr('exit_dialog_desc'),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blueGrey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      side: BorderSide(color: Colors.blueGrey[200]!),
                    ),
                    child: Text(
                      ref.tr('cancel'),
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Exit Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF8E53),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.r),
                        onTap: () {
                          Navigator.pop(context, true);
                          SystemNavigator.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Center(
                            child: Text(
                              ref.tr('exit'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
