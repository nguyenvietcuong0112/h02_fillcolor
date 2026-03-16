import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/storage_utils.dart';
import 'core/utils/thumbnail_helper.dart';
import 'di/dependency_injection.dart';
import 'services/remote_config_service.dart';
import 'package:injectable/injectable.dart';
import 'package:ds_ads/ds_ads.dart';

import 'app.dart';

const String env = Environment.dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize Firebase (optional - app will work without it)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Firebase not configured - app will work without it
    debugPrint('Firebase initialization skipped: $e');
    debugPrint('App will continue without Firebase features');
  }

  // Initialize services
  await StorageUtils.init();

  // Clear thumbnail cache to ensure fresh images are loaded
  await ThumbnailHelper.clearAllThumbnails();

  // Initialize services that don't require Firebase first
  await configureDependencies(env);

  // Initialize Ads
  final ads = getIt<AdManager>();
  await ads.init();
  ads.loadInterstitialAd();

  // Initialize Firebase services only if Firebase is initialized
  if (firebaseInitialized) {
    try {
      await RemoteConfigService.instance.initialize();
    } catch (e) {
      debugPrint('RemoteConfig initialization error: $e');
    }
  }

  // Show app open ad
  runApp(const ProviderScope(child: FillColorApp()));
}
