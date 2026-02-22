import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'languages/en.dart';
import 'languages/vi.dart';
import 'languages/es.dart';

import '../utils/storage_utils.dart';

/// Language state provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(StorageUtils.languageCode ?? 'en');

  Future<void> setLanguage(String lang) async {
    await StorageUtils.setLanguageCode(lang);
    state = lang;
  }
}

class AppLocalizations {
  final String currentLanguage;

  AppLocalizations(this.currentLanguage);

  static const Map<String, Map<String, String>> _translationsArr = {
    'en': en,
    'vi': vi,
    'es': es,
  };

  String translate(String key) {
    return _translationsArr[currentLanguage]?[key] ?? _translationsArr['en']![key] ?? key;
  }

  static AppLocalizations of(WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return AppLocalizations(lang);
  }
}

extension LocalizationShort on WidgetRef {
  String tr(String key) {
    return AppLocalizations.of(this).translate(key);
  }
}
