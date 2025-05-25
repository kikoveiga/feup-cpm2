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

  factory HourlyCondition.fromJson(Map<String, dynamic> json, String parentDate) {
    final time = json['datetime'] ?? '';
    final fullDateTime = '$parentDate $time';

    final hour = time.split(':')[0] + 'h';

    return HourlyCondition(
      datetime: fullDateTime,
      icon: json['icon'] ?? '',
      hour: hour,
      temperature: (json['temp'] ?? 0).toDouble()
    );
  }
}
