import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/widgets/loading_widget.dart';
import '../../services/purchase_service.dart';
import '../../services/analytics_service.dart';
import '../../core/localization/app_localizations.dart';

/// Paywall screen
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final packages = await PurchaseService.instance.getPackages();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    try {
      AnalyticsService.instance.logSubscriptionStarted(package.identifier);

      final success = await PurchaseService.instance.purchasePackage(package);

      if (success) {
        AnalyticsService.instance.logSubscriptionCompleted(package.identifier);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.tr('subs_success'))),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    try {
      final success = await PurchaseService.instance.restorePurchases();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.tr('restore_success'))),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.tr('restore_failed'))),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(ref.tr('go_premium')),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(Icons.palette, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    ref.tr('unlock_premium'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('premium_desc'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Features
                  _FeatureItem(icon: Icons.lock_open, text: ref.tr('unlock_all_images')),
                  _FeatureItem(icon: Icons.palette, text: ref.tr('access_premium_palettes')),
                  _FeatureItem(icon: Icons.block, text: ref.tr('remove_ads')),
                  _FeatureItem(icon: Icons.save, text: ref.tr('unlimited_saves')),
                  _FeatureItem(icon: Icons.brush, text: ref.tr('advanced_brush')),
                  const SizedBox(height: 32),
                  // Packages
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_packages.isEmpty)
                    Text(
                      ref.tr('no_packages'),
                      textAlign: TextAlign.center,
                    )
                  else
                    ..._packages.map((package) => _PackageCard(
                          package: package,
                          onTap: _isPurchasing ? null : () => _purchasePackage(package),
                        )),
                  const SizedBox(height: 16),
                  // Restore purchases
                  TextButton(
                    onPressed: _isPurchasing ? null : _restorePurchases,
                    child: Text(ref.tr('restore_purchases')),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('subs_disclaimer'),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

/// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Package card widget
class _PackageCard extends ConsumerWidget {
  final Package package;
  final VoidCallback? onTap;

  const _PackageCard({
    required this.package,
    this.onTap,
  });

  String _getPackageName(String identifier, WidgetRef ref) {
    if (identifier.contains('weekly')) return ref.tr('weekly');
    if (identifier.contains('monthly')) return ref.tr('monthly');
    if (identifier.contains('yearly')) return ref.tr('yearly');
    return 'Premium';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageName = _getPackageName(package.identifier, ref);
    final price = package.storeProduct.priceString;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (package.identifier.contains('yearly'))
                      Text(
                        ref.tr('best_value'),
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

