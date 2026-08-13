import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  static const String android_app_version = "android_app_version";

  //ads
  static const String banner_splash = "banner_splash";
  static const String native_banner = "native_banner";
  static const String inter_splash_high = "inter_splash_high";
  static const String inter_splash = "inter_splash";
  static const String native_language = "native_language";
  static const String native_language_click = "native_language_click";
  static const String native_onboarding_1 = "native_onboarding_1";
  static const String native_onboarding_full_1 = "native_onboarding_full_1";
  static const String native_onboarding_full_2 = "native_onboarding_full_2";
  static const String native_onboarding_3 = "native_onboarding_3";

  static const String inter_all = "inter_all";
  static const String inter_save = "inter_save";
  static const String interval_inter_ad = "interval_inter_ad";
  static const String native_all = "native_all";
  static const String native_sketch = "native_sketch";
  static const String native_fill_brush = "native_fill_brush";

  static const String app_open_resume = "app_open_resume";
  static const String reward_all = "reward_all";

  static const String time_delay_close_premium = "time_delay_close_premium";
  static const String show_activity_iap = "show_activity_iap";



  static Future<void> initFirebaseRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 2),
          minimumFetchInterval: const Duration(seconds: 60),
        ),
      );
      await remoteConfig.setDefaults({
        "show_activity_iap": true,
        "banner_splash": true,
        "native_banner": true,
        "inter_splash_high": true,
        "inter_splash": true,
        "native_language": true,
        "native_language_click": true,
        "native_onboarding_1": true,
        "native_onboarding_full_1": true,
        "native_onboarding_full_2": true,
        "native_onboarding_3": true,
        "native_permission": true,
        "inter_onboard": true,
        "inter_all": true,
        "inter_save": true,
        "native_all": true,
        "native_sketch": true,
        "native_fill_brush": true,
        "app_open_resume": true,
        "appOpenResume": true,
        "native_themes": true,
        "native_piano": true,
        "interval_inter_ad": 30,
        "time_delay_close_premium": 3,
      });
      await remoteConfig.fetchAndActivate();
    } catch (e) {}
  }

  static String getStringConfigByKey(String key) {
    return remoteConfig.getString(key);
  }

  static bool getBoolConfigByKey(String key, {bool defaultValue = true}) {
    try {
      final mappedKey = _mapAdKeyToRemoteConfigKey(key);
      final value = remoteConfig.getValue(mappedKey);
      if (value.source == ValueSource.valueStatic) {
        final rawValue = remoteConfig.getValue(key);
        if (rawValue.source != ValueSource.valueStatic) {
          return remoteConfig.getBool(key);
        }
        return defaultValue;
      }
      return remoteConfig.getBool(mappedKey);
    } catch (e) {
      return defaultValue;
    }
  }

  static String _mapAdKeyToRemoteConfigKey(String key) {
    switch (key) {
      case "nativeAll":
        return native_all;
      case "native_sketch":
        return native_sketch;
      case "native_fill_brush":
        return native_fill_brush;
      case "interAll":
        return inter_all;
      case "inter_save":
        return inter_save;
      case "nativeBanner":
        return native_banner;
      case "interSplash":
        return inter_splash;
      case "interSplashHigh":
        return inter_splash_high;
      case "nativeLanguage":
        return native_language;
      case "nativeLanguageClick":
        return native_language_click;
      case "nativeOnboard1Ad":
        return native_onboarding_1;
      case "nativeOnboardFull1Ad":
        return native_onboarding_full_1;
      case "nativeOnboardFull2Ad":
        return native_onboarding_full_2;
      case "nativeOnboard3Ad":
        return native_onboarding_3;
      case "nativeFull":
        return native_onboarding_full_1;
      case "rewardedAd":
        return reward_all;
      default:
        return key;
    }
  }

  static int getIntConfigByKey(String key, {int defaultValue = 0}) {
    try {
      final value = remoteConfig.getValue(key);
      if (value.source == ValueSource.valueStatic) {
        return defaultValue;
      }
      return remoteConfig.getInt(key);
    } catch (e) {
      return defaultValue;
    }
  }
}

typedef FirebaseService = FirebaseRemoteConfigService;
