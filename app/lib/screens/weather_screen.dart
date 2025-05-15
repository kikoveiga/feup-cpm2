import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';
import '../storage/city_storage.dart';

class WeatherScreen extends StatefulWidget {
  final String city;

  const WeatherScreen({super.key, required this.city});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather?> weatherData;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    weatherData = WeatherService.fetchWeather(widget.city);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorites = await CityStorage.getFavoriteCities();
    setState(() {
      isFavorite = favorites.contains(widget.city);
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await CityStorage.removeCity(widget.city);
    } else {
      await CityStorage.addCity(widget.city);
    }
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite
            ? '${widget.city} adicionada aos favoritos'
            : '${widget.city} removida dos favoritos'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima em ${widget.city}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Weather?>(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          } else if (snapshot.hasData) {
            final weather = snapshot.data;
            print('Icon recebido: ${weather?.icon}');
            if (weather != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://raw.githubusercontent.com/visualcrossing/WeatherIcons/main/PNG/2nd%20Set%20-%20Color/${weather.icon}.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud_off, size: 100, color: Colors.grey);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Temperatura: ${weather.temp}°C',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Condições: ${weather.conditions}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Sem dados do clima para exibir.'));
            }
          } else {
            return const Center(child: Text('Erro ao carregar dados'));
          }
        },
      ),
    );
  }
}
