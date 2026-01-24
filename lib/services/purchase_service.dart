import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/storage_utils.dart';

/// Service for managing RevenueCat subscriptions
class PurchaseService {
  static PurchaseService? _instance;
  static PurchaseService get instance => _instance ??= PurchaseService._();

  PurchaseService._();

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;

  /// Initialize RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(AppConstants.revenueCatApiKey),
    );

    // Check current subscription status
    await refreshSubscriptionStatus();

    _isInitialized = true;
  }

  /// Refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      final isPremium = _customerInfo?.entitlements.active[AppConstants.entitlementPremium] != null;
      await StorageUtils.setPremium(isPremium);
    } catch (e) {
      // Handle error
    }
  }

  /// Get available packages
  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      final isPremium = purchaserInfo.entitlements.active[AppConstants.entitlementPremium] != null;
      await StorageUtils.setPremium(isPremium);
      await refreshSubscriptionStatus();
      return isPremium;
    } catch (e) {
      // User cancelled or error occurred
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      final isPremium = _customerInfo?.entitlements.active[AppConstants.entitlementPremium] != null;
      await StorageUtils.setPremium(isPremium);
      return isPremium;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is premium
  bool get isPremium {
    return StorageUtils.isPremium;
  }

  /// Get customer info
  CustomerInfo? get customerInfo => _customerInfo;
}

