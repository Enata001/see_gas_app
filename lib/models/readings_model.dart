class DeviceReadings {
  final String id;
  final double lpgOne;
  final double lpgTwo;
  final double lpgThree;
  final int smoke;
  final double temp;
  final double humidity;
  final bool warning;
  final bool danger;

  DeviceReadings({
    required this.warning,
    required this.danger,
    required this.id,
    required this.lpgOne,
    required this.lpgTwo,
    required this.lpgThree,
    required this.smoke,
    required this.temp,
    required this.humidity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lpgOne': lpgOne,
      'lpgTwo': lpgTwo,
      'lpgThree': lpgThree,
      'smoke': smoke,
      'temp': temp,
      'humidity': humidity,
    };
  }

  factory DeviceReadings.fromMap(Map<String, dynamic> map) {
    return DeviceReadings(
      // id: map['id'] as String,
      lpgOne: map['lpg1'],
      lpgTwo: map['lpg2'],
      lpgThree: map['lpg3'],
      smoke: map['smoke'],
      temp: map['temp'],
      humidity: map['humidity'],
      danger: map['danger'] as bool,
      warning: map['warning'] as bool, id: '1',
    );
  }
}
