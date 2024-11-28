import 'package:flutter/material.dart';

class LoginError with ChangeNotifier {
  final String code;
  final String message;

  LoginError({ required this.code, required this.message});

  factory LoginError.fromJson(Map<String, dynamic> parsedJson) {
    return LoginError(
      code: parsedJson['code'],
      message: parsedJson['message'],
    );
  }


}
