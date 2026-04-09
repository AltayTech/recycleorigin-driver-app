import 'package:flutter/material.dart';

import '../region.dart';

class Address with ChangeNotifier {
  final String name;
  final String address;
  final Region region;
  final String latitude;
  final String longitude;

  Address(
      {required this.name,
      required this.address,
      required this.region,
      this.latitude = '',
      this.longitude = ''});

  factory Address.fromJson(Map<String, dynamic> parsedJson) {
    return Address(
      name: parsedJson['name']?.toString() ?? '',
      address: parsedJson['address']?.toString() ?? '',
      region: Region.fromJson(parsedJson['region']),
      latitude: parsedJson['latitude']?.toString() ?? '',
      longitude: parsedJson['longitude']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? region = this.region.toJson();

    return {
      'name': name,
      'address': address,
      'region': region,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
