import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for Firebase Analytics
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  FirebaseAnalytics? _analytics;

  /// Get analytics instance (lazy initialization)
  FirebaseAnalytics? get analytics {
    try {
      _analytics ??= FirebaseAnalytics.instance;
      return _analytics;
    } catch (e) {
      // Firebase not initialized - return null
      return null;
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      final analyticsInstance = analytics;
      if (analyticsInstance != null) {
        await analyticsInstance.logScreenView(screenName: screenName);
      }
    } catch (e) {
      // Firebase not initialized - silently fail
    }
  }

  /// Log event
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    try {
      final analyticsInstance = analytics;
      if (analyticsInstance != null) {
        await analyticsInstance.logEvent(
          name: name,
          parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
        );
      }
    } catch (e) {
      // Firebase not initialized - silently fail
    }
  }

  /// Log coloring started
  Future<void> logColoringStarted(String imageId) async {
    await logEvent('coloring_started', {'image_id': imageId});
  }

  /// Log coloring completed
  Future<void> logColoringCompleted(String imageId) async {
    await logEvent('coloring_completed', {'image_id': imageId});
  }

  /// Log artwork saved
  Future<void> logArtworkSaved() async {
    await logEvent('artwork_saved', null);
  }

  /// Log artwork shared
  Future<void> logArtworkShared() async {
    await logEvent('artwork_shared', null);
  }

  /// Log subscription started
  Future<void> logSubscriptionStarted(String packageId) async {
    await logEvent('subscription_started', {'package_id': packageId});
  }

  /// Log subscription completed
  Future<void> logSubscriptionCompleted(String packageId) async {
    await logEvent('subscription_completed', {'package_id': packageId});
  }
}

