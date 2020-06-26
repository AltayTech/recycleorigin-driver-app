import 'package:flutter/material.dart';


import '../driver.dart';
import '../status.dart';
import 'address.dart';
import 'collect.dart';
import 'collect_status.dart';

class RequestWasteItem with ChangeNotifier {
  final int id;
  final Status status;
  final int collect_type;
  final CollectStatus total_price;
  final CollectStatus total_weight;
  final CollectStatus total_number;
  final String collect_day;
  final String collect_hours;
  final String collect_hour_exact;
  final Address address;
  final List<Collect> collect_list;
  final Driver driver;

  RequestWasteItem(
      {this.id,
      this.status,
      this.collect_type,
      this.total_price,
      this.total_weight,
      this.total_number,
      this.collect_day,
      this.collect_hours,
      this.collect_hour_exact,
      this.address,
      this.collect_list,
      this.driver});

  factory RequestWasteItem.fromJson(Map<String, dynamic> parsedJson) {
    var collectList = parsedJson['collect_list'] as List;
    List<Collect> collectRaw =
        collectList.map((i) => Collect.fromJson(i)).toList();

    return RequestWasteItem(
      id: parsedJson['id'],
      status: Status.fromJson(parsedJson['status']),
      total_price: CollectStatus.fromJson(parsedJson['total_price']),
      total_weight: CollectStatus.fromJson(parsedJson['total_weight']),
      total_number: CollectStatus.fromJson(parsedJson['total_number']),
      collect_day: parsedJson['collect_day'] != null
          ? parsedJson['collect_day']
          : '',
      collect_hours: parsedJson['collect_hours'] != null
          ? parsedJson['collect_hours']
          : '',
      collect_hour_exact: parsedJson['collect_hour_exact'] != null
          ? parsedJson['collect_hour_exact']
          : '',
      address: Address.fromJson(parsedJson['address']),
      collect_list: collectRaw,
      driver: Driver.fromJson(parsedJson['driver']),
    );
  }

  Map<String, dynamic> toJson() {
    Map address = this.address != null ? this.address.toJson() : null;
    Map status = this.status != null ? this.status.toJson() : null;
    Map driver = this.driver != null ? this.driver.toJson() : null;
    Map total_price = this.total_price != null ? this.total_price.toJson() : null;
    Map total_weight = this.total_weight != null ? this.total_weight.toJson() : null;
    Map total_number = this.total_number != null ? this.total_number.toJson() : null;

    List<Map> collect_list = this.collect_list != null
        ? this.collect_list.map((i) => i.toJson()).toList()
        : null;

    return {
      'id': id,
      'status': status,
      'total_price': total_price,
      'total_weight': total_weight,
      'total_number': total_number,
      'collect_day': collect_day,
      'collect_hours': collect_hours,
      'collect_hour_exact': collect_hour_exact,
      'address_data': address,
      'collect_list': collect_list,
      'driver': driver,
    };
  }
}
