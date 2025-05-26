import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/daily_weather.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['API_KEY']!;
  static const String _baseUrl =
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline';

  static Future<Weather?> fetchWeather(String city) async {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    final todayStr = today.toIso8601String().split('T').first;
    final tomorrowStr = tomorrow.toIso8601String().split('T').first;

    final url =
        '$_baseUrl/$city,PT/$todayStr/$tomorrowStr?include=days,hours&iconSet=icons2&unitGroup=metric&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<DailyWeather>> fetchWeeklyWeather(String city) async {
    final today = DateTime.now();
    final lastWeek = today.subtract(const Duration(days: 6));

    final todayStr = today.toIso8601String().split('T').first;
    final lastWeekStr = lastWeek.toIso8601String().split('T').first;

    final url =
        '$_baseUrl/$city,PT/$lastWeekStr/$todayStr?include=days&unitGroup=metric&iconSet=icons2&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> days = data['days'];
        return days.map((d) => DailyWeather.fromJson(d)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
