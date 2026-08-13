import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/share_preference_service.dart';
import '../constants/app_constants.dart';
import 'firebase_helper.dart';

class IAPHelper {
  static const String weeklyProductId = 'com.learnpiano.weekly';
  static const String monthlyProductId = 'com.learnpiano.monthly';

  static final Set<String> productIds = {
    weeklyProductId,
    monthlyProductId,
  };

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static final ValueNotifier<bool> isAvailable = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  static final ValueNotifier<Map<String, ProductDetails>> productsMap =
      ValueNotifier<Map<String, ProductDetails>>({});

  static Future<void> initIAP() async {
    // 1. Restore local premium state first
    final bool savedIsPremium = await SharedPreferenceService.getIsPremiumUser();
    if (savedIsPremium) {
      AppConstants.isPremiumUser.value = true;
    }

    // 2. Check store availability
    try {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      debugPrint("IAP Helper initialized, available: $available");

      if (!available) return;

      // 3. Listen to purchase updates stream
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint("IAP purchaseStream error: $error");
        },
      );

      // 4. Query available products
      await queryProducts();
    } catch (e) {
      debugPrint("IAP init error: $e");
    }
  }

  static Future<void> queryProducts() async {
    try {
      isLoading.value = true;
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('IAP queryProductDetails error: ${response.error}');
      }

      final Map<String, ProductDetails> map = {};
      for (final product in response.productDetails) {
        map[product.id] = product;
        debugPrint('IAP Product found: ${product.id} - ${product.price}');
      }
      productsMap.value = map;
    } catch (e) {
      debugPrint('IAP queryProducts exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  static Future<bool> buyProduct(ProductDetails productDetails) async {
    try {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      isLoading.value = true;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      
      final bool success =
          await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      debugPrint('IAP buyProduct error: $e');
      isLoading.value = false;
      return false;
    }
  }

  static Future<void> restorePurchases() async {
    try {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      isLoading.value = true;
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP restorePurchases error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          isLoading.value = false;
          debugPrint('IAP error: ${purchaseDetails.error}');
          FirebaseHelper.logEventPurchaseError(
            purchase: purchaseDetails,
            isGoogle: defaultTargetPlatform == TargetPlatform.android,
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          isLoading.value = false;
          _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          isLoading.value = false;
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    AppConstants.isPremiumUser.value = true;
    SharedPreferenceService.setIsPremiumUser(true);

    final product = productsMap.value[purchaseDetails.productID];
    final bool isGoogle = defaultTargetPlatform == TargetPlatform.android;

    if (product != null) {
      if (purchaseDetails.productID == weeklyProductId) {
        AdjustHelper().trackEventBuyWeeklySuccess(
          purchase: purchaseDetails,
          productDetail: product,
        );
        FirebaseHelper.logEventPurchaseSuccessWeekly(
          purchase: purchaseDetails,
          productDetail: product,
          isGoogle: isGoogle,
        );
      } else if (purchaseDetails.productID == monthlyProductId) {
        AdjustHelper().trackEventBuyMonthlySuccess(
          purchase: purchaseDetails,
          productDetail: product,
        );
        FirebaseHelper.logEventPurchaseSuccessMonthly(
          purchase: purchaseDetails,
          productDetail: product,
          isGoogle: isGoogle,
        );
      }

      FirebaseHelper.logInAppPurchaseCustom(
        purchase: purchaseDetails,
        productDetail: product,
        isGoogle: isGoogle,
      );
    }
    debugPrint('IAP Purchase successful: ${purchaseDetails.productID}');
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
