import 'package:flutter/foundation.dart';

class DriverData with ChangeNotifier {
  final String driver_image;
  final String fname;
  final String lname;
  final String ostan;
  final String city;
  final String phone;
  final String mobile;
  final String address;
  final String postcode;
  final String email;

  DriverData({
    required this.driver_image,
    required this.phone,
    required this.fname,
    required this.lname,
    required this.email,
    required this.ostan,
    required this.city,
    required this.mobile,
    required this.address,
    required this.postcode,
  });

  /// Coerces a JSON value to String (handles backend sending object e.g. driver_image as Map).
  static String _stringFromJson(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final url = value['url'] ?? value['src'] ?? value['link'];
      if (url is String) return url;
    }
    return value.toString();
  }

  factory DriverData.fromJson(Map<String, dynamic> parsedJson) {
    return DriverData(
      driver_image: _stringFromJson(parsedJson['driver_image']),
      phone: _stringFromJson(parsedJson['phone']),
      fname: _stringFromJson(parsedJson['fname']),
      lname: _stringFromJson(parsedJson['lname']),
      email: _stringFromJson(parsedJson['email']),
      ostan: _stringFromJson(parsedJson['ostan']),
      city: _stringFromJson(parsedJson['city']),
      mobile: _stringFromJson(parsedJson['mobile']),
      address: _stringFromJson(parsedJson['address']),
      postcode: _stringFromJson(parsedJson['postcode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'fname': fname,
      'lname': lname,
      'email': email,
      'ostan': ostan,
      'city': city,
      'address_data': address,
      'postcode': postcode,
    };
  }
}
