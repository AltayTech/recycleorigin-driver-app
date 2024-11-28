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

  factory DriverData.fromJson(Map<String, dynamic> parsedJson) {
    return DriverData(
      driver_image:
          parsedJson['driver_image'] != null ? parsedJson['driver_image'] : '',
      phone: parsedJson['phone'] != null ? parsedJson['phone'] : '',
      fname: parsedJson['fname'] != null ? parsedJson['fname'] : '',
      lname: parsedJson['lname'] != null ? parsedJson['lname'] : '',
      email: parsedJson['email'] != null ? parsedJson['email'] : '',
      ostan: parsedJson['ostan'] != null ? parsedJson['ostan'] : '',
      city: parsedJson['city'] != null ? parsedJson['city'] : '',
      mobile: parsedJson['mobile'] != null ? parsedJson['mobile'] : '',
      address: parsedJson['address'] != null ? parsedJson['address'] : '',
      postcode: parsedJson['postcode'] != null ? parsedJson['postcode'] : '',
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
