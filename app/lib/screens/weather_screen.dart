import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';
import '../storage/city_storage.dart';
import 'next_day_forecast_screen.dart';
import '../widgets/weekly_temp_chart.dart';
import '../models/daily_weather.dart';

String _getWindDirectionName(double degrees) {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  int index = ((degrees + 22.5) ~/ 45) % 8;
  return directions[index];
}

Widget _buildWeatherInfoTile(IconData icon, String value, String label, {required MaterialColor iconColor}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: iconColor, size: 28),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class WeatherScreen extends StatefulWidget {
  final String city;

  const WeatherScreen({super.key, required this.city});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather?> weatherData;
  late Future<List<DailyWeather>> weeklyData;
  bool isFavorite = false;
  String? aiAdvice;
  final GeminiService geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    weatherData = WeatherService.fetchWeather(widget.city);
    weeklyData = WeatherService.fetchWeeklyWeather(widget.city);
    _loadFavoriteStatus();
    _fetchAIAdvice();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorites = await CityStorage.getFavoriteCities();
    setState(() {
      isFavorite = favorites.contains(widget.city);
    });
  }

  Future<void> _fetchAIAdvice() async {
    try {
      final weather = await weatherData;
      if (weather != null) {
        final advice = await geminiService.getAIAdviceFromWeather(
          weather.toJson(),
          widget.city,
        );
        setState(() {
          aiAdvice = advice;
        });
      } else {
        setState(() {
          aiAdvice = 'Weather data not available.';
        });
      }
    } catch (e) {
      print('Erro ao obter conselho de IA: $e');
      setState(() {
        aiAdvice = 'Não foi possível obter conselho de IA.';
      });
    }
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
        content: Text(
          isFavorite
              ? '${widget.city} adicionada aos favoritos'
              : '${widget.city} removida dos favoritos',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather in ${widget.city}'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00838F), Color(0xFF4DD0E1)], // tons de teal
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            if (weather != null) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE0F7FA), Color(0xFF74E7F4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.blue,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.city,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${weather.getCurrentHourTemp()?.toStringAsFixed(1) ?? "N/A"}°C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      weather.conditions,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Min: ${weather.tempmin.toStringAsFixed(1)}°  |  Max: ${weather.tempmax.toStringAsFixed(1)}°',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.network(
                                'https://raw.githubusercontent.com/visualcrossing/WeatherIcons/main/PNG/2nd%20Set%20-%20Color/${weather.icon}.png',
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.cloud_off,
                                    size: 80,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card for Hourly Forecast
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 30.0),
                                      child: Text(
                                        'Hourly forecast',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: weather.hourlyConditions.map((hourData) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
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
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.cloud,
                                                size: 40,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${hourData.temperature.toStringAsFixed(0)}°',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Card for Wind Information
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.wind_power, color: Colors.lightBlue),
                                    SizedBox(width: 8),
                                    Text(
                                      'Wind',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.air,
                                          size: 28,
                                          color: Colors.lightBlue,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${weather.windspeed} km/h',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Speed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.bolt,
                                          size: 28,
                                          color: Colors.lightBlue,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${weather.windgust} km/h',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Gust',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Transform.rotate(
                                          angle: weather.winddir * (3.1416 / 180),
                                          child: const Icon(
                                            Icons.explore,
                                            size: 28,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${weather.winddir.toStringAsFixed(0)}°',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _getWindDirectionName(weather.winddir),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card for Precipitation Information
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // fundo branco
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.grain, color: Colors.lightBlue),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Precipitation',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildWeatherInfoTile(
                                      Icons.water_drop,
                                      '${weather.precip} mm',
                                      'Amount',
                                      iconColor: Colors.lightBlue,
                                    ),
                                    _buildWeatherInfoTile(
                                      Icons.percent,
                                      '${weather.precipprob.toStringAsFixed(0)}%',
                                      'Probability',
                                      iconColor: Colors.lightBlue,
                                    ),
                                    _buildWeatherInfoTile(
                                      Icons.blur_on,
                                      '${weather.precipcover.toStringAsFixed(0)}%',
                                      'Coverage',
                                      iconColor: Colors.lightBlue,
                                    ),
                                    _buildWeatherInfoTile(
                                      Icons.cloud,
                                      weather.preciptype.isNotEmpty ? weather.preciptype.first : 'N/A',
                                      'Type',
                                      iconColor: Colors.lightBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Card for AI Advice
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0F7FA), Color(0xFF74E7F4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.psychology, color: Colors.blueAccent),
                                    SizedBox(width: 8),
                                    Text(
                                      'AI Advice',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  aiAdvice ?? 'Loading advice...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Pressure',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildWeatherInfoTile(
                                        Icons.speed,
                                        '${weather.pressure} hPa',
                                        'Pressure',
                                        iconColor: Colors.lightBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Humidity',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildWeatherInfoTile(
                                        Icons.water_drop,
                                        '${weather.humidity}%',
                                        'Humidity',
                                        iconColor: Colors.lightBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Sunset',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildWeatherInfoTile(
                                        Icons.wb_twilight,
                                        weather.sunset,
                                        'Sunset',
                                        iconColor: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.blue,
                                        blurRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Visibility',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildWeatherInfoTile(
                                        Icons.remove_red_eye,
                                        '${weather.visibility} km',
                                        'Visibility',
                                        iconColor: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE0F7FA), Color(0xFF74E7F4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12), // match button radius
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.blue,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Tomorrow\'s Forecast'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // make button background transparent
                              shadowColor: Colors.transparent,     // remove button shadow (optional)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              final nextDayConditions = weather.getNextDayHourly();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NextDayForecastScreen(
                                    city: widget.city,
                                    nextDayConditions: nextDayConditions,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),


                        const SizedBox(height: 20),
                        FutureBuilder<List<DailyWeather>>(
                          future: weeklyData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Erro ao carregar dados da semana.',
                                ),
                              );
                            }

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.blue,
                                      blurRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Temperature Evolution (Last 7 Days)',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 250,
                                      child: WeeklyTempChart(
                                        data: snapshot.data!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('Sem dados do clima para exibir.'),
              );
            }
          } else {
            return const Center(child: Text('Erro ao carregar dados'));
          }
        },
      ),
    );
  }
}
