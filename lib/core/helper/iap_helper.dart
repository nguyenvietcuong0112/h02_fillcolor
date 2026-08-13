import 'package:flutter/foundation.dart';
import '../../services/share_preference_service.dart';
import '../constants/app_constants.dart';

/// Stub IAPHelper without external in_app_purchase dependencies
class IAPHelper {
  static final ValueNotifier<bool> isAvailable = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  static final ValueNotifier<Map<String, dynamic>> productsMap =
      ValueNotifier<Map<String, dynamic>>({});

  static Future<void> initIAP() async {
    final bool savedIsPremium = await SharedPreferenceService.getIsPremiumUser();
    if (savedIsPremium) {
      AppConstants.isPremiumUser.value = true;
    }
  }

  static Future<void> queryProducts() async {}

  static Future<bool> buyProduct(dynamic productDetails) async {
    return false;
  }

  static Future<void> restorePurchases() async {}

  static void dispose() {}
}
