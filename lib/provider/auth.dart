import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/models/token_response_model.dart';
import 'package:recycleorigindriver/models/region.dart';
import 'package:recycleorigindriver/models/request/address.dart';
import 'package:recycleorigindriver/models/request/address_main.dart';
import 'package:recycleorigindriver/provider/urls.dart';

/// Authentication state. Uses same JWT email+password login as main Recycle Origin app.
class Auth with ChangeNotifier {
  String _token = '';
  bool _isLoggedin = false;
  bool _isFirstLogin = false;
  bool _isFirstLogout = false;
  bool _isCompleted = false;

  List<Address> _addressItems = [];
  Address _selectedAddress = Address(
    name: '',
    address: '',
    region: Region(
      term_id: 0,
      name: '',
      collect_hour: [],
    ),
  );
  List<Region> _regionItems = [];
  Region _regionData = Region(term_id: 0, name: '', collect_hour: []);

  TokenResponseModel tokenResponseModel = TokenResponseModel();

  bool get isLoggedin => _isLoggedin;
  bool get isFirstLogout => _isFirstLogout;
  bool get isFirstLogin => _isFirstLogin;
  bool get isCompleted => _isCompleted;
  String get token => _token;
  List<Address> get addressItems => _addressItems;
  Address get selectedAddress => _selectedAddress;
  List<Region> get regionItems => _regionItems;
  Region get regionData => _regionData;

  set isFirstLogout(bool value) => _isFirstLogout = value;
  set isFirstLogin(bool value) => _isFirstLogin = value;

  /// True if we have a stored token. Call [loadStoredToken] to refresh from storage.
  bool get isAuth => _token.isNotEmpty;

  /// Load token from secure storage (e.g. on app start or when checking auth).
  Future<void> loadStoredToken() async {
    try {
      _token = await SecureStorage.getToken() ?? '';
      _isLoggedin = await SecureStorage.getLoginStatus() && _token.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _token = '';
      _isLoggedin = false;
      notifyListeners();
    }
  }

  /// Login with email and password. Same API as main Recycle Origin app (JWT).
  /// Returns true if login succeeded, false otherwise.
  Future<bool> login(String email, String password) async {
    final uri = Uri.parse(Urls.apiBaseUrl + Urls.loginPath).replace(
      queryParameters: {'username': email, 'password': password},
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
          _setLoggedOut();
          notifyListeners();
          return false;
        }
        final tokenStr = data['token']?.toString();
        if (tokenStr == null || tokenStr.isEmpty) {
          _setLoggedOut();
          notifyListeners();
          return false;
        }
        _token = tokenStr;
        _isFirstLogin = true;
        _isLoggedin = true;
        tokenResponseModel = TokenResponseModel.fromJson(data);
        final userData = jsonEncode({'token': _token});
        await SecureStorage.saveUserData(userData);
        await SecureStorage.saveToken(_token);
        await SecureStorage.saveLoginStatus(true);
        notifyListeners();
        return true;
      }

      if (response.statusCode == 401) {
        _setLoggedOut();
        notifyListeners();
        return false;
      }

      _setLoggedOut();
      notifyListeners();
      return false;
    } catch (e) {
      _setLoggedOut();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoggedOut() {
    _token = '';
    _isLoggedin = false;
    tokenResponseModel = TokenResponseModel();
  }

  Future<void> removeToken() async {
    await SecureStorage.deleteToken();
    await SecureStorage.saveLoginStatus(false);
    _token = '';
    _isLoggedin = false;
    tokenResponseModel = TokenResponseModel();
    notifyListeners();
  }

  Future<void> getToken() async {
    await loadStoredToken();
  }

  Future<void> checkCompleted() async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        _isCompleted = false;
        notifyListeners();
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
        _isCompleted = extractedData['complete'] == true;
      } else {
        _isCompleted = false;
      }
      notifyListeners();
    } catch (e) {
      _isCompleted = false;
      notifyListeners();
    }
  }

  Future<void> getAddresses() async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        _addressItems = [];
        notifyListeners();
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
      _addressItems = addressMain.addressData;
      notifyListeners();
    } catch (e) {
      _addressItems = [];
      notifyListeners();
    }
  }

  Future<void> updateAddress(List<Address> addressList) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        _addressItems = addressList;
        notifyListeners();
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
        body: jsonEncode(AddressMain(addressData: addressList)),
      );
      final extractedData = json.decode(response.body);
      final addressMain = AddressMain.fromJson(extractedData);
      _addressItems = addressMain.addressData;
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getOrder(List<Address> addressList) async {
    try {
      final t = await SecureStorage.getToken();
      if (t == null || t.isEmpty) {
        _addressItems = addressList;
        notifyListeners();
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
        body: json.encode(AddressMain(addressData: addressList)),
      );
      _addressItems = addressList;
      notifyListeners();
    } catch (e) {
      _addressItems = addressList;
      notifyListeners();
    }
  }

  Future<void> selectAddress(Address address) async {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> retrieveRegionList() async {
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
      _regionItems =
          extractedData.map((i) => Region.fromJson(i as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retrieveRegion(int regionId) async {
    final url = Urls.rootUrl + Urls.regionEndPoint + '/$regionId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    _regionData = Region.fromJson(extractedData);
    notifyListeners();
  }
}
