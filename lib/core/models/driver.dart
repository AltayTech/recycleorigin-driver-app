import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/models/status.dart';

import 'package:recycleorigindriver/core/models/driver_data.dart';
import 'request/pasmand.dart';

class Driver with ChangeNotifier {
  final Status status;
  final Status car;
  final Status car_color;
  final String car_number;
  final DriverData driver_data;
  final List<Pasmand> stores;
  final String money;
  final double? averageRating;

  Driver({
    required this.status,
    required this.car,
    required this.car_color,
    required this.car_number,
    required this.driver_data,
    required this.stores,
    required this.money,
    this.averageRating,
  });

  factory Driver.fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return Driver(
        status: Status(term_id: 0, name: '', slug: ''),
        car: Status(term_id: 0, name: '', slug: ''),
        car_color: Status(term_id: 0, name: '', slug: ''),
        car_number: '',
        driver_data: DriverData(
          driver_image: '',
          phone: '',
          fname: '',
          lname: '',
          email: '',
          ostan: '',
          city: '',
          mobile: '',
          address: '',
          postcode: '',
        ),
        stores: const [],
        money: '0',
        averageRating: null,
      );
    }
    final storeList = parsedJson['stores'];
    final List<Pasmand> storeRaw = storeList is List
        ? (storeList)
            .map<Pasmand>(
                (dynamic i) => Pasmand.fromJson(i as Map<String, dynamic>))
            .toList()
        : <Pasmand>[];

    final driverDataJson = parsedJson['driver_data'];
    final driverData = driverDataJson is Map<String, dynamic>
        ? DriverData.fromJson(driverDataJson)
        : DriverData(
            driver_image: '',
            phone: '',
            fname: '',
            lname: '',
            email: '',
            ostan: '',
            city: '',
            mobile: '',
            address: '',
            postcode: '',
          );

    return Driver(
      status: parsedJson['status'] != null && parsedJson['status'] is Map
          ? Status.fromJson(parsedJson['status'] as Map<String, dynamic>)
          : Status(term_id: 0, name: '', slug: ''),
      car: parsedJson['car'] != null && parsedJson['car'] is Map
          ? Status.fromJson(parsedJson['car'] as Map<String, dynamic>)
          : Status(term_id: 0, name: '', slug: ''),
      car_color:
          parsedJson['car_color'] != null && parsedJson['car_color'] is Map
              ? Status.fromJson(parsedJson['car_color'] as Map<String, dynamic>)
              : Status(term_id: 0, name: '', slug: ''),
      car_number: parsedJson['car_number'] != null
          ? parsedJson['car_number'] as String
          : '',
      driver_data: driverData,
      stores: storeRaw,
      money: parsedJson['money'] != null ? parsedJson['money'] as String : '0',
      averageRating: _parseAvg(parsedJson['average_rating']),
    );
  }

  static double? _parseAvg(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'car': car,
      'car_color': car_color,
      'driver_data': driver_data,
    };
  }
}
