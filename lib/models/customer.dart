import 'package:flutter/foundation.dart';

import '../models/personal_data.dart';
import 'status.dart';

class Customer with ChangeNotifier {
  final int id;
  final Status status;
  final Status type;
  final PersonalData personalData;
  final String money;

  Customer({
    required this.id,
    required this.status,
    required this.type,
    required this.personalData,
     this.money='',
  });

  factory Customer.fromJson(Map<String, dynamic> parsedJson) {
    return Customer(
      id: parsedJson['id'] != null ? parsedJson['id'] : 0,
      status: parsedJson['status'] != null
          ? Status.fromJson(parsedJson['status'])
          : Status(term_id: 0, name: '', slug: ''),
      type: parsedJson['type'] != null
          ? Status.fromJson(parsedJson['type'])
          : Status(term_id: 0, name: '', slug: ''),
      personalData: PersonalData.fromJson(parsedJson['customer_data']),
      money: parsedJson['money'] != null ? parsedJson['money'] : '0',
    );
  }

  Map<String, dynamic> toJson() {
    Map personalData =
         this.personalData.toJson() ;
    Map type =  this.type.toJson() ;

    return {
      'customer_data': personalData,
      'type': type,
      'id': id,
      'money': money,
    };
  }
}
