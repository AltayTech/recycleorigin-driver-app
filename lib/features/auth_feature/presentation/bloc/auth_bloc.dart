import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/features/auth_feature/data/firebase_auth_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/core/notifications/driver_push_notification_controller.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/utils/jwt_utils.dart';
import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/models/request/address_main.dart';
import 'package:recycleorigindriver/core/models/token_response_model.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

/// Handles authentication, token storage, addresses, and regions for the
/// driver app.
///
/// Login goes through Firebase ([FirebaseAuthService]): credentials are
/// validated against Firebase Auth, then the resulting ID token is exchanged
/// at `POST /pasmands/v1/auth/firebase` for a backend access + refresh
/// token pair. Google sign-in follows the same exchange.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({FirebaseAuthService? firebaseAuthService})
      : _firebase = firebaseAuthService ?? FirebaseAuthService(),
        super(AuthState.initial()) {
    on<AuthLoadTokenRequested>(_onLoadToken);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthEmailVerificationResendRequested>(_onResendVerification);
    on<AuthEmailVerificationCheckRequested>(_onCheckVerification);
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

  final FirebaseAuthService _firebase;

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

  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) {
    final c = Completer<bool>();
    add(AuthRegisterRequested(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      completer: c,
    ));
    return c.future;
  }

  Future<bool> signInWithGoogle() {
    final c = Completer<bool>();
    add(AuthGoogleSignInRequested(completer: c));
    return c.future;
  }

  Future<void> sendPasswordReset(String email) {
    final c = Completer<void>();
    add(AuthForgotPasswordRequested(email, completer: c));
    return c.future;
  }

  Future<void> resendEmailVerification() {
    final c = Completer<void>();
    add(AuthEmailVerificationResendRequested(completer: c));
    return c.future;
  }

  Future<bool> refreshEmailVerification() {
    final c = Completer<bool>();
    add(AuthEmailVerificationCheckRequested(completer: c));
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
      final token = await SecureStorage.getAccessToken() ?? '';
      final refresh = await SecureStorage.getRefreshToken() ?? '';
      final loggedIn = await SecureStorage.getLoginStatus() && token.isNotEmpty;
      final claims = decodeJwtPayload(token);
      emit(state.copyWith(
        token: token,
        refreshToken: refresh,
        isLoggedIn: loggedIn,
        emailVerified: claims?['email_verified'] == true,
        role: (claims?['role'] as String?) ?? state.role,
        provider: (claims?['provider'] as String?) ?? state.provider,
      ));
      if (loggedIn) {
        unawaited(DriverPushNotificationController.instance.syncAfterLogin());
      }
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(token: '', refreshToken: '', isLoggedIn: false));
      event.completer?.complete();
    }
  }

  void _setLoggedOut(Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        token: '',
        refreshToken: '',
        isLoggedIn: false,
        emailVerified: false,
        provider: '',
        role: '',
        tokenResponseModel: TokenResponseModel(),
      ),
    );
  }

  Future<void> _persistResult(
    FirebaseAuthResult result,
    Emitter<AuthState> emit, {
    bool isFirstLogin = false,
  }) async {
    final user = result.user;
    final email = (user['email'] as String?) ?? '';
    final displayName = (user['display_name'] as String?) ??
        '${(user['first_name'] as String?) ?? ''} ${(user['last_name'] as String?) ?? ''}'
            .trim();
    final tokenModel = TokenResponseModel.fromJson(<String, dynamic>{
      'token': result.accessToken,
      'user_email': email,
      'user_nicename': email,
      'user_display_name': displayName,
    });
    await SecureStorage.saveUserData(jsonEncode(user));
    emit(state.copyWith(
      token: result.accessToken,
      refreshToken: result.refreshToken,
      tokenResponseModel: tokenModel,
      isLoggedIn: true,
      isFirstLogin: isFirstLogin,
      isFirstLogout: false,
      emailVerified: result.emailVerified,
      provider: result.provider,
      role: result.role,
    ));
    unawaited(DriverPushNotificationController.instance.syncAfterLogin());
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _firebase.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      await _persistResult(result, emit, isFirstLogin: true);
      event.completer?.complete(true);
    } on AuthException catch (e, st) {
      developer.log(
        'Driver login failed: ${e.code}',
        name: 'driver.auth',
        error: e,
        stackTrace: st,
        level: 900,
      );
      _setLoggedOut(emit);
      event.completer?.completeError(e, st);
    } catch (e, st) {
      _setLoggedOut(emit);
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    final displayName = '${event.firstName ?? ''} ${event.lastName ?? ''}'.trim();
    try {
      final result = await _firebase.registerWithEmail(
        email: event.email,
        password: event.password,
        displayName: displayName.isEmpty ? null : displayName,
      );
      await _persistResult(result, emit, isFirstLogin: true);
      event.completer?.complete(true);
    } on AuthException catch (e, st) {
      developer.log(
        'Driver register failed: ${e.code}',
        name: 'driver.auth',
        error: e,
        stackTrace: st,
        level: 900,
      );
      event.completer?.completeError(e, st);
    } catch (e, st) {
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _firebase.signInWithGoogle();
      await _persistResult(result, emit, isFirstLogin: true);
      event.completer?.complete(true);
    } on AuthException catch (e, st) {
      if (e.code == AuthErrorCodes.cancelled) {
        event.completer?.complete(false);
        return;
      }
      event.completer?.completeError(e, st);
    } catch (e, st) {
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _firebase.sendPasswordReset(event.email);
      event.completer?.complete();
    } catch (e, st) {
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onResendVerification(
    AuthEmailVerificationResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _firebase.sendEmailVerification();
      event.completer?.complete();
    } catch (e, st) {
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onCheckVerification(
    AuthEmailVerificationCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _firebase.reloadAndExchangeIfVerified();
      if (result == null) {
        event.completer?.complete(false);
        return;
      }
      await _persistResult(result, emit);
      event.completer?.complete(true);
    } catch (e, st) {
      event.completer?.completeError(e, st);
    }
  }

  Future<void> _onRemoveToken(
    AuthRemoveTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    await DriverPushNotificationController.instance.onLogout();
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(Urls.apiBaseUrl + Urls.logoutPath),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${state.token}',
          },
          body: jsonEncode({'refresh_token': refresh}),
        );
      } catch (e) {
        developer.log('Backend logout failed (continuing): $e',
            name: 'driver.auth', level: 900);
      }
    }
    try {
      await _firebase.signOut();
    } catch (_) {}
    await SecureStorage.deleteToken();
    await SecureStorage.saveLoginStatus(false);
    emit(state.copyWith(
      token: '',
      refreshToken: '',
      isLoggedIn: false,
      isFirstLogin: false,
      emailVerified: false,
      provider: '',
      role: '',
      tokenResponseModel: TokenResponseModel(),
    ));
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
