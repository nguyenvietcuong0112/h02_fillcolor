import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/storage_utils.dart';
import 'services/ads_service.dart';
import 'services/remote_config_service.dart';
import 'app.dart';

void main() async {
  // Disable Impeller engine to use Skia for better performance with complex SVG paths
  // Impeller can cause lag with many paths. Skia is more stable.
  // To disable Impeller, run: flutter run --no-enable-impeller
  // Or set environment variable: export FLUTTER_IMPELLER=0
  // For production builds, add --no-enable-impeller to build commands
  
  WidgetsFlutterBinding.ensureInitialized();

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
  
  // Initialize services that don't require Firebase first
  await AdsService.instance.initialize();
  
  // Initialize Firebase services only if Firebase is initialized
  if (firebaseInitialized) {
    try {
      await RemoteConfigService.instance.initialize();
    } catch (e) {
      debugPrint('RemoteConfig initialization error: $e');
    }
  }

  // Show app open ad
  AdsService.instance.showAppOpenAd();

  runApp(
    const ProviderScope(
      child: FillColorApp(),
    ),
  );
}
