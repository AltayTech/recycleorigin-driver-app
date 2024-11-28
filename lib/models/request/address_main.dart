import 'package:flutter/material.dart';
import '../../models/request/address.dart';

class AddressMain with ChangeNotifier {
  final List<Address> addressData;

  AddressMain({
    required this.addressData,
  });

  factory AddressMain.fromJson(Map<String, dynamic> parsedJson) {
    var addressList = parsedJson['address_data'] as List;
    List<Address> addressRaw = [];
    addressRaw = addressList.map((i) => Address.fromJson(i)).toList();
    return AddressMain(
      addressData: addressRaw,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? addressData = this.addressData.map((i) => i.toJson()).toList();
    return {
      'address_data': addressData,
    };
  }
}
