import 'package:shared_preferences/shared_preferences.dart';

class CityStorage {
  static const _key = 'favorite_cities';

  static Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(_key) ?? [];
    if (!cities.contains(city)) {
      cities.add(city);
      await prefs.setStringList(_key, cities);
    }
  }

  static Future<void> removeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(_key) ?? [];
    cities.remove(city);
    await prefs.setStringList(_key, cities);
  }
}
