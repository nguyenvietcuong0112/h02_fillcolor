import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../services/ads_service.dart';
import '../services/firebase_remote_config_service.dart';
import '../services/share_preference_service.dart';
import 'dependency_injection.config.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configure(String environment) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await FirebaseRemoteConfigService.initFirebaseRemoteConfig();

  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FirebaseAnalytics>(FirebaseAnalytics.instance);
  getIt.registerSingleton<FirebaseRemoteConfigService>(
    FirebaseRemoteConfigService(),
  );
  getIt.registerSingleton<AdsService>(AdsService());
  getIt.registerSingleton<SharedPreferenceService>(SharedPreferenceService());
}

Future<void> configureDependencies() async {
  getIt.init(environment: env);
  await configure(env);
}
