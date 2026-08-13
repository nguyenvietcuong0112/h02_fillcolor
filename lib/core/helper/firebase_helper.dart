import 'dart:io';
import 'dart:ui';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../ads/const/ad_id.dart';
import '../../ads/const/ad_id_name.dart';

class FirebaseHelper {
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  static Locale? get userLocale => PlatformDispatcher.instance.locale;

  static const EVENT_USER_LOCALE = 'user_locale';

  static const premium_view = "premium_view";
  static const paywall_view = "paywall_view";
  static const payment_successful = "payment_successful";
  static const payment_failed = "payment_failed";
  static const payment_cancel = "payment_cancel";
  static const payment_restore = "payment_restore";
  static const sale_popup_view = "sale_popup_view";
  static const sale_banner_view = "sale_banner_view";

  static const main_view = "main_view";
  static const onboard1_view = "onboard1_view";
  static const onboard2_view = "onboard2_view";
  static const onboard3_view = "onboard3_view";

  static const show_dialog_no_internet = "show_dialog_no_internet";
  static const show_dialog_no_internet_in_FO = "show_dialog_no_internet_in_FO";

  // Event purchase
  static const EVENT_CLICK_PURCHASE_WEEKLY = 'click_purchase_weekly';
  static const EVENT_CLICK_PURCHASE_MONTHLY = 'click_purchase_monthly';
  static const EVENT_CLICK_PURCHASE_YEARLY = 'click_purchase_yearly';
  static const EVENT_CLICK_PURCHASE_YEARLY_SALE = 'click_purchase_yearly_sale';
  static const EVENT_CLICK_PURCHASE_LIFETIME = 'click_purchase_lifetime';
  static const EVENT_CLICK_PURCHASE_3MONTHS = 'click_purchase_3months';
  static const EVENT_CLICK_PURCHASE_REMOVE_ADS = 'click_purchase_remove_ads';
  static const EVENT_PURCHASE_SUCCESS_WEEKLY = 'purchase_success_weekly';
  static const EVENT_PURCHASE_SUCCESS_MONTHLY = 'purchase_success_monthly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY_SALE = 'purchase_success_yearly_sale';
  static const EVENT_PURCHASE_SUCCESS_LIFETIME = 'purchase_success_lifetime';
  static const EVENT_PURCHASE_SUCCESS_3MONTHS = 'purchase_success_3months';
  static const EVENT_PURCHASE_SUCCESS_REMOVE_ADS =
      'purchase_success_remove_ads';
  static const EVENT_PURCHASE_ERROR = 'purchase_error';

  static setUserId(String userId) {
    analytics.setUserId(id: userId);
  }

  static setTrackingScreenName(String screenName) async {
    try {
      FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      debugPrint('setTrackingScreenName: $screenName');
    } catch (e) {
      debugPrint("error setTrackingScreenName $e");
    }
  }

  static String? getAdPlacementEventName(String? adUnitId,
      {String? adIdName, AdUnitType? adUnitType}) {
    debugPrint(
        'DEBUG_TRACE getAdPlacementEventName: adUnitId=$adUnitId, adIdName=$adIdName, adUnitType=$adUnitType');
    if (adUnitId == null && adIdName == null) return null;

    String? keyName = adIdName;

    // If adIdName is null or is an ad unit ID (starts with ca-app-pub-), try to look up in maps
    if (keyName == null || keyName.startsWith('ca-app-pub-')) {
      final searchId = adUnitId ?? adIdName;
      final prodMap = myAdsId[Environment.prod] ?? {};
      final devMap = myAdsId[Environment.dev] ?? {};

      keyName = null;
      prodMap.forEach((key, val) {
        if (val == searchId && keyName == null) keyName = key;
      });
      if (keyName == null) {
        devMap.forEach((key, val) {
          if (val == searchId && keyName == null) keyName = key;
        });
      }
    }

    debugPrint('DEBUG_TRACE keyName resolved: $keyName');

    if (keyName != null) {
      switch (keyName) {
        case MyAdIdName.appOpenResume:
          return "resume_open_app";
        case MyAdIdName.interSplash:
          return "inter_splash_view";
        case MyAdIdName.interAll:
          return "inters_ad_view";
        case MyAdIdName.nativeLanguage:
          return "native_language_view";
        case MyAdIdName.nativeLanguageClick:
          return "native_language_click_view";
        case MyAdIdName.nativeOnboard1Ad:
          return "native_onboarding_1_view";
        case MyAdIdName.nativeOnboardFull1Ad:
          return "native_onboarding_full_1_view";
        case MyAdIdName.nativeOnboardFull2Ad:
          return "native_onboarding_full_2_view";
        case MyAdIdName.nativeOnboard3Ad:
          return "native_onboarding_3_view";
        case MyAdIdName.nativeBanner:
          return "native_banner_view";
        case MyAdIdName.interOnboard:
          return "inter_onboard_view";
        case MyAdIdName.nativeFull:
          return "native_full_view";
        case MyAdIdName.nativeAll:
          return "native_all_view";
        case MyAdIdName.rewardedAd:
          return "rewarded_ad_view";
      }
    }

    return null;
  }

  static Future<void> logAdmobAdImpression(
      {required Ad ad, String? adIdName, AdUnitType? adUnitType}) async {
    try {
      debugPrint(
          'DEBUG_TRACE logAdmobAdImpression called: adUnitId=${ad.adUnitId}, adIdName=$adIdName');
      // 1. Log custom ad placement event matching the checklist
      final placementEvent = getAdPlacementEventName(ad.adUnitId,
          adIdName: adIdName, adUnitType: adUnitType);
      debugPrint('DEBUG_TRACE placementEvent: $placementEvent');
      if (placementEvent != null) {
        await analytics.logEvent(name: placementEvent);
        debugPrint('Firebase logged ad placement event: $placementEvent');
      }

      // 2. Log standard Firebase ad_impression
      await analytics.logAdImpression(
        adFormat: ad is BannerAd
            ? 'Banner'
            : (ad is AppOpenAd
                ? 'OpenAd'
                : (ad is NativeAd ? 'Native' : 'Interstitial')),
        adPlatform: 'Admob',
        adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
        adUnitName: ad.adUnitId,
        currency: 'USD',
      );
    } catch (e) {
      debugPrint("error logAdmobAdImpression: $e");
    }
  }

  static logEventName(String eventName, {String param = ''}) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {"param": param},
      );
    } catch (e) {
      debugPrint("error logEventName $e");
    }
  }

  static logEventUserLocale({
    required String languageCode,
    required String countryCode,
    required String scriptCode,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_USER_LOCALE,
      parameters: {
        "language_code": languageCode,
        "country_code": countryCode,
        "script_code": scriptCode,
      },
    );
  }

  static logEventClickPurchaseRemoveAds({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_REMOVE_ADS,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseMonthly({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_MONTHLY,
      parameters: {
        "product_id": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearly({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearlySale({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY_SALE,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseLifetime({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_LIFETIME,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventPurchaseSuccessWeekly(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_WEEKLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccessMonthly(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_MONTHLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccessYearly(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_YEARLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccessYearlySale(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_YEARLY_SALE,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccessLifetime(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_LIFETIME,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccess3Months(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_3MONTHS,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseSuccessRemoveAds(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode ?? '';
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_REMOVE_ADS,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_$countryCode',
      },
    );
  }

  static logEventPurchaseError(
      {required dynamic purchase, required bool isGoogle}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_ERROR,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "store": isGoogle ? "Google" : "Apple",
      },
    );
  }

  static logInAppPurchaseCustom(
      {required dynamic purchase,
      required dynamic productDetail,
      required bool isGoogle}) async {
    await analytics.logEvent(
      name: 'in_app_purchase_custom',
      parameters: {
        "source": purchase.purchaseID.toString(),
        "demand": 'default',
        "decimalvalue": productDetail.rawPrice.toString(),
        "store": isGoogle ? "Google" : "Apple",
      },
    );
  }
}
