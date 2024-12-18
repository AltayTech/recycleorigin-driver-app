import 'package:flutter/material.dart';

class PriceWeight with ChangeNotifier {
  final String weight;
  final String price;

  PriceWeight({
    required this.weight,
    required this.price,
  });

  factory PriceWeight.fromJson(Map<String, dynamic> parsedJson) {
    return PriceWeight(
      weight: parsedJson['weight'],
      price: parsedJson['price'],
    );
  }
}
