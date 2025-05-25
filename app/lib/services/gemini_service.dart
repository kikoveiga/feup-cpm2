import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_KEY'] ?? '';
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<String> getAIAdviceFromWeather(Map<String, dynamic> weatherJson,String cityName) async {
    final prompt = '''
I'm developing a mobile weather app. Here is the current weather data in JSON format:

$weatherJson, city: $cityName

Based on this data, give me a short, helpful, and clear piece of advice that I can show to the user inside the app. The advice should be related to the weather. Don't include any greetings or introductions, just the advice itself. Give good advice to the user. Don't give the output with quotes. Start the advice referencing the city name but in a natural way, like "In $cityName, ..." or other similar phrases.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No advice returned.';
    } catch (e) {
      throw Exception('Failed to fetch AI advice: $e');
    }
  }
}
