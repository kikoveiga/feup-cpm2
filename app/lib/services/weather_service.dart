import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static String _apiKey = dotenv.env['API_KEY']!;
  static const String _baseUrl = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline';

  static Future<Weather?> fetchWeather(String city) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final url = '$_baseUrl/$city,PT/$today?include=current&iconSet=icons2&unitGroup=metric&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        print('Erro na resposta: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar clima: $e');
      return null;
    }
  }
}
