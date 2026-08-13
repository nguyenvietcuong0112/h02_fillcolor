import 'dart:async';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:injectable/injectable.dart';

import '../core/helper/iap_helper.dart';
import '../core/helper/notification_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../main.dart' as app_main;
import '../services/ads_service.dart';

class AppInitializer {
  static StreamSubscription<FGBGType>? _fgbgSubscription;

  static void init() {
    configLoading();
    AdsService.initOrganic();
    _initCommonSDK();
    IAPHelper.initIAP();

    Future.delayed(const Duration(seconds: 5), () {
      NotificationHelper.initializeNotifications();
    });
  }

  static void dispose() {
    _fgbgSubscription?.cancel();
  }

  static void _initCommonSDK() {
    _initPlatformState();
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      debugPrint('MyApp FGBGEvents: $event');
      if (event == FGBGType.foreground) {
        AppConstants.appInBackground = false;
      } else if (event == FGBGType.background) {
        AppConstants.appInBackground = true;
      }
    });


  }



  static Future<void> _initPlatformState() async {
    final isProd = app_main.env == Environment.prod;
    AdjustHelper.init(
      token: '1234',
      iapToken: '5678',
      isProd: isProd,
    );

    AdjustConfig config = AdjustConfig(
      AdjustHelper.adjustToken,
      !isProd ? AdjustEnvironment.sandbox : AdjustEnvironment.production,
    );

    await EasyAds.instance.initAdjust(
      config,
      onOrganicChanged: (isOrganic) => AdsService.setIsOrganic(isOrganic),
    );
  }

  static void handleStateApp(FGBGType event) {
    if (event == FGBGType.foreground) {
      debugPrint('App entered foreground');
    } else if (event == FGBGType.background) {
      debugPrint('App entered background');
    }
  }

  static void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.light
      ..radius = 10.0
      ..backgroundColor = AppColors.accent
      ..indicatorColor = AppColors.primary
      ..textColor = AppColors.primary
      ..userInteractions = true
      ..dismissOnTap = true
      ..maskType = EasyLoadingMaskType.none
      ..animationStyle = EasyLoadingAnimationStyle.scale;
  }
}
