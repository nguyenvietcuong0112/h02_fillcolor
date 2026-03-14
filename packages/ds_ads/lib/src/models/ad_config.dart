import 'dart:io';

class PlatformAdConfig {
  final String appId;
  final String interstitialId;
  final Map<String, String> ids;

  PlatformAdConfig({
    required this.appId,
    required this.interstitialId,
    required this.ids,
  });

  String getId(String key) => ids[key] ?? '';
}

class AdConfig {
  final PlatformAdConfig android;
  final PlatformAdConfig ios;
  final bool isProd;

  AdConfig({
    required this.android,
    required this.ios,
    required this.isProd,
  });

  PlatformAdConfig get _current => Platform.isAndroid ? android : ios;

  String get appId => _current.appId;
  String get interstitialId => _current.interstitialId;

  String getId(String key) => _current.getId(key);

  // Helper getters for common app units (can be expanded)
  String get nativeIdLanguage => getId('native_language');
  String get nativeIdIntro1 => getId('native_intro1');
  String get nativeIdIntro3 => getId('native_intro3');
  String get interstitialIdSplash => getId('interstitial_splash');
  String get bannerIdHome => getId('banner_home');
}
