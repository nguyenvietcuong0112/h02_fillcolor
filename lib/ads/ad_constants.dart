import 'package:ds_ads/ds_ads.dart';
import 'package:get_it/get_it.dart';

class AdIds {
  final String appUnitId;
  final String interstitial;
  final String? nativeLanguage;
  final String? nativeIntro1;
  final String? nativeIntro3;
  final String? nativeColoring;
  final String? interstitialSplash;
  final String? interstitialSave;
  final String? interstitialItem;
  final String? banner;

  const AdIds({
    required this.appUnitId,
    required this.interstitial,
    this.nativeLanguage,
    this.nativeIntro1,
    this.nativeIntro3,
    this.nativeColoring,
    this.interstitialSplash,
    this.interstitialSave,
    this.interstitialItem,
    this.banner,
  });

  PlatformAdConfig toPlatformConfig() {
    return PlatformAdConfig(
      appId: appUnitId,
      interstitialId: interstitial,
      ids: {
        'native_language': nativeLanguage ?? '',
        'native_intro1': nativeIntro1 ?? '',
        'native_intro3': nativeIntro3 ?? '',
        'native_coloring': nativeColoring ?? '',
        'interstitial_splash': interstitialSplash ?? interstitial,
        'interstitial_save': interstitialSave ?? interstitial,
        'interstitial_item': interstitialItem ?? interstitial,
        'banner': banner ?? '',
      },
    );
  }
}

class AdConstants {
  // ================= ANDROID IDs =================

  static const AdIds androidTest = AdIds(
    appUnitId: 'ca-app-pub-3940256099942544~3347511713',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    nativeLanguage: 'ca-app-pub-3940256099942544/2247696110',
    nativeIntro1: 'ca-app-pub-3940256099942544/2247696110',
    nativeIntro3: 'ca-app-pub-3940256099942544/2247696110',
    nativeColoring: 'ca-app-pub-3940256099942544/2247696110',
    interstitialSplash: 'ca-app-pub-3940256099942544/1033173712',
    interstitialItem: 'ca-app-pub-3940256099942544/1033173712',
    interstitialSave: 'ca-app-pub-3940256099942544/1033173712',
    banner: 'ca-app-pub-3940256099942544/6300978111',
  );
  // static const AdIds androidTest = AdIds(
  //   appUnitId: 'ca-app-pub-3940256099942544~3347511713',
  //   interstitial: '',
  //   nativeLanguage: '',
  //   nativeIntro1: '',
  //   nativeIntro3: '',
  //   nativeColoring: '',
  //   interstitialSplash: '',
  //   interstitialSave: '',
  //   interstitialItem: '',
  //   banner: '',
  // );

  static const AdIds androidProd = AdIds(
    appUnitId: 'ca-app-pub-5535645532626180~2776234620',
    interstitial: 'ca-app-pub-5535645532626180/9563082361',
    nativeLanguage: 'ca-app-pub-5535645532626180/6054114591',
    nativeIntro1: '',
    nativeIntro3: '',
    nativeColoring: 'ca-app-pub-5535645532626180/8488706242',
    interstitialSplash: 'ca-app-pub-5535645532626180/9563082361',
    interstitialSave: 'ca-app-pub-5535645532626180/7367196260',
    interstitialItem: 'ca-app-pub-5535645532626180/2717175241',
    banner: 'ca-app-pub-5535645532626180/4741032928',
  );

  // ================= IOS IDs =================

  static const AdIds iosTest = AdIds(
    appUnitId: 'ca-app-pub-3940256099942544~1458002511',
    interstitial: 'ca-app-pub-3940256099942544/4411468910',
    nativeLanguage: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro1: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro3: 'ca-app-pub-3940256099942544/3986624511',
    nativeColoring: 'ca-app-pub-3940256099942544/3986624511',
    interstitialSplash: 'ca-app-pub-3940256099942544/4411468910',
    interstitialItem: 'ca-app-pub-3940256099942544/4411468910',
    banner: 'ca-app-pub-3940256099942544/2934735716',
  );

  static const AdIds iosProd = AdIds(
    appUnitId: 'ca-app-pub-3940256099942544~1458002511',
    interstitial: 'ca-app-pub-3940256099942544/4411468910',
    nativeLanguage: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro1: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro3: 'ca-app-pub-3940256099942544/3986624511',
    nativeColoring: 'ca-app-pub-3940256099942544/3986624511',
    interstitialSplash: 'ca-app-pub-3940256099942544/4411468910',
    interstitialItem: 'ca-app-pub-3940256099942544/4411468910',
    banner: 'ca-app-pub-3940256099942544/2934735716',
  );
}

class AppAdIds {
  static AdManager get _ads => GetIt.instance<AdManager>();

  static String get interstitialSplash =>
      _ads.config.getId('interstitial_splash');
  static String get interstitialSave => _ads.config.getId('interstitial_save');
  static String get interstitialItem => _ads.config.getId('interstitial_item');
  static String get interstitialSpin => _ads.config.getId('interstitial_spin');
  static String get nativeLanguage => _ads.config.getId('native_language');
  static String get nativeIntro1 => _ads.config.getId('native_intro1');
  static String get nativeIntro3 => _ads.config.getId('native_intro3');
  static String get nativeColoring => _ads.config.getId('native_coloring');
  static String get banner => _ads.config.getId('banner');

  // Generic helper if needed
  static String getId(String key) => _ads.config.getId(key);
}
