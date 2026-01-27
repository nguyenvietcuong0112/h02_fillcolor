import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../intro/intro_screen.dart';
import '../../app.dart'; // For MainNavigator
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  final List<Map<String, String>> languages = const [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  void _onLanguageSelected(BuildContext context, String code) async {
    await StorageUtils.setLanguageCode(code);
    
    if (!context.mounted) return;

    // Check if intro is seen to determine next screen
    if (StorageUtils.introSeen) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigator()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.space20, vertical: AppDimens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Language',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black),
              ),
              SizedBox(height: AppDimens.space12),
              Text(
                'Select your preferred language to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: AppDimens.space32),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppDimens.space12),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return _buildLanguageItem(context, lang);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, Map<String, String> lang) {
    return InkWell(
      onTap: () => _onLanguageSelected(context, lang['code']!),
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space16, horizontal: AppDimens.space20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(color: Colors.grey[200]!), // Can keep or move to theme
        ),
        child: Row(
          children: [
            Text(
              lang['flag']!,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: AppDimens.space20),
            Text(
              lang['name']!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: AppDimens.iconSmall,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
