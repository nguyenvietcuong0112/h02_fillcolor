import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_remote_config_service.dart';
import '../dimens/ad_dimen.dart';

class NativeAdWithClose extends StatefulWidget {
  final String factoryId;
  final String adId;
  final String? adIdName;
  final double height;

  const NativeAdWithClose({
    super.key,
    required this.factoryId,
    required this.adId,
    this.adIdName,
    this.height = AdDimen.mediumNativeHeight,
  });

  @override
  State<NativeAdWithClose> createState() => _NativeAdWithCloseState();
}

class _NativeAdWithCloseState extends State<NativeAdWithClose> {
  bool _isClosed = false;

  @override
  Widget build(BuildContext context) {
    final adIdKey = widget.adIdName ?? FirebaseRemoteConfigService.native_all;
    final isAdEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(adIdKey);

    if (_isClosed || EasyAds.instance.isPremiumUser || !isAdEnabled) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        EasyNativeAd(
          factoryId: widget.factoryId,
          adId: widget.adId,
          adIdName: widget.adIdName,
          height: widget.height,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isClosed = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
