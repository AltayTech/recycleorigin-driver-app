import 'package:flutter/foundation.dart';

import 'request/address.dart';

class PersonalData with ChangeNotifier {
  final String phone;
  final String first_name;
  final String last_name;
  final String ostan;
  final String city;
  final String mobile;
  final List<Address> addresses;
  final String postcode;
  final String email;

  PersonalData({
    required this.phone,
    required this.first_name,
    required this.last_name,
    this.email = '',
    this.ostan = '',
    this.city = '',
    this.mobile = '',
    required this.addresses,
    this.postcode = '',
  });

  factory PersonalData.fromJson(Map<String, dynamic> parsedJson) {
    List<Address> addressRaw = [];
    if (parsedJson['address_data'] != null) {
      var addressList = parsedJson['address_data'] as List;
      addressRaw = addressList.map((i) => Address.fromJson(i)).toList();
    } else {
      addressRaw = [];
    }
    return PersonalData(
      phone: parsedJson['phone'] ?? '',
      first_name: parsedJson['fname'] ?? '',
      last_name: parsedJson['lname'] ?? '',
      email: parsedJson['email'] ?? '',
      ostan: parsedJson['ostan'] ?? '',
      city: parsedJson['city'] ?? '',
      mobile: parsedJson['mobile'] ?? '',
      addresses: addressRaw,
      postcode: parsedJson['postcode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    List<Map> addresses = this.addresses.map((i) => i.toJson()).toList();

    return {
      'phone': phone,
      'fname': first_name,
      'lname': last_name,
      'email': email,
      'ostan': ostan,
      'city': city,
      'mobile': mobile,
      'address_data': addresses,
      'postcode': postcode,
    };
  }
}
