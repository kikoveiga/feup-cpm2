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
        title: Text('Weather in ${widget.city}'),
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
            print("Length: ${weather?.hourlyConditions.length}");
            if (weather != null) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.city,
                        style: const TextStyle(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.temp.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.conditions,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Min: ${weather.tempmin.toStringAsFixed(1)}°C  |  Max: ${weather.tempmax.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 30),
                      Image.network(
                        'https://raw.githubusercontent.com/visualcrossing/WeatherIcons/main/PNG/2nd%20Set%20-%20Color/${weather.icon}.png',
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.cloud_off, size: 100, color: Colors.grey);
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Hourly forecast',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weather.hourlyConditions.length,
                          itemBuilder: (context, index) {
                            final hourData = weather.hourlyConditions[index];
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    hourData.hour,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Image.network(
                                    'https://raw.githubusercontent.com/visualcrossing/WeatherIcons/main/PNG/2nd%20Set%20-%20Color/${hourData.icon}.png',
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.cloud, size: 40),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${hourData.temperature.toStringAsFixed(0)}°',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    ],
                  ),
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
