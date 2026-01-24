# FillColor - Professional Coloring Book App

A complete, production-ready Flutter coloring book application with brush coloring, tap-to-fill coloring, subscription monetization, ads, and save & share features.

## Features

- 🎨 **Two Coloring Modes**:
  - **Fill Mode**: Tap to fill vector regions
  - **Brush Mode**: Freehand drawing with adjustable brush size

- 🖼️ **SVG-Based Coloring**: Vector-based coloring engine (no pixel flood fill)

- 💾 **Save & Share**: Save your artworks to gallery and share with friends

- 📱 **Gallery**: View and manage all your saved artworks

- 💰 **Monetization**:
  - RevenueCat subscription integration (Weekly/Monthly/Yearly)
  - Google AdMob ads (App Open, Interstitial, Native)
  - Premium features unlock

- 📊 **Analytics**: Firebase Analytics integration

- ⚙️ **Remote Config**: Firebase Remote Config for dynamic configuration

- 🔄 **Undo/Redo**: Full undo/redo support for both fill and brush actions

- 🎯 **Zoom & Pan**: Pinch to zoom and pan around the canvas

## Tech Stack

- **Flutter 3.x** with null safety
- **State Management**: Riverpod
- **Vector Rendering**: flutter_svg
- **Canvas Drawing**: CustomPainter
- **Storage**: shared_preferences + local file system
- **Subscription**: RevenueCat
- **Ads**: Google AdMob
- **Analytics & Remote Config**: Firebase

## Project Structure

```
lib/
 ├── main.dart
 ├── app.dart
 ├── core/
 │    ├── constants/
 │    ├── theme/
 │    ├── utils/
 │    └── widgets/
 ├── data/
 │    ├── models/
 │    ├── repositories/
 │    └── datasources/
 ├── features/
 │    ├── home/
 │    ├── coloring/
 │    │    ├── coloring_screen.dart
 │    │    ├── coloring_controller.dart
 │    │    ├── coloring_state.dart
 │    │    ├── widgets/
 │    │    └── engine/
 │    ├── gallery/
 │    └── subscription/
 └── services/
      ├── ads_service.dart
      ├── purchase_service.dart
      ├── analytics_service.dart
      └── remote_config_service.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Android Studio / Xcode
- Firebase account
- AdMob account
- RevenueCat account

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd h02_colorfill
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Follow the [CONFIGURATION.md](CONFIGURATION.md) guide
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. Configure AdMob:
   - Update AdMob App IDs in `AndroidManifest.xml` and `Info.plist`
   - Update Ad Unit IDs in `lib/core/constants/app_constants.dart`

5. Configure RevenueCat:
   - Update API key in `lib/core/constants/app_constants.dart`
   - Set up subscription products in RevenueCat dashboard

6. Run the app:
```bash
flutter run
```

## Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for detailed setup instructions for:
- Firebase (Android & iOS)
- AdMob (Android & iOS)
- RevenueCat (Android & iOS)
- Permissions and capabilities

## Building for Production

### Android

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Then archive and upload via Xcode.

## Key Components

### Coloring Engine

The app uses a custom SVG-based coloring engine:

- **SVG Parser**: Parses SVG files and extracts fillable paths
- **Fill Engine**: Handles tap-to-fill operations on vector paths
- **Brush Engine**: Manages freehand brush strokes
- **Undo/Redo Manager**: Tracks actions for undo/redo functionality

### State Management

Uses Riverpod for state management with separate controllers for:
- Home screen (categories and images)
- Coloring screen (coloring state and actions)
- Gallery screen (saved artworks)
- Subscription (purchase flow)

### Services

- **AdsService**: Manages AdMob ads (App Open, Interstitial, Native)
- **PurchaseService**: Handles RevenueCat subscriptions
- **AnalyticsService**: Firebase Analytics events
- **RemoteConfigService**: Firebase Remote Config values

## Monetization

### Subscription Plans

- Weekly subscription
- Monthly subscription
- Yearly subscription (best value)

### Premium Features

- Unlock all premium images
- Access premium color palettes
- Remove all ads
- Unlimited saves
- Advanced brush tools

### Ads (Free Users)

- App Open Ad on launch
- Interstitial Ad on save limit
- Native Ads in image grid

## Performance Optimizations

- Cached parsed SVG paths
- Optimized canvas repaint (only changed paths)
- RepaintBoundary usage for image export
- Memory-efficient undo/redo stack
- Support for low-end devices

## License

This project is licensed under the MIT License.

## Support

For configuration help, see [CONFIGURATION.md](CONFIGURATION.md)

For issues or questions:
- Firebase: https://firebase.google.com/support
- AdMob: https://support.google.com/admob
- RevenueCat: https://docs.revenuecat.com
