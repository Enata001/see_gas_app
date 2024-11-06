import 'dart:convert';

import 'package:see_gas_app/models/device_info_model.dart';

import '../utils/typedefs.dart';

class UserModel {
  final String username;
  UserId? userId;
  final String email;
  final String phoneContact;
  List<DeviceInfo>? devices;
  final String? photoLink;

  UserModel(
      {required this.phoneContact,
      required this.username,
      required this.userId,
      required this.email,
      this.photoLink,
      this.devices})
      : super();

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userId': userId,
      'email': email,
      'photoLink': photoLink,
      'phoneContact': phoneContact
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      userId: map['userId'] as UserId,
      email: map['email'] as String,
      photoLink: map['photoLink'] as String,
      phoneContact: map['phoneContact'] as String,
    );
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }


  factory UserModel.fromString(String text){
    return UserModel.fromMap(jsonDecode(text));
  }
}
