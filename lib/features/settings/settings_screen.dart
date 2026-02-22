import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/localization/app_localizations.dart';
import '../language/language_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          ref.tr('settings'),
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(ref.tr('language')),
            SizedBox(height: 16.h),
            _buildLanguageButton(context, ref),
            
            SizedBox(height: 40.h),
            _buildSectionHeader(ref.tr('info')),
            SizedBox(height: 16.h),
            _buildActionCard(
              context, 
              ref.tr('privacy_policy'), 
              Icons.privacy_tip_rounded,
              () => _launchUrl('https://pheejstudio.vercel.app/policy'), // Replace with actual URL
            ),
            _buildActionCard(
              context, 
              ref.tr('share_app'), 
              Icons.share_rounded,
              () => _shareApp(),
            ),
            _buildActionCard(
              context, 
              ref.tr('rate_app'), 
              Icons.star_rounded,
              () => _rateApp(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final languages = {
      'en': {'name': 'English', 'flag': '🇺🇸'},
      'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳'},
      'es': {'name': 'Español', 'flag': '🇪🇸'},
      'fr': {'name': 'Français', 'flag': '🇫🇷'},
      'ja': {'name': '日本語', 'flag': '🇯🇵'},
      'ko': {'name': '한국어', 'flag': '🇰🇷'},
    };
    
    final langInfo = languages[currentLang] ?? languages['en']!;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguageScreen(isFromSettings: true)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50]!.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Text(langInfo['flag']!, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 16.w),
            Text(
              langInfo['name']!,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey[900],
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey[300], size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.blueGrey[50]!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(icon, color: Colors.blueGrey[400], size: 22.sp),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: Colors.blueGrey[300], size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareApp() async {
    // Replace with actual app store links
    const String appLink = 'Check out this amazing coloring app: https://example.com/colorflow';
    await Share.share(appLink);
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      // Fallback to store page if requestReview is not available
      // await inAppReview.openStoreListing(appStoreId: '...', microsoftStoreId: '...');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
        color: Colors.blueGrey[300],
        letterSpacing: 2,
      ),
    );
  }

}

