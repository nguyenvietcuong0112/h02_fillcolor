import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../intro/intro_screen.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ds_ads/ds_ads.dart';
import '../../ads/ad_constants.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  final bool isFromSettings;
  const LanguageScreen({super.key, this.isFromSettings = false});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _tempSelectedCode;
  bool _isAdProcessDecided = false;

  final List<Map<String, String>> languages = const [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedCode = StorageUtils.languageCode;
  }

  void _onConfirm() async {
    if (_tempSelectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.tr('please_select_language')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isAdProcessDecided) return;

    await ref.read(languageProvider.notifier).setLanguage(_tempSelectedCode!);

    if (!mounted) return;

    if (widget.isFromSettings) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const IntroScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.space12,
                  vertical: AppDimens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.isFromSettings)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        SizedBox(width: AppDimens.space8),
                        Expanded(
                          child: Text(
                            ref.tr('select_language'),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontSize: 28
                                      .sp, // Slightly smaller to fit better in row
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isAdProcessDecided ? _onConfirm : null,
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            size: 32.sp,
                            color: _isAdProcessDecided
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.space8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimens.space12),
                          Text(
                            ref.tr('select_language_desc'),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.space32),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.space8,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: languages.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppDimens.space12),
                        itemBuilder: (context, index) {
                          final lang = languages[index];
                          return _buildLanguageItem(lang);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Native Ad at the bottom
            DSAdNative(
              height: 265.h,
              id: AppAdIds.nativeLanguage,
              onAdLoaded: () {
                if (mounted) {
                  setState(() {
                    _isAdProcessDecided = true;
                  });
                }
              },
              onAdFailed: () {
                if (mounted) {
                  setState(() {
                    _isAdProcessDecided = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> lang) {
    final isSelected = _tempSelectedCode == lang['code'];

    return InkWell(
      onTap: () {
        setState(() {
          _tempSelectedCode = lang['code'];
        });
      },
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.space16,
          horizontal: AppDimens.space20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(lang['flag']!, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: AppDimens.space20),
            Text(
              lang['name']!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
