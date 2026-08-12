import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Service for Firebase Remote Config
class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  RemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  /// Get remote config instance (lazy initialization)
  FirebaseRemoteConfig get _config {
    _remoteConfig ??= FirebaseRemoteConfig.instance;
    return _remoteConfig!;
  }

  /// Initialize Remote Config
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig ??= FirebaseRemoteConfig.instance;
      await _config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      // Set default values
      await _config.setDefaults({
        'max_free_saves': 3,
        'ad_cooldown_minutes': 5,
        'enable_app_open_ads': true,
        'enable_interstitial_ads': true,
        'show_native_coloring_ad': true,
        'gemini_api_key': '',
        'gemini_model_name': 'gemini-3.5-flash',
      });

      // Fetch and activate
      try {
        await _config.fetchAndActivate();
      } catch (e) {
        // Handle error - use defaults
      }

      _isInitialized = true;
    } catch (e) {
      // Firebase not initialized - use defaults
      _isInitialized = true;
    }
  }

  /// Get max free saves
  int get maxFreeSaves {
    if (!_isInitialized || _remoteConfig == null) return 3;
    try {
      return _config.getInt('max_free_saves');
    } catch (e) {
      return 3;
    }
  }

  /// Get ad cooldown minutes
  int get adCooldownMinutes {
    if (!_isInitialized || _remoteConfig == null) return 5;
    try {
      return _config.getInt('ad_cooldown_minutes');
    } catch (e) {
      return 5;
    }
  }

  /// Check if app open ads are enabled
  bool get enableAppOpenAds {
    if (!_isInitialized || _remoteConfig == null) return true;
    try {
      return _config.getBool('enable_app_open_ads');
    } catch (e) {
      return true;
    }
  }

  /// Check if interstitial ads are enabled
  bool get enableInterstitialAds {
    if (!_isInitialized || _remoteConfig == null) return true;
    try {
      return _config.getBool('enable_interstitial_ads');
    } catch (e) {
      return true;
    }
  }

  /// Check if native coloring ad is enabled
  bool get showNativeColoringAd {
    if (!_isInitialized || _remoteConfig == null) return true;
    try {
      return _config.getBool('show_native_coloring_ad');
    } catch (e) {
      return true;
    }
  }

  /// Get Gemini API key
  String get geminiApiKey {
    const String defaultKey = '';
    if (!_isInitialized || _remoteConfig == null) return defaultKey;
    try {
      final String val = _config.getString('gemini_api_key');
      return val.isNotEmpty ? val : defaultKey;
    } catch (e) {
      return defaultKey;
    }
  }

  /// Get Gemini Model Name
  String get geminiModelName {
    const String defaultModel = 'gemini-3.5-flash';
    if (!_isInitialized || _remoteConfig == null) return defaultModel;
    try {
      final String val = _config.getString('gemini_model_name');
      return val.isNotEmpty ? val : defaultModel;
    } catch (e) {
      return defaultModel;
    }
  }

  /// Fetch and activate config
  Future<void> fetchAndActivate() async {
    if (!_isInitialized || _remoteConfig == null) return;
    try {
      await _config.fetchAndActivate();
    } catch (e) {
      // Handle error
    }
  }
}
