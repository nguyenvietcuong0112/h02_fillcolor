import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ads/const/ad_id_name.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/firebase_remote_config_service.dart';

/// Reusable Save Success Popup Dialog used across all coloring screens
class SaveSuccessDialog extends ConsumerWidget {
  const SaveSuccessDialog({super.key});

  /// Static helper to display the save success dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const SaveSuccessDialog(),
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
            // Artistic Success Badge Illustration
            SizedBox(
              height: 96.h,
              width: 96.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Soft Glow Ring
                  Container(
                    width: 92.w,
                    height: 92.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withValues(alpha: 0.18),
                          const Color(0xFF81C784).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Middle Gradient Circle with Elevation
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF66BB6A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42.sp,
                    ),
                  ),

                  // Floating Sparkle 1 (Top Right Star)
                  Positioned(
                    top: 2.h,
                    right: 6.w,
                    child: Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFFFC107),
                      size: 22.sp,
                    ),
                  ),

                  // Floating Sparkle 2 (Bottom Left Dot)
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

                  // Floating Sparkle 3 (Top Left Small Star)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Icon(
                      Icons.star_rounded,
                      color: const Color(0xFF81C784),
                      size: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Title
            Text(
              ref.tr('save_success_title'),
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
              ref.tr('save_success_desc'),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blueGrey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Synchronized Primary Gradient Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
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
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    final navigator = Navigator.of(context, rootNavigator: true);

                    void goHome() {
                      navigator.popUntil((route) => route.isFirst);
                    }

                    final isInterEnabled =
                        FirebaseRemoteConfigService.getBoolConfigByKey(
                      FirebaseRemoteConfigService.inter_save,
                    );

                    if (isInterEnabled && !EasyAds.instance.isPremiumUser) {
                      EasyAds.instance.showInterstitialAd(
                        context,
                        adId: MyAdIdName.interAll,
                        adIdName: MyAdIdName.interAll,
                        adDissmissed: () {
                          try {
                            navigator.pop();
                          } catch (_) {}
                          goHome();
                        },
                        onFailed: () {
                          try {
                            navigator.pop();
                          } catch (_) {}
                          goHome();
                        },
                      );
                    } else {
                      try {
                        navigator.pop();
                      } catch (_) {}
                      goHome();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          ref.tr('back_to_home'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
