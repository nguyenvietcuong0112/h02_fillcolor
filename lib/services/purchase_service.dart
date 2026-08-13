import '../core/utils/storage_utils.dart';

/// Stub Service for managing subscriptions without external IAP dependencies
class PurchaseService {
  static PurchaseService? _instance;
  static PurchaseService get instance => _instance ??= PurchaseService._();

  PurchaseService._();

  /// Initialize
  Future<void> initialize() async {
    await refreshSubscriptionStatus();
  }

  /// Refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    // No-op
  }

  /// Get available packages
  Future<List<dynamic>> getPackages() async {
    return [];
  }

  /// Purchase a package
  Future<bool> purchasePackage(dynamic package) async {
    return false;
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    return false;
  }

  /// Check if user is premium
  bool get isPremium {
    return StorageUtils.isPremium;
  }
}
