/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ColorFlow';
  static const String appFullName = 'ColorFlow - Coloring Book';
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
  static const String galleryFolderName = 'ColorFlow';
  static const int maxGalleryItems = 100;

  // Coloring
  static const double minBrushSize = 5.0;
  static const double maxBrushSize = 50.0;
  static const double defaultBrushSize = 15.0;
  static const int maxUndoRedoSteps = 50;

  // Categorized Palettes
  static const Map<String, List<int>> colorPalettes = {
    'Basic': [
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
    ],
    'Pastel': [
      0xFFFFB7B2, // Pastel Red
      0xFFFFDAC1, // Pastel Orange
      0xFFFFF9B1, // Pastel Yellow
      0xFFE2F0CB, // Pastel Green
      0xFFB5EAD7, // Pastel Mint
      0xFFC7CEEA, // Pastel Blue
      0xFFFF9AA2, // Pastel Pink
      0xFFB28DFF, // Pastel Purple
      0xFFAFF8D8, // Pastel Teal
      0xFFE0BBE4, // Pastel Lavender
    ],
    'Neon': [
      0xFF39FF14, // Neon Green
      0xFFFF00FF, // Neon Magenta
      0xFF00FFFF, // Neon Cyan
      0xFFFFFF00, // Neon Yellow
      0xFFFF3131, // Neon Red
      0xFFBC13FE, // Neon Purple
      0xFF00E5FF, // Neon Blue
      0xFFFF5F1F, // Neon Orange
      0xFFFE019A, // Neon Pink
    ],
    'Ocean': [
      0xFF0077BE, // Ocean Blue
      0xFF0096FF, // Clear Blue
      0xFF00C9FF, // Sky Blue
      0xFF50BFE6, // Soft Blue
      0xFF008080, // Teal
      0xFF20B2AA, // Light Sea Green
      0xFF40E0D0, // Turquoise
      0xFF7FFFD4, // Aquamarine
      0xFFADEAEA, // Soft Cyan
    ],
    'Autumn': [
      0xFF8B0000, // Dark Red
      0xFFA52A2A, // Brown
      0xFFD2691E, // Chocolate
      0xFFB8860B, // Dark Goldenrod
      0xFFCD853F, // Peru
      0xFF8B4513, // Saddle Brown
      0xFFD2B48C, // Tan
      0xFFBC8F8F, // Rosy Brown
      0xFFBCB88A, // Sage
      0xFF704214, // Umber
    ],
    'Skin Tones': [
      0xFFFFDBAC, // Lightest
      0xFFF1C27D, // Light
      0xFFE0AC69, // Medium
      0xFFC68642, // Medium-Deep
      0xFF8D5524, // Dark
      0xFFFFB38B, // Peach
      0xFFE4A285, // Rose Beige
      0xFF9A5239, // Deep Terra
      0xFF5A3321, // Espresso
      0xFFD7886C, // Sunset
    ],
    'Hair': [
      0xFF3D2314, // Dark Brown
      0xFF4E2D1A, // Medium Brown
      0xFF593222, // Light Brown
      0xFF91553D, // Reddish Brown
      0xFFA7856A, // Dirty Blonde
      0xFFE6BE8A, // Light Blonde
      0xFFFFF5E1, // Platinum Blonde
      0xFFB55239, // Auburn
      0xFF8D4B38, // Copper
    ],
    'Eyes': [
      0xFF634E34, // Brown
      0xFF2E536F, // Blue
      0xFF3D671D, // Green
      0xFF1C7847, // Emerald
      0xFF497665, // Hazel
      0xFF707070, // Grey
      0xFF1E3F66, // Navy
      0xFF4B0082, // Indigo
      0xFF800080, // Purple
    ],
    'Lips': [
      0xFFD13639, // Classic Red
      0xFF9D2135, // Berry
      0xFFE16266, // Coral
      0xFFF093A2, // Soft Pink
      0xFFDA70D6, // Orchid
      0xFF800020, // Burgundy
      0xFFC71585, // Medium Violet Red
      0xFFDB7093, // Pale Violet Red
      0xFFFFB6C1, // Light Pink
      0xFFFFA07A, // Light Salmon
    ],
    'Nature': [
      0xFF228B22, // Forest Green
      0xFF87CEEB, // Sky Blue
      0xFF4682B4, // Steel Blue
      0xFFD2B48C, // Tan
      0xFF8B4513, // Saddle Brown
      0xFF2E8B57, // Sea Green
      0xFF778899, // Light Slate Grey
      0xFFBDB76B, // Dark Khaki
      0xFFCD853F, // Peru
      0xFF556B2F, // Dark Olive Green
    ],
  };

  // Default Colors (Legacy support)
  static const List<int> defaultColors = [
    0xFFFF0000, // Changed Red to first color instead of black
    0xFF808080, 0xFFC0C0C0, 0xFFFFFFFF,
    0xFF8B0000, 0xFFFF4D4D, 0xFFFF6666,
    0xFF00FF00, 0xFF008000, 0xFF013220, 0xFF90EE90,
  ];

  static const List<int> premiumColors = [
    0xFFFFB7B2, 0xFFFFDAC1, 0xFFE2F0CB, 0xFFB5EAD7, 0xFFC7CEEA,
  ];
}


