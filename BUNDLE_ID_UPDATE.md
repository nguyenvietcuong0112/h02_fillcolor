# Bundle ID Update Summary

Bundle ID đã được cập nhật thành: **`com.fillcolor.coloringbook.paint.colorart`**

## Các file đã được cập nhật:

### Android
- ✅ `android/app/build.gradle.kts` - namespace và applicationId
- ✅ `android/app/src/main/kotlin/com/fillcolor/coloringbook/paint/colorart/MainActivity.kt` - package name
- ✅ Thư mục cũ `com/example/h02_colorfill` đã được xóa

### iOS
- ✅ `ios/Runner.xcodeproj/project.pbxproj` - PRODUCT_BUNDLE_IDENTIFIER (tất cả build configurations)
- ✅ `ios/Runner/Info.plist` - Đã có sẵn cấu hình

### macOS
- ✅ `macos/Runner.xcodeproj/project.pbxproj` - PRODUCT_BUNDLE_IDENTIFIER
- ✅ `macos/Runner/Configs/AppInfo.xcconfig` - PRODUCT_BUNDLE_IDENTIFIER

### Linux
- ✅ `linux/CMakeLists.txt` - APPLICATION_ID

### Configuration Files
- ✅ `android/app/google-services.json.example` - package_name
- ✅ `ios/Runner/GoogleService-Info.plist.example` - BUNDLE_ID
- ✅ `CONFIGURATION.md` - Hướng dẫn cấu hình

## Bước tiếp theo:

1. **Firebase Setup**:
   - Tạo Firebase project
   - Thêm Android app với package name: `com.fillcolor.coloringbook.paint.colorart`
   - Thêm iOS app với Bundle ID: `com.fillcolor.coloringbook.paint.colorart`
   - Tải `google-services.json` → đặt vào `android/app/`
   - Tải `GoogleService-Info.plist` → đặt vào `ios/Runner/`

2. **AdMob Setup**:
   - Tạo app trong AdMob Console với bundle ID mới
   - Cập nhật App ID trong `AndroidManifest.xml` và `Info.plist`
   - Cập nhật Ad Unit IDs trong `lib/core/constants/app_constants.dart`

3. **RevenueCat Setup**:
   - Thêm app mới với bundle ID: `com.fillcolor.coloringbook.paint.colorart`
   - Cập nhật API key trong `lib/core/constants/app_constants.dart`

4. **Build & Test**:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   cd ios && pod install && cd ..
   flutter run
   ```

## Lưu ý:

- Đảm bảo bundle ID này đã được đăng ký trong:
  - Google Play Console (cho Android)
  - App Store Connect (cho iOS)
  - Firebase Console
  - AdMob Console
  - RevenueCat Dashboard

