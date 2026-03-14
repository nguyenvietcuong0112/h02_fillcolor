import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../ds_ads_manager.dart';

class DSAdInterstitial {
  /// Shows an interstitial ad using a key from the generic config
  static void show({
    String? key,
    String? id,
    VoidCallback? onAdClosed,
    Duration? interval,
  }) {
    final adManager = GetIt.instance<AdManager>();
    final adId = id ?? (key != null ? adManager.config.getId(key) : null);

    adManager.showInterstitialAd(
      id: adId,
      interval: interval,
      onAdClosed: onAdClosed,
    );
  }

  /// Preloads an interstitial ad
  static void load({String? key, String? id}) {
    final adManager = GetIt.instance<AdManager>();
    final adId = id ?? (key != null ? adManager.config.getId(key) : null);
    adManager.loadInterstitialAd(id: adId);
  }
}
