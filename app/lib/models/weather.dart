class Weather {
  final String conditions;
  final String icon;
  final double temp;

  Weather({
    required this.conditions,
    required this.icon,
    required this.temp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      conditions: json['currentConditions']['conditions'] ?? '',
      icon: json['currentConditions']['icon'] ?? '',
      temp: json['currentConditions']['temp']?.toDouble() ?? 0.0,
    );
  }
}
