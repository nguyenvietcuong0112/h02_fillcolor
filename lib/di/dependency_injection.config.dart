// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:appsflyer_sdk/appsflyer_sdk.dart' as _i187;
import 'package:ds_ads/ds_ads.dart' as _i943;
import 'package:get_it/get_it.dart' as _i174;
import 'package:h02_colorfill/di/modules/ads_module.dart' as _i235;
import 'package:h02_colorfill/di/modules/core_module.dart' as _i311;
import 'package:h02_colorfill/services/share_preference_service.dart' as _i739;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

const String _dev = 'dev';
const String _test = 'test';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final adsModule = _$AdsModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i187.AppsflyerSdk>(() => coreModule.appsflyerSdk);
    gh.lazySingleton<_i739.SharedPreferenceService>(
      () => coreModule.sharedPreferenceService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i943.AdConfig>(
      () => adsModule.devAdConfig,
      registerFor: {_dev, _test},
    );
    gh.factory<_i943.AdConfig>(
      () => adsModule.prodAdConfig,
      registerFor: {_prod},
    );
    gh.lazySingleton<_i943.AdManager>(
      () => adsModule.adManager(gh<_i943.AdConfig>()),
    );
    return this;
  }
}

class _$CoreModule extends _i311.CoreModule {}

class _$AdsModule extends _i235.AdsModule {}
