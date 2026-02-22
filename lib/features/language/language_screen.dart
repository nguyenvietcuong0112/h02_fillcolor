import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../intro/intro_screen.dart';
import '../../app.dart'; // For MainNavigator
import '../../core/theme/app_dimens.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageScreen extends ConsumerWidget {
  final bool isFromSettings;
  const LanguageScreen({super.key, this.isFromSettings = false});

  final List<Map<String, String>> languages = const [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  void _onLanguageSelected(BuildContext context, WidgetRef ref, String code) async {
    await ref.read(languageProvider.notifier).setLanguage(code);
    
    if (!context.mounted) return;

    if (isFromSettings) {
      Navigator.of(context).pop();
      return;
    }

    // Check if intro is seen to determine next screen
    // if (StorageUtils.introSeen) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const MainNavigator()),
    //   );
    // } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    // }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isFromSettings ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.space20, vertical: AppDimens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.tr('select_language'),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: AppDimens.space12),
              Text(
                ref.tr('select_language_desc'), // I'll add this to lang files
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
                    return _buildLanguageItem(context, ref, lang);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, WidgetRef ref, Map<String, String> lang) {
    return InkWell(
      onTap: () => _onLanguageSelected(context, ref, lang['code']!),
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space16, horizontal: AppDimens.space20),
        decoration: BoxDecoration(
          color: Colors.white,
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
