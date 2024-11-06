

import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String id;
  final String name;
  final String location;

  const DeviceInfo({required this.location, required this.name, required this.id});

  DeviceInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        location = json['location'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  @override
  List<Object?> get props => [id, name, location];
}
