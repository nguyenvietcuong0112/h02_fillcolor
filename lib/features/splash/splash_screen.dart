import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../../app.dart'; // For MainNavigator
import '../language/language_screen.dart';
import '../intro/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigator();
  }

  Future<void> _checkNavigator() async {
    // Artificial delay for splash effect (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check routing logic
    final languageCode = StorageUtils.languageCode;
    final introSeen = StorageUtils.introSeen;

    if (languageCode == null) {
      // 1. Language not set -> Go to Language Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
    } else if (!introSeen) {
      // 2. Language set but Intro not seen -> Go to Intro Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    } else {
      // 3. All set -> Go to Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigator()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Icon(
              Icons.palette,
              size: 100.w, // Responsive size (or AppDimens.iconXLarge * 3 if you define it)
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20.h),
            Text(
              'ColorFill',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
