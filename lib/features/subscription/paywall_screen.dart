import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/widgets/loading_widget.dart';
import '../../services/purchase_service.dart';
import '../../services/analytics_service.dart';

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
            const SnackBar(content: Text('Subscription successful! Enjoy premium features.')),
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
            const SnackBar(content: Text('Purchases restored successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No purchases found to restore.')),
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
        title: const Text('Go Premium'),
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
                  const Text(
                    'Unlock Premium Features',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get unlimited access to all coloring pages and features',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Features
                  _FeatureItem(icon: Icons.lock_open, text: 'Unlock all premium images'),
                  _FeatureItem(icon: Icons.palette, text: 'Access premium color palettes'),
                  _FeatureItem(icon: Icons.block, text: 'Remove all ads'),
                  _FeatureItem(icon: Icons.save, text: 'Unlimited saves'),
                  _FeatureItem(icon: Icons.brush, text: 'Advanced brush tools'),
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
                    const Text(
                      'No subscription packages available. Please try again later.',
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
                    child: const Text('Restore Purchases'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.',
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
class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;

  const _PackageCard({
    required this.package,
    this.onTap,
  });

  String _getPackageName(String identifier) {
    if (identifier.contains('weekly')) return 'Weekly';
    if (identifier.contains('monthly')) return 'Monthly';
    if (identifier.contains('yearly')) return 'Yearly';
    return 'Premium';
  }

  @override
  Widget build(BuildContext context) {
    final packageName = _getPackageName(package.identifier);
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
                    if (packageName == 'Yearly')
                      const Text(
                        'Best Value',
                        style: TextStyle(color: Colors.green, fontSize: 12),
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

