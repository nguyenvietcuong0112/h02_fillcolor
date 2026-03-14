import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_it/get_it.dart';
import '../ds_ads_manager.dart';
import 'widgets/shimmer_ad_view.dart';

class DSAdBanner extends StatefulWidget {
  final String? keyName; // Renamed from key to avoid conflict with Flutter Key
  final String? id;
  final AdSize size;

  const DSAdBanner({
    super.key,
    this.keyName,
    this.id,
    this.size = AdSize.banner,
  });

  @override
  State<DSAdBanner> createState() => _DSAdBannerState();
}

class _DSAdBannerState extends State<DSAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adManager = GetIt.instance<AdManager>();
    final adId = widget.id ??
        (widget.keyName != null ? adManager.config.getId(widget.keyName!) : '');

    if (adId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('DSAdBanner failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return ShimmerAdView(
      height: widget.size.height.toDouble(),
    );
  }
}
