import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/storage_utils.dart';
import 'services/ads_service.dart';
import 'services/remote_config_service.dart';
import 'app.dart';

void main() async {
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
