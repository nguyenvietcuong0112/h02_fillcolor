import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_it/get_it.dart';
import '../../ds_ads_manager.dart';
import 'shimmer_ad_view.dart';

class NativeAdView extends StatefulWidget {
  final String factoryId;
  final double height;
  final String? id;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailed;

  const NativeAdView({
    super.key,
    this.factoryId = 'listTile',
    this.height = 300,
    this.id,
    this.onAdLoaded,
    this.onAdFailed,
  });

  @override
  State<NativeAdView> createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adManager = GetIt.instance<AdManager>();
    final adId = widget.id ?? adManager.config.getId('native_language');

    if (adId.isEmpty) {
      if (mounted) {
        setState(() {
          _isFailed = true;
        });
      }
      return;
    }

    adManager.loadNativeAd(
      factoryId: widget.factoryId,
      id: adId,
      onAdLoaded: (NativeAd ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _nativeAd = ad;
          _isLoaded = true;
          _isFailed = false;
        });
        widget.onAdLoaded?.call();
      },
      onAdFailed: (LoadAdError error) {
        debugPrint('Native ad failed to load: $error');
        if (!mounted) return;
        setState(() {
          _isFailed = true;
          _isLoaded = false;
        });
        widget.onAdFailed?.call();
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _nativeAd != null) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        child: AdWidget(ad: _nativeAd!),
      );
    }
    if (_isFailed) {
      return const SizedBox.shrink();
    }
    return ShimmerAdView(
      height: widget.height,
    );
  }
}
