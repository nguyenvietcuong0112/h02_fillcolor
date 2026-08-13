import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsService {
  static const String keyIsOrganic = 'is_organic';
  static RxBool isOrganic = false.obs;

  void init() {
    debugPrint('AdsService initialized');
    initOrganic();
  }

  static Future<void> initOrganic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool value = prefs.getBool(keyIsOrganic) ?? false;
      isOrganic.value = value;
    } catch (e) {
      isOrganic.value = false;
    }
  }

  static Future<void> setIsOrganic(bool value) async {
    try {
      isOrganic.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyIsOrganic, value);
    } catch (e) {
      debugPrint('Error setting isOrganic in AdsService: $e');
    }
  }

  static Future<bool> isOrganicAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool value = prefs.getBool(keyIsOrganic) ?? false;
      isOrganic.value = value;
      return value;
    } catch (e) {
      return false;
    }
  }
}
