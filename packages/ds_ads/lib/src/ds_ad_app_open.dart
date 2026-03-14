import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../ds_ads_manager.dart';

class DSAdAppOpen {
  static void load({String? key, String? id}) {
    final adManager = GetIt.instance<AdManager>();
    final adId = id ?? (key != null ? adManager.config.getId(key) : null);
    adManager.loadAppOpenAd(id: adId);
  }

  static void show({String? key, String? id, VoidCallback? onAdClosed}) {
    final adManager = GetIt.instance<AdManager>();
    final adId = id ?? (key != null ? adManager.config.getId(key) : null);
    adManager.showAppOpenAd(id: adId, onAdClosed: onAdClosed);
  }
}
