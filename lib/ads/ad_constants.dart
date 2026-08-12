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
    appUnitId: 'ca-app-pub-3753821601142094~2183908220',
    interstitial: 'ca-app-pub-3753821601142094/2772683703',
    nativeLanguage: 'ca-app-pub-3753821601142094/5148982914',
    nativeIntro1: '',
    nativeIntro3: '',
    nativeColoring: 'ca-app-pub-3753821601142094/5148982914',
    interstitialSplash: 'ca-app-pub-3753821601142094/2772683703',
    interstitialSave: 'ca-app-pub-3753821601142094/2772683703',
    interstitialItem: 'ca-app-pub-3753821601142094/2772683703',
    banner: 'ca-app-pub-3753821601142094/5398847043',
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
    // TODO: Replace with your REAL iOS AdMob App ID
    appUnitId: 'ca-app-pub-3753821601142094~2183908220', // Use your REAL App ID here
    // TODO: Replace with your REAL iOS Interstitial Ad Unit ID
    interstitial: 'ca-app-pub-3940256099942544/4411468910', 
    // TODO: Replace with your REAL iOS Native Ad Unit ID
    nativeLanguage: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro1: 'ca-app-pub-3940256099942544/3986624511',
    nativeIntro3: 'ca-app-pub-3940256099942544/3986624511',
    nativeColoring: 'ca-app-pub-3940256099942544/3986624511',
    interstitialSplash: 'ca-app-pub-3940256099942544/4411468910',
    interstitialItem: 'ca-app-pub-3940256099942544/4411468910',
    // TODO: Replace with your REAL iOS Banner Ad Unit ID
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
