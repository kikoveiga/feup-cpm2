class DailyWeather {
  final String date;
  final double tempMax;
  final double tempMin;

  DailyWeather({
    required this.date,
    required this.tempMax,
    required this.tempMin,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: json['datetime'] ?? '',
      tempMax: (json['tempmax'] ?? 0.0).toDouble(),
      tempMin: (json['tempmin'] ?? 0.0).toDouble(),
    );
  }
}
