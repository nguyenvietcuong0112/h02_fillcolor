import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Keep AppConstants import for when ads are re-enabled
// ignore: unused_import
import '../core/constants/app_constants.dart';

/// Service for managing AdMob ads
class AdsService {
  static AdsService? _instance;
  static AdsService get instance => _instance ??= AdsService._();

  AdsService._();

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;

  /// Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;

    // Load app open ad
    _loadAppOpenAd();
  }

  /// Load app open ad
  void _loadAppOpenAd() {
    // Ads disabled - config kept but not shown
    // AppOpenAd.load(
    //   adUnitId: AppConstants.adAppOpenId,
    //   request: const AdRequest(),
    //   adLoadCallback: AppOpenAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _appOpenAd = ad;
    //       _appOpenAd!.show();
    //     },
    //     onAdFailedToLoad: (error) {
    //       // Handle error silently
    //     },
    //   ),
    // );
  }

  /// Show app open ad
  Future<void> showAppOpenAd() async {
    // Ads disabled - config kept but not shown
    // if (_appOpenAd != null) {
    //   _appOpenAd!.show();
    //   _appOpenAd = null;
    //   _loadAppOpenAd(); // Preload next ad
    // }
  }

  /// Load interstitial ad
  void loadInterstitialAd() {
    // Ads disabled - config kept but not shown
    // InterstitialAd.load(
    //   adUnitId: AppConstants.adInterstitialId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _interstitialAd = ad;
    //       _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    //         onAdDismissedFullScreenContent: (ad) {
    //           ad.dispose();
    //           _interstitialAd = null;
    //           loadInterstitialAd(); // Preload next ad
    //         },
    //         onAdFailedToShowFullScreenContent: (ad, error) {
    //           ad.dispose();
    //           _interstitialAd = null;
    //         },
    //       );
    //     },
    //     onAdFailedToLoad: (error) {
    //       // Handle error silently
    //     },
    //   ),
    // );
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    // Ads disabled - config kept but not shown
    // if (_interstitialAd != null) {
    //   _interstitialAd!.show();
    // } else {
    //   // If ad not loaded, try loading it
    //   loadInterstitialAd();
    // }
  }

  /// Create native ad widget
  Widget createNativeAdWidget({
    required double height,
    required double width,
  }) {
    // Ads disabled - config kept but not shown
    // Return empty widget instead of ad
    return const SizedBox.shrink();
    
    // Original code (commented out):
    // return SizedBox(
    //   height: height,
    //   width: width,
    //   child: AdWidget(
    //     ad: NativeAd(
    //       adUnitId: AppConstants.adNativeId,
    //       request: const AdRequest(),
    //       listener: NativeAdListener(
    //         onAdLoaded: (_) {},
    //         onAdFailedToLoad: (_, error) {},
    //       ),
    //     )..load(),
    //   ),
    // );
  }

  /// Dispose ads
  void dispose() {
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
  }
}


