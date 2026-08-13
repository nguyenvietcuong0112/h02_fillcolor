import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../app/app.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/storage_utils.dart';
import '../../services/firebase_remote_config_service.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isShouldShowNext = false;

  Timer? _adTimeoutTimer;
  StreamSubscription? _adEventSubscription;

  @override
  void initState() {
    super.initState();
    _checkAndStartAdLogic(_currentPage);
  }

  void _checkAndStartAdLogic(int pageIndex) {
    _adTimeoutTimer?.cancel();
    _adEventSubscription?.cancel();

    // Page 1 (Intro 2) has no ad or premium user
    if (pageIndex == 1 || AppConstants.isPremiumUser.value) {
      if (mounted) {
        setState(() {
          _isShouldShowNext = true;
        });
      }
      return;
    }

    // Page 0 & 2 have ads: hide Next button until ad loads/displays or 3s timeout
    if (mounted) {
      setState(() {
        _isShouldShowNext = false;
      });
    }

    // Start 3s timeout timer
    _adTimeoutTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted && !_isShouldShowNext) {
        setState(() {
          _isShouldShowNext = true;
        });
      }
    });

    final targetAdId = pageIndex == 0
        ? MyAdIdName.nativeOnboard1Ad.getId
        : MyAdIdName.nativeOnboard3Ad.getId;

    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == targetAdId) {
        if (event.type == AdEventType.adLoaded ||
            event.type == AdEventType.adFailedToLoad ||
            event.type == AdEventType.onAdImpression) {
          _onAdLoadedOrImpression();
        }
      }
    });
  }

  void _onAdLoadedOrImpression() {
    _adTimeoutTimer?.cancel();
    if (mounted && !_isShouldShowNext) {
      setState(() {
        _isShouldShowNext = true;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _checkAndStartAdLogic(index);
  }

  void _onNext() {
    if (!_isShouldShowNext) return;
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() async {
    await StorageUtils.setIntroSeen(true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
  }

  @override
  void dispose() {
    _adTimeoutTimer?.cancel();
    _adEventSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pages = [
      {
        'title': ref.tr('intro_1_title'),
        'desc': ref.tr('intro_1_desc'),
        'image': 'assets/images/intro_1.webp',
      },
      {
        'title': ref.tr('intro_2_title'),
        'desc': ref.tr('intro_2_desc'),
        'image': 'assets/images/intro_2.webp',
      },
      {
        'title': ref.tr('intro_3_title'),
        'desc': ref.tr('intro_3_desc'),
        'image': 'assets/images/intro_3.webp',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fullscreen Onboard Images (Fixed, never pushed up)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  pages[index]['image']!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // 2. Gradient Overlay (Transparent at top -> Gradually turns darker black towards bottom)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.9),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Controls & Ads Layer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pagination
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Text Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        key: ValueKey<int>(_currentPage),
                        children: [
                          Text(
                            pages[_currentPage]['title']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            pages[_currentPage]['desc']!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Action Button or Loading Spinner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: !_isShouldShowNext
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == pages.length - 1
                                        ? ref.tr('get_started')
                                        : ref.tr('next'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Native Ad for Intro 1 & Intro 3
                  _buildNativeAd(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeAd() {
    if (AppConstants.isPremiumUser.value || EasyAds.instance.isPremiumUser) {
      return const SizedBox.shrink();
    }
    if (_currentPage == 0) {
      final isEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_1,
      );
      if (!isEnabled) return const SizedBox.shrink();
      return EasyNativeAd(
        factoryId: NativeFactoryId.nativeMedia,
        adId: MyAdIdName.nativeOnboard1Ad.getId,
        adIdName: MyAdIdName.nativeOnboard1Ad,
        height: AdDimen.mediumNativeHeight,
        onLoaded: _onAdLoadedOrImpression,
        onImpression: _onAdLoadedOrImpression,
      );
    } else if (_currentPage == 2) {
      final isEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_3,
      );
      if (!isEnabled) return const SizedBox.shrink();
      return EasyNativeAd(
        factoryId: NativeFactoryId.nativeMedia,
        adId: MyAdIdName.nativeOnboard3Ad.getId,
        adIdName: MyAdIdName.nativeOnboard3Ad,
        height: AdDimen.mediumNativeHeight,
        onLoaded: _onAdLoadedOrImpression,
        onImpression: _onAdLoadedOrImpression,
      );
    }
    return const SizedBox.shrink();
  }
}
