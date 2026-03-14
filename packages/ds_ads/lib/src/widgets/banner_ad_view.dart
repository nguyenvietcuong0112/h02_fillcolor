import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_it/get_it.dart';
import '../../ds_ads_manager.dart';
import 'shimmer_ad_view.dart';

class BannerAdView extends StatefulWidget {
  final bool isCollapsible;
  final bool isBottom;
  final String? id;

  const BannerAdView({
    super.key,
    this.isCollapsible = false,
    this.isBottom = true,
    this.id,
  });

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get adaptive size.');
      if (mounted) {
        setState(() {
          _isFailed = true;
        });
      }
      return;
    }

    final AdManager adManager = GetIt.instance<AdManager>();
    _bannerAd = BannerAd(
      adUnitId: widget.id ?? adManager.config.bannerIdHome,
      size: size,
      request: AdRequest(
        extras: widget.isCollapsible
            ? <String, String>{
                'collapsible': widget.isBottom ? 'bottom' : 'top',
              }
            : null,
      ),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _isFailed = false;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isFailed = true;
            _isLoaded = false;
          });
        },
      ),
    );
    await _bannerAd!.load();
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
    if (_isFailed) {
      return const SizedBox.shrink();
    }
    return const ShimmerAdView(
      height: 60, // Standard adaptive banner height approximation
    );
  }
}
