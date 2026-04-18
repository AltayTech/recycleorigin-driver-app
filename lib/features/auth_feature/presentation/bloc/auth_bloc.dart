import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/models/request/address_main.dart';
import 'package:recycleorigindriver/core/models/token_response_model.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

/// Handles login, token storage, addresses, and regions for the driver app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<AuthLoadTokenRequested>(_onLoadToken);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRemoveTokenRequested>(_onRemoveToken);
    on<AuthCheckCompletedRequested>(_onCheckCompleted);
    on<AuthGetAddressesRequested>(_onGetAddresses);
    on<AuthUpdateAddressRequested>(_onUpdateAddress);
    on<AuthGetOrderRequested>(_onGetOrder);
    on<AuthSelectAddressRequested>(_onSelectAddress);
    on<AuthRetrieveRegionListRequested>(_onRetrieveRegionList);
    on<AuthRetrieveRegionRequested>(_onRetrieveRegion);
    on<AuthFirstLoginSet>(_onFirstLoginSet);
    on<AuthFirstLogoutSet>(_onFirstLogoutSet);
  }

  Future<void> loadStoredToken() {
    final c = _voidCompleter();
    add(AuthLoadTokenRequested(completer: c));
    return c.future;
  }

  Future<bool> login(String email, String password) {
    final c = Completer<bool>();
    add(AuthLoginRequested(email, password, completer: c));
    return c.future;
  }

  Future<void> removeToken() {
    final c = _voidCompleter();
    add(AuthRemoveTokenRequested(completer: c));
    return c.future;
  }

  Future<void> getToken() => loadStoredToken();

  Future<void> checkCompleted() {
    final c = _voidCompleter();
    add(AuthCheckCompletedRequested(completer: c));
    return c.future;
  }

  Future<void> getAddresses() {
    final c = _voidCompleter();
    add(AuthGetAddressesRequested(completer: c));
    return c.future;
  }

  Future<void> updateAddress(List<Address> addressList) {
    final c = _voidCompleter();
    add(AuthUpdateAddressRequested(addressList, completer: c));
    return c.future;
  }

  Future<void> getOrder(List<Address> addressList) {
    final c = _voidCompleter();
    add(AuthGetOrderRequested(addressList, completer: c));
    return c.future;
  }

  Future<void> selectAddress(Address address) {
    final c = _voidCompleter();
    add(AuthSelectAddressRequested(address, completer: c));
    return c.future;
  }

  Future<void> retrieveRegionList() {
    final c = _voidCompleter();
    add(AuthRetrieveRegionListRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveRegion(int regionId) {
    final c = _voidCompleter();
    add(AuthRetrieveRegionRequested(regionId, completer: c));
    return c.future;
  }

  set isFirstLogin(bool value) => add(AuthFirstLoginSet(value));

  set isFirstLogout(bool value) => add(AuthFirstLogoutSet(value));

  Completer<void> _voidCompleter() => Completer<void>();

  void _onFirstLoginSet(
    AuthFirstLoginSet event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isFirstLogin: event.value));
  }

  void _onFirstLogoutSet(
    AuthFirstLogoutSet event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isFirstLogout: event.value));
  }

  Future<void> _onLoadToken(
    AuthLoadTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      final loggedIn = await SecureStorage.getLoginStatus() && token.isNotEmpty;
      emit(state.copyWith(token: token, isLoggedIn: loggedIn));
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(token: '', isLoggedIn: false));
      event.completer?.complete();
    }
  }

  void _setLoggedOut(Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        token: '',
        isLoggedIn: false,
        tokenResponseModel: TokenResponseModel(),
      ),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final uri = Uri.parse(Urls.apiBaseUrl + Urls.loginPath).replace(
      queryParameters: {'username': event.email, 'password': event.password},
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        if (data == null) {
          _setLoggedOut(emit);
          event.completer?.complete(false);
          return;
        }
        final tokenStr = data['token']?.toString();
        if (tokenStr == null || tokenStr.isEmpty) {
          _setLoggedOut(emit);
          event.completer?.complete(false);
          return;
        }
        final tokenResponseModel = TokenResponseModel.fromJson(data);
        final userData = jsonEncode({'token': tokenStr});
        await SecureStorage.saveUserData(userData);
        await SecureStorage.saveToken(tokenStr);
        await SecureStorage.saveLoginStatus(true);
        emit(
          state.copyWith(
            token: tokenStr,
            isFirstLogin: true,
            isFirstLogout: false,
            isLoggedIn: true,
            tokenResponseModel: tokenResponseModel,
          ),
        );
        event.completer?.complete(true);
        return;
      }

      if (response.statusCode == 401) {
        _setLoggedOut(emit);
        event.completer?.complete(false);
        return;
      }

      _setLoggedOut(emit);
      event.completer?.complete(false);
    } catch (e) {
      _setLoggedOut(emit);
      event.completer?.completeError(e);
      rethrow;
    }
  }

  Future<void> _onRemoveToken(
    AuthRemoveTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    await SecureStorage.deleteToken();
    await SecureStorage.saveLoginStatus(false);
    emit(
      state.copyWith(
        token: '',
        isLoggedIn: false,
        isFirstLogin: false,
        tokenResponseModel: TokenResponseModel(),
      ),
    );
    event.completer?.complete();
  }

  Future<void> _onCheckCompleted(
    AuthCheckCompletedRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        emit(state.copyWith(isCompleted: false));
        event.completer?.complete();
        return;
      }
      final url = Urls.rootUrl + Urls.checkCompletedEndPoint;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $t',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as dynamic;
        emit(
          state.copyWith(isCompleted: extractedData['complete'] == true),
        );
      } else {
        emit(state.copyWith(isCompleted: false));
      }
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(isCompleted: false));
      event.completer?.complete();
    }
  }

  Future<void> _onGetAddresses(
    AuthGetAddressesRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        emit(state.copyWith(addressItems: []));
        event.completer?.complete();
        return;
      }
      final url = Urls.rootUrl + Urls.addressEndPoint;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $t',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body);
      final addressMain = AddressMain.fromJson(extractedData);
      emit(state.copyWith(addressItems: addressMain.addressData));
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(addressItems: []));
      event.completer?.complete();
    }
  }

  Future<void> _onUpdateAddress(
    AuthUpdateAddressRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        emit(state.copyWith(addressItems: event.addressList));
        event.completer?.complete();
        return;
      }
      final url = Urls.rootUrl + Urls.addressEndPoint;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $t',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(AddressMain(addressData: event.addressList)),
      );
      final extractedData = json.decode(response.body);
      final addressMain = AddressMain.fromJson(extractedData);
      emit(state.copyWith(addressItems: addressMain.addressData));
      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
      rethrow;
    }
  }

  Future<void> _onGetOrder(
    AuthGetOrderRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        emit(state.copyWith(addressItems: event.addressList));
        event.completer?.complete();
        return;
      }
      final url = Urls.rootUrl + Urls.addressEndPoint;
      await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $t',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(AddressMain(addressData: event.addressList)),
      );
      emit(state.copyWith(addressItems: event.addressList));
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(addressItems: event.addressList));
      event.completer?.complete();
    }
  }

  Future<void> _onSelectAddress(
    AuthSelectAddressRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(selectedAddress: event.address));
    event.completer?.complete();
  }

  Future<void> _onRetrieveRegionList(
    AuthRetrieveRegionListRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final url = Urls.rootUrl + Urls.regionEndPoint;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body) as List;
      final regions = extractedData
          .map((i) => Region.fromJson(i as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(regionItems: regions));
      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
      rethrow;
    }
  }

  Future<void> _onRetrieveRegion(
    AuthRetrieveRegionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.regionEndPoint + '/${event.regionId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    emit(state.copyWith(regionData: Region.fromJson(extractedData)));
    event.completer?.complete();
  }
}
