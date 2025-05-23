import 'package:flutter/material.dart';

import '../models/status.dart';

class Clearing with ChangeNotifier {
  final int id;
  final Status status;
  final String bank_transaction;
  final String money;
  final String paid_date;
  final String shaba;

  Clearing({
    required this.id,
    required this.status,
    required this.bank_transaction,
    required this.money,
    required this.paid_date,
    required this.shaba,
  });

  factory Clearing.fromJson(Map<String, dynamic> parsedJson) {
    return Clearing(
      id: parsedJson['id'],
      bank_transaction: parsedJson['bank_transaction'] != null
          ? parsedJson['bank_transaction']
          : '0',
      money: parsedJson['money'] != null ? parsedJson['money'] : '0',
      paid_date: parsedJson['paid_date'] != null ? parsedJson['paid_date'] : '',
      shaba: parsedJson['shaba'] != null ? parsedJson['shaba'] : '',
      status: parsedJson['status'] != null
          ? Status.fromJson(parsedJson['status'])
          : Status(name: '', term_id: 0, slug: ''),
    );
  }

  Map<String, dynamic> toJson() {
    Map status = this.status.toJson() ;

    return {
      'id': id,
      'status': status,
      'bank_transaction': bank_transaction,
      'money': money,
      'paid_date': paid_date,
      'shaba': shaba,
    };
  }
}
