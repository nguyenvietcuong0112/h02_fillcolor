import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../language/language_screen.dart';
import '../intro/intro_screen.dart';
import '../../app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ds_ads/ds_ads.dart';
import '../../ads/ad_constants.dart';
import '../../services/remote_config_service.dart';
import '../../di/dependency_injection.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/utils/thumbnail_helper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isInitStarted = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitStarted) {
      _isInitStarted = true;
      _bootstrapApp();
    }
  }

  Future<void> _bootstrapApp() async {
    debugPrint('SplashScreen: Starting Bootstrap...');

    // 1. Storage (Essential)
    try {
      debugPrint('SplashScreen: Init Storage...');
      await StorageUtils.init().timeout(const Duration(seconds: 5));
      debugPrint('SplashScreen: Storage Done');
    } catch (e) {
      debugPrint('SplashScreen: Storage Timeout/Error: $e');
    }

    // 2. DI (Essential for AdManager)
    try {
      debugPrint('SplashScreen: Init DI...');
      await configureDependencies('dev').timeout(const Duration(seconds: 7));
      debugPrint('SplashScreen: DI Done');
    } catch (e) {
      debugPrint('SplashScreen: DI Timeout/Error: $e');
    }

    // 3. Firebase & Remote Config
    try {
      debugPrint('SplashScreen: Init Firebase...');
      await Firebase.initializeApp().timeout(const Duration(seconds: 5));
      debugPrint('SplashScreen: Firebase Done');

      debugPrint('SplashScreen: Init Remote Config...');
      await RemoteConfigService.instance.initialize().timeout(
        const Duration(seconds: 5),
      );
      debugPrint('SplashScreen: Remote Config Done');
    } catch (e) {
      debugPrint('SplashScreen: Firebase/RC error: $e');
    }

    // 4. Ads
    try {
      debugPrint('SplashScreen: Init Ads...');
      final ads = getIt<AdManager>();
      await ads.init().timeout(const Duration(seconds: 5));
      ads.loadInterstitialAd();
      debugPrint('SplashScreen: Ads Done');
    } catch (e) {
      debugPrint('SplashScreen: Ads error: $e');
    }

    // Background task
    ThumbnailHelper.clearAllThumbnails();

    debugPrint('SplashScreen: Bootstrap Complete');
    _checkNavigator();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkNavigator() async {
    // Ensure splash is visible for at least 2 seconds total
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    void navigate() {
      if (!mounted) return;

      final languageCode = StorageUtils.languageCode;
      final introSeen = StorageUtils.introSeen;

      if (languageCode == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        );
      } else if (!introSeen) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigator()),
        );
      }
    }

    // Try showing splash ad if ready, otherwise navigate direct
    try {
      DSAdInterstitial.show(
        id: AppAdIds.interstitialSplash,
        onAdClosed: navigate,
      );
    } catch (e) {
      navigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFFFA06B),
              Color(0xFFFFC371),
              Color(0xFF9B59B6),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        // Use hardcoded app name for bootstrap safety
                        'ColorFlow',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Coloring Book',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
