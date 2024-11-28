 class CollectTime {
  final String time;
  final String day;
  final String collect_done_time;

  CollectTime({
    required this.time,
    required this.day,
    required this.collect_done_time,
  });

  factory CollectTime.fromJson(Map<String, dynamic> parsedJson) {
    return CollectTime(
      time: parsedJson['time'],
      day: parsedJson['day'],
      collect_done_time: parsedJson['collect_done_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'day': day,
      'collect_done_time': collect_done_time,
    };
  }
}
