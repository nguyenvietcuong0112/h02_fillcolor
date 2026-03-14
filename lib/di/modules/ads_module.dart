import 'package:ds_ads/ds_ads.dart';
import 'package:injectable/injectable.dart';
import '../../ads/ad_constants.dart';

@module
abstract class AdsModule {
  @Environment(Environment.prod)
  AdConfig get prodAdConfig => AdConfig(
    android: AdConstants.androidProd.toPlatformConfig(),
    ios: AdConstants.iosProd.toPlatformConfig(),
    isProd: true,
  );

  @Environment(Environment.dev)
  @Environment(Environment.test)
  AdConfig get devAdConfig => AdConfig(
    android: AdConstants.androidTest.toPlatformConfig(),
    ios: AdConstants.iosTest.toPlatformConfig(),
    isProd: false,
  );

  @lazySingleton
  AdManager adManager(AdConfig config) => AdManager(config);
}
