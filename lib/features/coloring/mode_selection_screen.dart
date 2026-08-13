import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/widgets/coloring_widgets.dart';
import '../../data/models/coloring_image_model.dart';
import 'fill_coloring_screen.dart';
import 'brush_coloring_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/premium_icons.dart';
import '../../services/firebase_remote_config_service.dart';

class ModeSelectionScreen extends ConsumerWidget {
  final ColoringImageModel image;

  const ModeSelectionScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Fixed Header (Back button & Image title)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    image.name,
                    style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body Content (excluding header and bottom ad)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Compact Image Showcase
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Container(
                                color: Colors.blueGrey[50]!.withValues(
                                  alpha: 0.3,
                                ),
                                width: double.infinity,
                                child: Hero(
                                  tag: 'image_${image.id}',
                                  child: Image.asset(
                                    image.svgPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.palette_rounded,
                                  size: 14.sp,
                                  color: Colors.blueGrey[300],
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  ref.tr('ready_to_color'),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blueGrey[300],
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Focused Titles
                    Text(
                      ref.tr('choose_style'),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey[900],
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      ref.tr('bring_to_life'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blueGrey[400],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),

                    // Mode Selection Buttons
                    _ModeButton(
                      iconWidget: PremiumFillIcon(
                        size: 28.sp,
                        color: const Color(0xFF4285F4),
                      ),
                      title: ref.tr('tap_to_fill'),
                      description: ref.tr('tap_to_fill_desc'),
                      color: const Color(0xFF4285F4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FillColoringScreen(image: image),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    _ModeButton(
                      iconWidget: PremiumBrushIcon(
                        size: 28.sp,
                        color: const Color(0xFFA142F4),
                      ),
                      title: ref.tr('freehand_brush'),
                      description: ref.tr('freehand_brush_desc'),
                      color: const Color(0xFFA142F4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BrushColoringScreen(image: image),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAd(),
    );
  }

  Widget? _buildBottomAd() {
    final isEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_all,
    );
    if (EasyAds.instance.isPremiumUser || !isEnabled) {
      return null;
    }
    return SafeArea(
      child: EasyNativeAd(
        factoryId: NativeFactoryId.nativeMediaSmall,
        adId: MyAdIdName.nativeAll.getId,
        adIdName: MyAdIdName.nativeAll,
        height: AdDimen.smallNativeAdHeight,
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.iconWidget,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blueGrey[500],
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: Colors.blueGrey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
