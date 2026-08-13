import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/firebase_remote_config_service.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/storage_utils.dart';
import '../../core/widgets/coloring_widgets.dart';
import '../intro/intro_screen.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  final bool isFromSettings;
  const LanguageScreen({super.key, this.isFromSettings = false});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _tempSelectedCode;
  int _selectedIndex = -1;
  bool _isShowClickAds = false;
  bool _isShouldShowNext = true;
  final bool _isShouldShowAds = true;
  bool _isLoading = false;
  bool _canClick = false;

  Timer? _nextDelayTimer;
  Timer? _loadingTimer;
  StreamSubscription? _adEventSubscription;

  final List<Map<String, String>> languages = const [
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'fil', 'name': 'Filipino', 'flag': '🇵🇭'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedCode = StorageUtils.languageCode;
    _selectedIndex = languages.indexWhere((l) => l['code'] == _tempSelectedCode);
    if (_selectedIndex < 0) _selectedIndex = 0;

    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);

    _isLoading = true;
    _canClick = false;
    _isShouldShowNext = true;

    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _canClick = true;
        });
      }
    });

    _listenAdEvents();
  }

  void _listenAdEvents() {
    _adEventSubscription?.cancel();
    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == MyAdIdName.nativeLanguageClick.getId) {
        if (event.type == AdEventType.adLoaded ||
            event.type == AdEventType.adFailedToLoad) {
          _nextDelayTimer?.cancel();
          _nextDelayTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted && !_isShouldShowNext) {
              setState(() {
                _isShouldShowNext = true;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nextDelayTimer?.cancel();
    _loadingTimer?.cancel();
    _adEventSubscription?.cancel();
    super.dispose();
  }

  void _onSelectItem(int index, String code) {
    if (!_canClick || _isLoading) return;

    if (_isShowClickAds) {
      setState(() {
        _selectedIndex = index;
        _tempSelectedCode = code;
        _isShouldShowNext = true;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
      _tempSelectedCode = code;
      _isShowClickAds = true;
      _isShouldShowNext = false;
    });

    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isShouldShowNext) {
        setState(() {
          _isShouldShowNext = true;
        });
      }
    });
  }

  void _onAdImpression() {
    if (_isShouldShowNext) return;

    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isShouldShowNext) {
        setState(() {
          _isShouldShowNext = true;
        });
      }
    });
  }

  void _onConfirm() async {
    if (!_canClick || _isLoading) return;
    if (_tempSelectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.tr('please_select_language')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isShouldShowNext) return;

    await ref.read(languageProvider.notifier).setLanguage(_tempSelectedCode!);

    if (!mounted) return;

    if (widget.isFromSettings) {
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      Navigator.of(context).pop();
      return;
    }

    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const IntroScreen()));
  }

  bool _shouldShowLanguageAd() {
    if (AppConstants.isPremiumUser.value ||
        widget.isFromSettings ||
        !_isShouldShowAds) {
      return false;
    }
    if (_isShowClickAds) {
      return FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language_click,
      );
    } else {
      return FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language,
      );
    }
  }

  Widget _buildNativeAd() {
    if (!_shouldShowLanguageAd()) {
      return const SizedBox.shrink();
    }

    return _isShowClickAds
        ? EasyNativeAdHigh(
            key: const ValueKey('nativeLanguageClick'),
            factoryId: NativeFactoryId.nativeMedia2,
            adId: MyAdIdName.nativeLanguageClick.getId,
            adIdHigh: MyAdIdName.nativeLanguageClickHigh.getId,
            adIdName: MyAdIdName.nativeLanguageClick,
            adIdNameHigh: MyAdIdName.nativeLanguageClickHigh,
            height: AdDimen.mediumNativeHeight,
            onImpression: _onAdImpression,
          )
        : EasyNativeAdHigh(
            key: const ValueKey('nativeLanguage'),
            factoryId: NativeFactoryId.nativeMedia,
            adId: MyAdIdName.nativeLanguage.getId,
            adIdHigh: MyAdIdName.nativeLanguageHigh.getId,
            adIdName: MyAdIdName.nativeLanguage,
            adIdNameHigh: MyAdIdName.nativeLanguageHigh,
            height: AdDimen.mediumNativeHeight,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                              RoundIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.pop(context),
                              ),
                            SizedBox(width: AppDimens.space8),
                            Expanded(
                              child: Text(
                                ref.tr('select_language'),
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            SizedBox(
                              width: 48.w,
                              height: 48.w,
                              child: !_isShouldShowNext || _isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.w,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: _onConfirm,
                                      icon: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 32.sp,
                                        color: Theme.of(context).primaryColor,
                                      ),
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
                              Text(
                                ref.tr('select_language_desc'),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppDimens.space16),
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
                              return _buildLanguageItem(index, lang);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Native Ad at the bottom
                _buildNativeAd(),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(int index, Map<String, String> lang) {
    final isSelected = _tempSelectedCode == lang['code'];

    return InkWell(
      onTap: () => _onSelectItem(index, lang['code']!),
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
