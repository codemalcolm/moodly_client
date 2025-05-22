import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastieRepository {
  Future<List<Map<String, dynamic>>> loadAllFastiesFromAssets() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/fasties.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<SharedPreferences> getPrefs() async => SharedPreferences.getInstance();

  Future<Set<String>> loadSelectedCategories() async {
    final prefs = await getPrefs();
    final selected =
        prefs.getStringList('selectedFastiesCategories') ??
        ['exercise', 'hydration', 'clean up'];
    return selected.toSet();
  }

  Future<List<Map<String, dynamic>>> loadFasties(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(key);
    if (stored != null) {
      return List<Map<String, dynamic>>.from(json.decode(stored));
    }
    return [];
  }

  Future<List<Map<String, dynamic>>?> loadStoredFasties(String key) async {
    final prefs = await getPrefs();
    final stored = prefs.getString(key);
    if (stored != null) {
      return List<Map<String, dynamic>>.from(json.decode(stored));
    }
    return null;
  }

  Future<void> saveFasties(
    String key,
    List<Map<String, dynamic>> fasties,
  ) async {
    final prefs = await getPrefs();
    await prefs.setString(key, json.encode(fasties));
  }

  Future<List<String>> loadCompletedFasties(String key) async {
    final prefs = await getPrefs();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveCompletedFasties(String key, List<String> completed) async {
    final prefs = await getPrefs();
    await prefs.setStringList(key, completed);
  }
}
