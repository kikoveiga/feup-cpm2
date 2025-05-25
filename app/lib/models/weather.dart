import 'hourly_condition.dart';

class Weather {
  final String conditions;
  final String icon;
  final double temp;
  final double tempmax;
  final double tempmin;
  final double humidity;
  final double pressure;
  final double windspeed;
  final double precip;
  final double precipprob;
  final double precipcover;
  final List<String> preciptype;
  final double uvindex;
  final double windgust;
  final double winddir;
  final double visibility;
  final String sunset;
  final List<HourlyCondition> hourlyConditions;
  List<HourlyCondition> nextDayHourlyConditions = [];
  Weather({
    required this.conditions,
    required this.icon,
    required this.temp,
    required this.tempmax,
    required this.tempmin,
    required this.humidity,
    required this.pressure,
    required this.windspeed,
    required this.precip,
    required this.precipprob,
    required this.precipcover,
    required this.preciptype,
    required this.uvindex,
    required this.windgust,
    required this.winddir,
    required this.sunset,
    required this.visibility,
    required this.hourlyConditions,
    required this.nextDayHourlyConditions,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final days = json['days'] as List;
    final day = days[0];

    final todayHours = (days[0]['hours'] as List)
        .map((h) => HourlyCondition.fromJson(h))
        .toList();

    List<HourlyCondition> nextDayHours = [];
    if (days.length > 1) {
      nextDayHours = (days[1]['hours'] as List)
          .map((h) => HourlyCondition.fromJson(h))
          .toList();
    }

    return Weather(
      conditions: day['conditions'] ?? '',
      icon: day['icon'] ?? '',
      temp: (day['temp'] ?? 0).toDouble(),
      tempmax: (day['tempmax'] ?? 0).toDouble(),
      tempmin: (day['tempmin'] ?? 0).toDouble(),
      humidity: (day['humidity'] ?? 0).toDouble(),
      pressure: (day['pressure'] ?? 0).toDouble(),
      windspeed: (day['windspeed'] ?? 0).toDouble(),
      precip: (day['precip'] ?? 0).toDouble(),
      precipprob: (day['precipprob'] ?? 0).toDouble(),
      precipcover: (day['precipcover'] ?? 0).toDouble(),
      preciptype: (day['preciptype'] as List?)?.map((e) => e.toString()).toList() ?? [],
      uvindex: (day['uvindex'] ?? 0).toDouble(),
      windgust: (day['windgust'] ?? 0).toDouble(),
      winddir: (day['winddir'] ?? 0).toDouble(),
      visibility: (day['visibility'] ?? 0).toDouble(),
      sunset: day['sunset'] ?? '',
      hourlyConditions: todayHours,
      nextDayHourlyConditions: nextDayHours,
    );
  }


  double? getCurrentHourTemp() {
    if (hourlyConditions.isEmpty) return null;

    final now = DateTime.now();
    final currentHour = now.hour;

    // Try to find the closest hour match
    final match = hourlyConditions.firstWhere(
          (cond) => int.tryParse(cond.hour.split(':').first) == currentHour,
      orElse: () => hourlyConditions.first,
    );

    return match.temperature;
  }

  List<HourlyCondition> getNextDayHourly() => nextDayHourlyConditions;

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions,
      'icon': icon,
      'temp': temp,
      'tempmax': tempmax,
      'tempmin': tempmin,
      'humidity': humidity,
      'pressure': pressure,
      'windspeed': windspeed,
      'precip': precip,
      'precipprob': precipprob,
      'precipcover': precipcover,
      'preciptype': preciptype,
      'uvindex': uvindex,
      'windgust': windgust,
      'winddir': winddir,
      'visibility': visibility,
      'sunset': sunset,
      'hourlyConditions': hourlyConditions.map((e) => e.toJson()).toList(),
      'nextDayHourlyConditions':
          nextDayHourlyConditions.map((e) => e.toJson()).toList(),
    };
  }

}
