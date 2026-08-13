import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ads/const/ad_id_extension.dart';
import 'ads/const/ad_id_name.dart';
import 'ads/loading/ad_loading_page.dart';
import 'ads/manager/my_ad_id_manager.dart';
import 'core/helper/firebase_helper.dart';
import 'core/utils/storage_utils.dart';
import 'core/utils/thumbnail_helper.dart';
import 'di/dependency_injection.dart';
import 'firebase_options.dart';
import 'package:injectable/injectable.dart';
import 'app/app.dart';

const String env = Environment.prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hide status bar and navigation bar for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );


  // Initialize services
  await StorageUtils.init();

  // Clear thumbnail cache to ensure fresh images are loaded
  await ThumbnailHelper.clearAllThumbnails();

  // Initialize services that don't require Firebase first
  await configureDependencies();



  await _initializeAds();

  // Show app open ad
  runApp(const ProviderScope(child: FillColorApp()));
}

Future<void> _initializeAds() async {
  try {
    debugPrint('🚀 Starting ads initialization...');

    await EasyAds.instance.initFirebaseAnalytics(FirebaseHelper.analytics);
    EasyAds.adIdResolver = (adId) => adId.getId;

    // Encapsulated Consent Flow (ATT & UMP GDPR)
    await EasyAds.instance.initConsent();

    final IAdIdManager adIdManager = MyAdIdManager();

    await EasyAds.instance.initialize(
      adIdManager,
      navigatorKey: rootNavigatorKey,
      unityTestMode: true,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 60000),
      admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
      loadingSplash: const AdLoadingPage(),
    );

    debugPrint('✅ EasyAds initialized');

    await EasyAds.instance.initAdmob(
      appOpenAdUnitId: MyAdIdName.appOpenResume.getId,
      appOpenAdIdName: MyAdIdName.appOpenResume,
    );

    // Preload App Open Ad so it's ready immediately when app is resumed
    EasyAds.instance.loadAppOpenAd();

    EasyAds.instance.onEvent.listen((event) {
      debugPrint('🔥 EasyAds event: type=${event.type}, adUnitId=${event.adUnitId}, data=${event.data}');

      Ad? adObj;
      if (event.ad is Ad) {
        adObj = event.ad as Ad;
      } else if (event.data is Ad) {
        adObj = event.data as Ad;
      }

      final String? adIdName = event.data is String ? event.data as String : null;

      // Handle onAdImpression: logs custom placement event + standard Firebase ad_impression
      if (event.type == AdEventType.onAdImpression) {
        if (adObj != null) {
          FirebaseHelper.logAdmobAdImpression(
            ad: adObj,
            adIdName: adIdName,
            adUnitType: event.adUnitType,
          );
        }
      }

      // Auto preload next App Open Ad after current one is dismissed or failed
      if (event.adUnitType == AdUnitType.appOpen) {
        if (event.type == AdEventType.adDismissed ||
            event.type == AdEventType.adFailedToLoad ||
            event.type == AdEventType.adFailedToShow) {
          EasyAds.instance.loadAppOpenAd();
        }
      }
    });

    debugPrint('✅ AdMob initialized with App Open Ad (preloading started)');
    debugPrint('✅ All ads initialization completed successfully');

  } catch (e) {
    debugPrint('❌ Ads initialization error: $e');
  }
}
