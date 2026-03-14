import 'package:flutter/material.dart';
import 'widgets/native_ad_view.dart';

class DSAdNative extends StatelessWidget {
  final String factoryId;
  final double height;
  final String? keyName;
  final String? id;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailed;

  const DSAdNative({
    super.key,
    this.factoryId = 'listTile',
    this.height = 300,
    this.keyName,
    this.id,
    this.onAdLoaded,
    this.onAdFailed,
  });

  @override
  Widget build(BuildContext context) {
    return NativeAdView(
      factoryId: factoryId,
      height: height,
      id: id ?? keyName,
      onAdLoaded: onAdLoaded,
      onAdFailed: onAdFailed,
    );
  }
}
