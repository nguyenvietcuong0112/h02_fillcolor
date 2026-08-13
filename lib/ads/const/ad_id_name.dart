import 'dart:io';

import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../main.dart' as app_main;

class MyAdIdName {

  static String get appID {
    final isProd = app_main.env == Environment.prod;
    if (isProd) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1189834344037075~7530902971";
      } else {
        return "";
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544~3347511713";
      } else {
        return "";
      }
    }
  }


  static const appOpenResume = "appOpenResume";
  static const interSplash = "interSplash";
  static const interSplashHigh = "interSplashHigh";
  static const nativeLanguage = "nativeLanguage";
  static const nativeLanguageHigh = "nativeLanguageHigh";
  static const nativeLanguageClick = "nativeLanguageClick";
  static const nativeLanguageClickHigh = "nativeLanguageClickHigh";
  static const nativeOnboard1Ad = "nativeOnboard1Ad";
  static const nativeOnboardFull1Ad = "nativeOnboardFull1Ad";
  static const nativeOnboardFull2Ad = "nativeOnboardFull2Ad";
  static const nativeOnboard3Ad = "nativeOnboard3Ad";
  static const interOnboard = "interOnboard";
  static const nativeFull = "nativeFull";
  static const rewardedAd = "rewardedAd";
  static const nativeBanner = "nativeBanner";
  static const interAll = "interAll";
  static const nativeAll = "nativeAll";
}

enum AdType { nativeExpand, nativeCollapse }
