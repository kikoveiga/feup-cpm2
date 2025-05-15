class Weather {
  final String conditions;
  final String icon;
  final double temp;
  final double tempmax;
  final double tempmin;
  final double humidity;
  final double pressure;
  final double windspeed;

  Weather({
    required this.conditions,
    required this.icon,
    required this.temp,
    required this.tempmax,
    required this.tempmin,
    required this.humidity,
    required this.pressure,
    required this.windspeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final day = json['days'][0];
    return Weather(
      conditions: day['conditions'] ?? '',
      icon: day['icon'] ?? '',
      temp: day['temp']?.toDouble() ?? 0.0,
      tempmax: day['tempmax']?.toDouble() ?? 0.0,
      tempmin: day['tempmin']?.toDouble() ?? 0.0,
      humidity: day['humidity']?.toDouble() ?? 0.0,
      pressure: day['pressure']?.toDouble() ?? 0.0,
      windspeed: day['windspeed']?.toDouble() ?? 0.0,
    );
  }
}
