import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/get_start_screen.dart';
import 'package:dcdg/dcdg.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const GetStartedScreen(), // Mostra esta primeiro
    );
  }
}
