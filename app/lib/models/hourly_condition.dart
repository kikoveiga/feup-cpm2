class HourlyCondition {
  final String datetime;
  final String icon;
  final String hour;
  final double temperature;

  HourlyCondition({
    required this.datetime,
    required this.icon,
    required this.hour,
    required this.temperature,
  });

  factory HourlyCondition.fromJson(Map<String, dynamic> json) {
    final datetime = json['datetime'] ?? '';
    final hour = datetime.split(':')[0] + 'h';

    return HourlyCondition(
      datetime: datetime, // <-- Store it here
      icon: json['icon'] ?? '',
      hour: hour,
      temperature: json['temp']?.toDouble() ?? 0.0,
    );
  }
}
