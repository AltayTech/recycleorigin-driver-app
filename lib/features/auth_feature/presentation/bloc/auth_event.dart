import 'dart:async';

import 'package:recycleorigindriver/core/models/request/address.dart';

abstract class AuthEvent {}

final class AuthLoadTokenRequested extends AuthEvent {
  AuthLoadTokenRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested(this.email, this.password, {this.completer});
  final String email;
  final String password;
  final Completer<bool>? completer;
}

final class AuthRemoveTokenRequested extends AuthEvent {
  AuthRemoveTokenRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthCheckCompletedRequested extends AuthEvent {
  AuthCheckCompletedRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthGetAddressesRequested extends AuthEvent {
  AuthGetAddressesRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthUpdateAddressRequested extends AuthEvent {
  AuthUpdateAddressRequested(this.addressList, {this.completer});
  final List<Address> addressList;
  final Completer<void>? completer;
}

final class AuthGetOrderRequested extends AuthEvent {
  AuthGetOrderRequested(this.addressList, {this.completer});
  final List<Address> addressList;
  final Completer<void>? completer;
}

final class AuthSelectAddressRequested extends AuthEvent {
  AuthSelectAddressRequested(this.address, {this.completer});
  final Address address;
  final Completer<void>? completer;
}

final class AuthRetrieveRegionListRequested extends AuthEvent {
  AuthRetrieveRegionListRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthRetrieveRegionRequested extends AuthEvent {
  AuthRetrieveRegionRequested(this.regionId, {this.completer});
  final int regionId;
  final Completer<void>? completer;
}

final class AuthFirstLoginSet extends AuthEvent {
  AuthFirstLoginSet(this.value);
  final bool value;
}

final class AuthFirstLogoutSet extends AuthEvent {
  AuthFirstLogoutSet(this.value);
  final bool value;
}

final class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.completer,
  });

  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final Completer<bool>? completer;
}

final class AuthGoogleSignInRequested extends AuthEvent {
  AuthGoogleSignInRequested({this.completer});
  final Completer<bool>? completer;
}

final class AuthForgotPasswordRequested extends AuthEvent {
  AuthForgotPasswordRequested(this.email, {this.completer});
  final String email;
  final Completer<void>? completer;
}

final class AuthEmailVerificationResendRequested extends AuthEvent {
  AuthEmailVerificationResendRequested({this.completer});
  final Completer<void>? completer;
}

final class AuthEmailVerificationCheckRequested extends AuthEvent {
  AuthEmailVerificationCheckRequested({this.completer});
  final Completer<bool>? completer;
}
