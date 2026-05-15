import 'package:flutter/material.dart';

class RequestAddress with ChangeNotifier {
  final String name;
  final String address;
  final String region;
  final String latitude;
  final String longitude;

  RequestAddress({
    required this.name,
    required this.address,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  factory RequestAddress.fromJson(Map<String, dynamic> parsedJson) {
    return RequestAddress(
      name: parsedJson['name'],
      address: parsedJson['address'],
      region: parsedJson['region'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'region': region,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
