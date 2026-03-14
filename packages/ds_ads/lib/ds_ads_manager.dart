import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:get/get.dart';
import 'src/models/ad_config.dart';
import 'src/widgets/interstitial_loading_view.dart';

@lazySingleton
class AdManager {
  final AdConfig _config;
  final Map<String, InterstitialAd?> _interstitialAds = {};

  final Map<String, RxBool> _isInterstitialAdLoadingMap = {};
  final Map<String, DateTime> _lastShowTimeMap = {};

  AdManager(this._config);

  AdConfig get config => _config;

  bool isInterstitialAdReady({String? id}) {
    final adId = id ?? _config.interstitialId;
    if (adId.isEmpty) return false;
    return _interstitialAds[adId] != null;
  }

  bool isInterstitialAdAllowed({String? id}) {
    final adId = id ?? _config.interstitialId;
    return adId.isNotEmpty;
  }

  RxBool getInterstitialAdLoading({String? id}) {
    final adId = id ?? _config.interstitialId;
    return _isInterstitialAdLoadingMap.putIfAbsent(adId, () => false.obs);
  }

  // Legacy getter for backward compatibility
  RxBool get isInterstitialAdLoading =>
      getInterstitialAdLoading(id: _config.interstitialId);

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  // Interstitial Ad
  void loadInterstitialAd({String? id}) {
    final adId = id ?? _config.interstitialId;
    if (adId.isEmpty) return;

    final isLoading = getInterstitialAdLoading(id: adId);

    if (isLoading.value || _interstitialAds[adId] != null) return;
    isLoading.value = true;

    // Safety timeout: if ad doesn't load/fail in 10s, reset loading state
    Future.delayed(const Duration(seconds: 10), () {
      if (isLoading.value) {
        isLoading.value = false;
        debugPrint('InterstitialAd load timed out for $adId');
      }
    });

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAds[adId] = ad;
          isLoading.value = false;
          debugPrint('InterstitialAd loaded for $adId');
          _setInterstitialAdCallbacks(ad, adId);
        },
        onAdFailedToLoad: (LoadAdError err) {
          debugPrint(
              'Failed to load an interstitial ad for $adId: ${err.message}');
          isLoading.value = false;
          _interstitialAds[adId] = null;
        },
      ),
    );
  }

  void _setInterstitialAdCallbacks(InterstitialAd ad, String adId) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAds[adId] = null;
        loadInterstitialAd(id: adId); // Pre-load same unit
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError err) {
        ad.dispose();
        _interstitialAds[adId] = null;
        loadInterstitialAd(id: adId);
      },
    );
  }

  void showInterstitialAd(
      {String? id, Duration? interval, VoidCallback? onAdClosed}) async {
    final adId = id ?? _config.interstitialId;

    // Check interval
    if (interval != null && _lastShowTimeMap.containsKey(adId)) {
      final lastShow = _lastShowTimeMap[adId]!;
      if (DateTime.now().difference(lastShow) < interval) {
        debugPrint(
            'InterstitialAd skipped due to interval: $adId. Last show: $lastShow');
        onAdClosed?.call();
        return;
      }
    }

    final isLoading = getInterstitialAdLoading(id: adId);

    // If not ready and not loading, try to load it first
    if (_interstitialAds[adId] == null && !isLoading.value) {
      loadInterstitialAd(id: id);
    }

    if (_interstitialAds[adId] == null) {
      if (isLoading.value) {
        // Show loading screen and wait for ad
        Get.dialog(
          const InterstitialLoadingView(),
          barrierDismissible: false,
          useSafeArea: false,
        );

        int retryCount = 0;
        const int maxRetries = 40; // 8 seconds (40 * 200ms)
        while (_interstitialAds[adId] == null &&
            isLoading.value &&
            retryCount < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 200));
          retryCount++;
        }

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        if (_interstitialAds[adId] == null) {
          debugPrint('InterstitialAd still not ready for $adId after waiting');
          onAdClosed?.call();
          return;
        }
      } else {
        debugPrint('InterstitialAd not ready and not loading for $adId');
        onAdClosed?.call();
        return;
      }
    }

    final ad = _interstitialAds[adId]!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAds[adId] = null;
        _lastShowTimeMap[adId] = DateTime.now(); // Update last show time
        onAdClosed?.call();
        loadInterstitialAd(id: adId);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError err) {
        ad.dispose();
        _interstitialAds[adId] = null;
        onAdClosed?.call();
        loadInterstitialAd(id: adId);
      },
    );

    ad.show();
  }

  // Native Ad
  void loadNativeAd({
    required String factoryId,
    String? id,
    required Function(NativeAd) onAdLoaded,
    Function(LoadAdError)? onAdFailed,
  }) {
    final adId = id ?? '';
    if (adId.isEmpty) return;

    NativeAd(
      adUnitId: adId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('NativeAd loaded with factory: $factoryId');
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('NativeAd failed to load: $error');
          ad.dispose();
          onAdFailed?.call(error);
        },
      ),
    ).load();
  }

  // App Open Ad
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;
  DateTime? _appOpenAdLoadTime;

  void loadAppOpenAd({String? id}) {
    final adId = id ?? ''; // Fallback, usually App Open has its own unit
    if (adId.isEmpty || _isAppOpenAdLoading || _appOpenAd != null) return;

    _isAppOpenAdLoading = true;
    AppOpenAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          _appOpenAdLoadTime = DateTime.now();
          debugPrint('AppOpenAd loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _isAppOpenAdLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAppOpenAd({String? id, VoidCallback? onAdClosed}) {
    final adId = id ?? '';
    if (_appOpenAd == null) {
      loadAppOpenAd(id: adId);
      onAdClosed?.call();
      return;
    }

    // Check if ad is expired (4 hours)
    if (_appOpenAdLoadTime != null &&
        DateTime.now().difference(_appOpenAdLoadTime!) >
            const Duration(hours: 4)) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAppOpenAd(id: adId);
      onAdClosed?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        onAdClosed?.call();
        loadAppOpenAd(id: adId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        onAdClosed?.call();
        loadAppOpenAd(id: adId);
      },
    );

    _appOpenAd!.show();
  }
}
