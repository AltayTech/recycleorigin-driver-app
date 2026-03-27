import 'package:flutter/material.dart';

import 'collect.dart';
import 'collect_time.dart';
import 'request_address.dart';

class RequestWaste with ChangeNotifier {
  final CollectTime collect_date;
  final RequestAddress address_data;
  final List<Collect> collect_list;
  final bool collected;

  RequestWaste({
    required this.collect_date,
    required this.address_data,
    required this.collect_list,
    required this.collected,
  });

  factory RequestWaste.fromJson(Map<String, dynamic> parsedJson) {
    var collectList = parsedJson['collect_list'] as List;
    List<Collect> collectRaw =
        collectList.map((i) => Collect.fromJson(i)).toList();

    return RequestWaste(
        address_data: RequestAddress.fromJson(parsedJson['address_data']),
        collect_list: collectRaw,
        collect_date: CollectTime(collect_done_time: '', day: '', time: ''),
        collected: false);
  }

  Map<String, dynamic> toJson() {
    Map address_data = this.address_data.toJson();
    Map collect_date = this.collect_date.toJson();

    List<Map> collect_list = this.collect_list.map((i) => i.toJson()).toList();

    return {
      'collect_date': collect_date,
      'address_data': address_data,
      'collect_list': collect_list,
      'collected': collected,
    };
  }
}
