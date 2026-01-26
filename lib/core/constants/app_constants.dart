/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FillColor';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyIsPremium = 'is_premium';
  static const String keySaveCount = 'save_count';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastAdShown = 'last_ad_shown';
  static const String keyLanguageCode = 'language_code';
  static const String keyIntroSeen = 'intro_seen';

  // Ad IDs (Replace with your actual AdMob IDs)
  static const String adAppOpenId = 'ca-app-pub-3940256099942544/3419835294'; // Test ID
  static const String adInterstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String adNativeId = 'ca-app-pub-3940256099942544/2247696110'; // Test ID

  // RevenueCat
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';
  static const String entitlementPremium = 'premium';

  // Subscription IDs
  static const String subscriptionWeekly = 'weekly_subscription';
  static const String subscriptionMonthly = 'monthly_subscription';
  static const String subscriptionYearly = 'yearly_subscription';

  // Limits
  static const int maxFreeSaves = 3;
  static const int adCooldownMinutes = 5;

  // Gallery
  static const String galleryFolderName = 'FillColor';
  static const int maxGalleryItems = 100;

  // Coloring
  static const double minBrushSize = 5.0;
  static const double maxBrushSize = 50.0;
  static const double defaultBrushSize = 15.0;
  static const int maxUndoRedoSteps = 50;

  // Default Colors
  static const List<int> defaultColors = [
    0xFF000000, // Black
    0xFFFFFFFF, // White
    0xFFFF0000, // Red
    0xFF00FF00, // Green
    0xFF0000FF, // Blue
    0xFFFFFF00, // Yellow
    0xFFFF00FF, // Magenta
    0xFF00FFFF, // Cyan
    0xFFFFA500, // Orange
    0xFF800080, // Purple
    0xFFFFC0CB, // Pink
    0xFFA52A2A, // Brown
  ];

  // Premium Colors
  static const List<int> premiumColors = [
    0xFFE6E6FA, // Lavender
    0xFFF0E68C, // Khaki
    0xFFCD5C5C, // Indian Red
    0xFF4B0082, // Indigo
    0xFF32CD32, // Lime Green
    0xFFFA8072, // Salmon
    0xFF20B2AA, // Light Sea Green
    0xFF9370DB, // Medium Purple
    0xFF3CB371, // Medium Sea Green
    0xFFFF7F50, // Coral
    0xFF4682B4, // Steel Blue
    0xFFDDA0DD, // Plum
  ];
}

