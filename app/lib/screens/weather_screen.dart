import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';

class WeatherScreen extends StatefulWidget {
  final String city;

  const WeatherScreen({super.key, required this.city});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather?> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = WeatherService.fetchWeather(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima em ${widget.city}'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Weather?>(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else if (snapshot.hasData) {
            final weather = snapshot.data;

            if (weather != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/icons2/${weather.icon}.png', // URL corrigida
                      width: 100,
                      height: 100,
                    ),

                    SizedBox(height: 20),
                    Text(
                      'Temperatura: ${weather.temp}°C',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Condições: ${weather.conditions}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('Sem dados do clima para exibir.'));
            }
          } else {
            return Center(child: Text('Erro ao carregar dados'));
          }
        },
      ),
    );
  }
}
