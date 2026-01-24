# Configuration Guide - FillColor App

This guide will help you configure the app for Android and iOS platforms.

## Prerequisites

1. **Firebase Project**: Create a Firebase project at https://console.firebase.google.com
2. **AdMob Account**: Create an AdMob account at https://admob.google.com
3. **RevenueCat Account**: Create a RevenueCat account at https://app.revenuecat.com

---

## Android Configuration

### 1. Firebase Setup

1. Go to Firebase Console → Project Settings
2. Add Android app with package name: `com.fillcolor.coloringbook.paint.colorart`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 2. AdMob Setup

1. Go to AdMob Console → Apps → Add App
2. Select Android platform
3. Copy your **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
4. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="YOUR_ADMOB_APP_ID"/>
   ```

5. Update `lib/core/constants/app_constants.dart` with your Ad Unit IDs:
   ```dart
   static const String adAppOpenId = 'YOUR_APP_OPEN_AD_UNIT_ID';
   static const String adInterstitialId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';
   static const String adNativeId = 'YOUR_NATIVE_AD_UNIT_ID';
   ```

### 3. RevenueCat Setup

1. Go to RevenueCat Dashboard → Projects → Your Project
2. Add Android app
3. Copy your **Public API Key**
4. Update `lib/core/constants/app_constants.dart`:
   ```dart
   static const String revenueCatApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
   ```

5. Configure subscription products in RevenueCat Dashboard:
   - Weekly subscription: `weekly_subscription`
   - Monthly subscription: `monthly_subscription`
   - Yearly subscription: `yearly_subscription`

### 4. Permissions

The following permissions are already configured in `AndroidManifest.xml`:
- Internet access
- Network state
- Storage (for saving artworks)

---

## iOS Configuration

### 1. Firebase Setup

1. Go to Firebase Console → Project Settings
2. Add iOS app with Bundle ID: `com.fillcolor.coloringbook.paint.colorart`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`
5. Add to Xcode project (drag and drop into Runner folder)

### 2. AdMob Setup

1. Go to AdMob Console → Apps → Add App
2. Select iOS platform
3. Copy your **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
4. Update `ios/Runner/Info.plist`:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>YOUR_ADMOB_APP_ID</string>
   ```

5. Update `lib/core/constants/app_constants.dart` with your Ad Unit IDs (same as Android or create separate ones)

### 3. RevenueCat Setup

1. Go to RevenueCat Dashboard → Projects → Your Project
2. Add iOS app
3. Copy your **Public API Key**
4. Update `lib/core/constants/app_constants.dart`:
   ```dart
   // You may want to use platform-specific keys
   static const String revenueCatApiKey = 'YOUR_REVENUECAT_IOS_API_KEY';
   ```

5. Configure subscription products in RevenueCat Dashboard (same as Android)

### 4. Capabilities & Permissions

The following are already configured in `Info.plist`:
- Photo Library Usage Description
- Photo Library Add Usage Description

### 5. Xcode Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Ensure your Team and Bundle Identifier are set correctly
4. Run `pod install` in the `ios` directory:
   ```bash
   cd ios
   pod install
   ```

---

## Code Configuration

### Update Constants

Edit `lib/core/constants/app_constants.dart`:

```dart
// Replace test AdMob IDs with your actual IDs
static const String adAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String adInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String adNativeId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

// Replace with your RevenueCat API key
static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';

// Update subscription IDs to match your RevenueCat configuration
static const String subscriptionWeekly = 'your_weekly_id';
static const String subscriptionMonthly = 'your_monthly_id';
static const String subscriptionYearly = 'your_yearly_id';
```

### Platform-Specific API Keys (Optional)

If you want different API keys for Android and iOS, you can use:

```dart
import 'dart:io';

static String get revenueCatApiKey {
  if (Platform.isAndroid) {
    return 'YOUR_ANDROID_API_KEY';
  } else if (Platform.isIOS) {
    return 'YOUR_IOS_API_KEY';
  }
  return 'YOUR_DEFAULT_API_KEY';
}
```

---

## Testing

### Test Ad Unit IDs

For testing, you can use Google's test ad unit IDs (already configured):
- App Open: `ca-app-pub-3940256099942544/3419835294`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Native: `ca-app-pub-3940256099942544/2247696110`

### Test Devices

Add your test device IDs to AdMob for testing real ads.

---

## Build Instructions

### Android

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter clean
flutter pub get
cd ios
pod install
pod update
cd ..
flutter build ios --release
```

---

## Troubleshooting

### Android

1. **Google Services Error**: Ensure `google-services.json` is in `android/app/`
2. **AdMob Not Loading**: Check App ID in `AndroidManifest.xml`
3. **Build Errors**: Run `flutter clean` and rebuild

### iOS

1. **Pod Install Errors**: Run `pod repo update` then `pod install`
2. **Firebase Not Found**: Ensure `GoogleService-Info.plist` is added to Xcode project
3. **AdMob Not Loading**: Check App ID in `Info.plist`
4. **Signing Issues**: Check Bundle ID and Team in Xcode

---

## Production Checklist

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Update RevenueCat API keys
- [ ] Configure subscription products in RevenueCat
- [ ] Set up Firebase Remote Config values
- [ ] Test ads on real devices
- [ ] Test subscription flow end-to-end
- [ ] Update app icons and splash screens
- [ ] Configure app signing for release builds
- [ ] Test on both Android and iOS devices
- [ ] Review privacy policy and terms of service

---

## Support

For issues or questions:
- Firebase: https://firebase.google.com/support
- AdMob: https://support.google.com/admob
- RevenueCat: https://docs.revenuecat.com

