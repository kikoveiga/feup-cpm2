import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';
import '../screens/weather_screen.dart';
import '../storage/city_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _portugalDistricts = [
    'Aveiro',
    'Beja',
    'Braga',
    'Bragança',
    'Castelo Branco',
    'Coimbra',
    'Évora',
    'Faro',
    'Guarda',
    'Leiria',
    'Lisboa',
    'Portalegre',
    'Porto',
    'Santarém',
    'Setúbal',
    'Viana do Castelo',
    'Vila Real',
    'Viseu',
  ];

  String _selectedCity = '';
  List<String> favoriteCities = [];
  Map<String, Weather?> favoriteWeatherData = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final cities = await CityStorage.getFavoriteCities();
    final Map<String, Weather?> weatherMap = {};
    for (String city in cities) {
      final weather = await WeatherService.fetchWeather(city);
      weatherMap[city] = weather;
    }

    setState(() {
      favoriteCities = cities;
      favoriteWeatherData = weatherMap;
    });
  }

  void _onSearch() {
    if (_selectedCity.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherScreen(city: _selectedCity),
        ),
      ).then((_) => _loadFavorites());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Weather App'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _portugalDistricts.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedCity = selection;
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search for a city',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 30),
            if (favoriteCities.isNotEmpty)
              const Text(
                'Favoritos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            ...favoriteCities.map((city) {
              final weather = favoriteWeatherData[city];
              return Card(
                child: ListTile(
                  title: Text(city),
                  subtitle: weather != null
                      ? Text('Temp: ${weather.temp}°C')
                      : const Text('Sem dados'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeatherScreen(city: city),
                      ),
                    ).then((_) => _loadFavorites());
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
