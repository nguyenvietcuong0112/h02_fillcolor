import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/share_preference_service.dart';

@module
abstract class CoreModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  SharedPreferenceService sharedPreferenceService(SharedPreferences prefs) =>
      SharedPreferenceService(prefs);

  @lazySingleton
  AppsflyerSdk get appsflyerSdk {
    final AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(afDevKey: '');
    return AppsflyerSdk(appsFlyerOptions);
  }
}
