import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static SharedPreferences? _prefs;

  // Key definitions
  static const String keyIsNoFirstOpenApp = 'is_no_first_open_app';
  static const String keySelectedLanguageCode = 'selected_language_code';
  static const String keySelectedThemeId = 'SELECTED_THEME_ID';
  static const String keySelectedThemeResName = 'SELECTED_THEME_RES_NAME';
  static const String keySelectedInstrument = 'SELECTED_INSTRUMENT';
  static const String keyAudioVolume = 'AUDIO_VOLUME';
  static const String keyIsPremiumUser = 'IS_PREMIUM_USER';
  static const String keyUnlockedLessons = 'UNLOCKED_LESSONS';

  // --- Unlocked Lessons ---
  static Future<List<String>> getUnlockedLessons() async {
    try {
      final prefs = await getInstance();
      return prefs.getStringList(keyUnlockedLessons) ?? [];
    } catch (e) {
      debugPrint('SharedPreferenceService getUnlockedLessons error: $e');
      return [];
    }
  }

  static Future<bool> unlockLesson(String songId) async {
    try {
      final prefs = await getInstance();
      final currentList = prefs.getStringList(keyUnlockedLessons) ?? [];
      if (!currentList.contains(songId)) {
        currentList.add(songId);
        return await prefs.setStringList(keyUnlockedLessons, currentList);
      }
      return true;
    } catch (e) {
      debugPrint('SharedPreferenceService unlockLesson error: $e');
      return false;
    }
  }

  // --- Premium User ---
  static Future<bool> getIsPremiumUser() async {
    try {
      return (await getInstance()).getBool(keyIsPremiumUser) ?? false;
    } catch (e) {
      debugPrint('SharedPreferenceService getIsPremiumUser error: $e');
      return false;
    }
  }

  static Future<bool> setIsPremiumUser(bool value) async {
    try {
      return await (await getInstance()).setBool(keyIsPremiumUser, value);
    } catch (e) {
      debugPrint('SharedPreferenceService setIsPremiumUser error: $e');
      return false;
    }
  }

  // --- Selected Language ---
  static Future<String> getSelectedLanguageCode() async {
    try {
      return (await getInstance()).getString(keySelectedLanguageCode) ?? 'en';
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedLanguageCode error: $e');
      return 'en';
    }
  }

  static Future<bool> setSelectedLanguageCode(String code) async {
    try {
      return await (await getInstance()).setString(keySelectedLanguageCode, code);
    } catch (e) {
      debugPrint('SharedPreferenceService setSelectedLanguageCode error: $e');
      return false;
    }
  }

  /// Ensures SharedPreferences instance is initialized and cached.
  static Future<SharedPreferences> getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- First Open App ---
  static Future<bool> getIsNoFirstOpenApp() async {
    try {
      return (await getInstance()).getBool(keyIsNoFirstOpenApp) ?? false;
    } catch (e) {
      debugPrint('SharedPreferenceService getIsNoFirstOpenApp error: $e');
      return false;
    }
  }

  static Future<bool> setIsNoFirstOpenApp(bool value) async {
    try {
      return await (await getInstance()).setBool(keyIsNoFirstOpenApp, value);
    } catch (e) {
      debugPrint('SharedPreferenceService setIsNoFirstOpenApp error: $e');
      return false;
    }
  }

  // --- Selected Theme ---
  static Future<String> getSelectedThemeResName() async {
    try {
      return (await getInstance()).getString(keySelectedThemeResName) ?? 'theme_1';
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedThemeResName error: $e');
      return 'theme_1';
    }
  }

  static Future<int?> getSelectedThemeId() async {
    try {
      return (await getInstance()).getInt(keySelectedThemeId);
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedThemeId error: $e');
      return null;
    }
  }

  static Future<bool> setSelectedTheme(String resName, int id) async {
    try {
      final prefs = await getInstance();
      await prefs.setInt(keySelectedThemeId, id);
      return await prefs.setString(keySelectedThemeResName, resName);
    } catch (e) {
      debugPrint('SharedPreferenceService setSelectedTheme error: $e');
      return false;
    }
  }

  static Future<bool> isThemeDownloaded(String resName) async {
    try {
      if (resName == 'theme_1' || resName == 'anime_1' || resName == 'theme1') return true;
      final prefs = await getInstance();
      return prefs.getBool('THEME_DOWNLOADED_$resName') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setThemeDownloaded(String resName) async {
    try {
      final prefs = await getInstance();
      return await prefs.setBool('THEME_DOWNLOADED_$resName', true);
    } catch (e) {
      return false;
    }
  }

  // --- Audio / Instrument ---
  static Future<String> getSelectedInstrument() async {
    try {
      return (await getInstance()).getString(keySelectedInstrument) ?? 'bright';
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedInstrument error: $e');
      return 'bright';
    }
  }

  static Future<bool> setSelectedInstrument(String instrumentFolder) async {
    try {
      return await (await getInstance()).setString(keySelectedInstrument, instrumentFolder);
    } catch (e) {
      debugPrint('SharedPreferenceService setSelectedInstrument error: $e');
      return false;
    }
  }

  static Future<double> getAudioVolume() async {
    try {
      return (await getInstance()).getDouble(keyAudioVolume) ?? 0.8;
    } catch (e) {
      debugPrint('SharedPreferenceService getAudioVolume error: $e');
      return 0.8;
    }
  }

  static Future<bool> setAudioVolume(double volume) async {
    try {
      return await (await getInstance()).setDouble(keyAudioVolume, volume);
    } catch (e) {
      debugPrint('SharedPreferenceService setAudioVolume error: $e');
      return false;
    }
  }

  // --- Generic Helpers ---
  static Future<bool> setString(String key, String value) async {
    return (await getInstance()).setString(key, value);
  }

  static Future<String?> getString(String key) async {
    return (await getInstance()).getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return (await getInstance()).setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    return (await getInstance()).getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return (await getInstance()).setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    return (await getInstance()).getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return (await getInstance()).setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    return (await getInstance()).getDouble(key);
  }

  // --- Lesson High Scores / Stars ---
  static const String keyLessonStarsPrefix = 'LESSON_STARS_';
  static const String keyCompletedSongsList = 'KEY_COMPLETED_SONGS_LIST';

  static Future<int> getLessonStars(String lessonId) async {
    try {
      final prefs = await getInstance();
      return prefs.getInt('$keyLessonStarsPrefix$lessonId') ?? 0;
    } catch (e) {
      debugPrint('SharedPreferenceService getLessonStars error: $e');
      return 0;
    }
  }

  static Future<bool> saveLessonStars(String lessonId, int stars) async {
    try {
      final prefs = await getInstance();
      final currentMax = prefs.getInt('$keyLessonStarsPrefix$lessonId') ?? 0;
      if (stars > currentMax) {
        return await prefs.setInt('$keyLessonStarsPrefix$lessonId', stars);
      }
      return true;
    } catch (e) {
      debugPrint('SharedPreferenceService saveLessonStars error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCompletedSongsList() async {
    try {
      final prefs = await getInstance();
      final String? jsonStr = prefs.getString(keyCompletedSongsList);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonStr);
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('SharedPreferenceService getCompletedSongsList error: $e');
    }
    return [];
  }

  static Future<bool> saveCompletedSongRecord({
    required String songId,
    required String titleName,
    required String authorName,
    required String duration,
    required String lessonsData,
    required int level,
    required int stars,
    required int score,
    required double accuracy,
  }) async {
    try {
      final prefs = await getInstance();
      final currentList = await getCompletedSongsList();

      final existingIndex = currentList.indexWhere((item) => item['songId'].toString() == songId);
      final newRecord = {
        'songId': songId,
        'titleName': titleName,
        'authorName': authorName,
        'duration': duration,
        'lessonsData': lessonsData,
        'level': level,
        'stars': stars,
        'score': score,
        'accuracy': accuracy.round(),
        'completedAt': DateTime.now().toIso8601String(),
      };

      if (existingIndex >= 0) {
        final oldStars = (currentList[existingIndex]['stars'] as num?)?.toInt() ?? 0;
        if (stars >= oldStars) {
          currentList[existingIndex] = newRecord;
        }
      } else {
        currentList.insert(0, newRecord);
      }

      return await prefs.setString(keyCompletedSongsList, json.encode(currentList));
    } catch (e) {
      debugPrint('SharedPreferenceService saveCompletedSongRecord error: $e');
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    return (await getInstance()).remove(key);
  }

  static Future<bool> clear() async {
    return (await getInstance()).clear();
  }
}

typedef SharedPreferenceUtils = SharedPreferenceService;
typedef ShapreferenceUtils = SharedPreferenceService;
