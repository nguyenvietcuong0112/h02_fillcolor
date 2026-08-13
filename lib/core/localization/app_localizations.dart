import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'languages/ar.dart';
import 'languages/bn.dart';
import 'languages/en.dart';
import 'languages/es.dart';
import 'languages/fil.dart';
import 'languages/fr.dart';
import 'languages/hi.dart';
import 'languages/id.dart';
import 'languages/pt.dart';
import 'languages/ru.dart';
import 'languages/tr.dart';
import 'languages/vi.dart';

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
    'ar': ar,
    'bn': bn,
    'en': en,
    'es': es,
    'fil': fil,
    'fr': fr,
    'hi': hi,
    'id': id,
    'pt': pt,
    'ru': ru,
    'tr': tr,
    'vi': vi,
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
