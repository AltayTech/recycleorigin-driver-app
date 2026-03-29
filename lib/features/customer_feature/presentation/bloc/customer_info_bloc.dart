import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_event.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/core/models/city.dart';
import 'package:recycleorigindriver/core/models/customer.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/models/province.dart';
import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/core/models/status.dart';
import 'package:recycleorigindriver/core/models/transaction.dart';
import 'package:recycleorigindriver/core/models/transaction_main.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// Driver profile, transactions, shop, and clearing request.
class CustomerInfoBloc extends Bloc<CustomerInfoEvent, CustomerInfoState> {
  /// Empty driver placeholder (same as legacy `driver_zero`).
  Driver get driverZero => state.driverZero;

  CustomerInfoBloc() : super(CustomerInfoState.initial()) {
    on<CustomerInfoGetCustomerRequested>(_onGetCustomer);
    on<CustomerInfoSendCustomerRequested>(_onSendCustomer);
    on<CustomerInfoFetchShopDataRequested>(_onFetchShopData);
    on<CustomerInfoSearchParamsChanged>(_onSearchParamsChanged);
    on<CustomerInfoSearchBuilderApplied>(_onSearchBuilderApplied);
    on<CustomerInfoSearchTransactionItemsRequested>(_onSearchTransactionItems);
    on<CustomerInfoRetrieveItemRequested>(_onRetrieveItem);
    on<CustomerInfoGetProvincesRequested>(_onGetProvinces);
    on<CustomerInfoGetCitiesRequested>(_onGetCities);
    on<CustomerInfoGetTypesRequested>(_onGetTypes);
    on<CustomerInfoSendClearingRequestRequested>(_onSendClearingRequest);
    on<CustomerInfoDriverSet>(_onDriverSet);
  }

  set driver(Driver value) => add(CustomerInfoDriverSet(value));

  void searchBuilder() => add(CustomerInfoSearchBuilderApplied());

  set sPage(int value) => add(CustomerInfoSearchParamsChanged(sPage: value));
  set sPerPage(int value) =>
      add(CustomerInfoSearchParamsChanged(sPerPage: value));
  set sOrder(String value) =>
      add(CustomerInfoSearchParamsChanged(sOrder: value));
  set sOrderBy(String value) =>
      add(CustomerInfoSearchParamsChanged(sOrderBy: value));

  Future<void> getCustomer() {
    final c = Completer<void>();
    add(CustomerInfoGetCustomerRequested(completer: c));
    return c.future;
  }

  Future<void> sendCustomer(Customer customer) {
    final c = Completer<void>();
    add(CustomerInfoSendCustomerRequested(customer, completer: c));
    return c.future;
  }

  Future<void> fetchShopData() {
    final c = Completer<void>();
    add(CustomerInfoFetchShopDataRequested(completer: c));
    return c.future;
  }

  Future<void> searchTransactionItems() {
    final c = Completer<void>();
    add(CustomerInfoSearchTransactionItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveItem(int collectId) {
    final c = Completer<void>();
    add(CustomerInfoRetrieveItemRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> getProvinces() {
    final c = Completer<void>();
    add(CustomerInfoGetProvincesRequested(completer: c));
    return c.future;
  }

  Future<void> getCities(int provinceId) {
    final c = Completer<void>();
    add(CustomerInfoGetCitiesRequested(provinceId, completer: c));
    return c.future;
  }

  Future<void> getTypes() {
    final c = Completer<void>();
    add(CustomerInfoGetTypesRequested(completer: c));
    return c.future;
  }

  Future<void> sendClearingRequest(
    String money,
    String shaba,
    bool isLogin,
  ) {
    final c = Completer<void>();
    add(CustomerInfoSendClearingRequestRequested(
      money,
      shaba,
      isLogin,
      completer: c,
    ));
    return c.future;
  }

  void _onDriverSet(
    CustomerInfoDriverSet event,
    Emitter<CustomerInfoState> emit,
  ) {
    emit(state.copyWith(driver: event.driver));
  }

  void _onSearchParamsChanged(
    CustomerInfoSearchParamsChanged event,
    Emitter<CustomerInfoState> emit,
  ) {
    emit(
      state.copyWith(
        searchKey: event.searchKey ?? state.searchKey,
        sPage: event.sPage ?? state.sPage,
        sPerPage: event.sPerPage ?? state.sPerPage,
        sOrder: event.sOrder ?? state.sOrder,
        sOrderBy: event.sOrderBy ?? state.sOrderBy,
      ),
    );
  }

  void _onSearchBuilderApplied(
    CustomerInfoSearchBuilderApplied event,
    Emitter<CustomerInfoState> emit,
  ) {
    final s = state;
    var searchEndPoint = '';
    if (s.searchKey != '') {
      searchEndPoint = '?search=${s.searchKey}';
      searchEndPoint = '$searchEndPoint&page=${s.sPage}&per_page=${s.sPerPage}';
    } else {
      searchEndPoint = '?page=${s.sPage}&per_page=${s.sPerPage}';
    }
    if (s.sOrder != '') {
      searchEndPoint = '$searchEndPoint&order=${s.sOrder}';
    }
    if (s.sOrderBy != '') {
      searchEndPoint = '$searchEndPoint&orderby=${s.sOrderBy}';
    }
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  Future<void> _onGetCustomer(
    CustomerInfoGetCustomerRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.driverEndPoint;
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      event.completer?.complete();
      return;
    }
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid driver profile response');
      }
      final driver = Driver.fromJson(decoded);
      emit(state.copyWith(driver: driver, token: token));
      event.completer?.complete();
    } catch (error, st) {
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  /// Body for POST /driver — matches [models.CustomerUpdateRequest] on the server.
  Map<String, dynamic> _driverProfileUpdatePayload(Customer customer) {
    return {
      'customer_type': customer.type.toJson(),
      'customer_data': customer.personalData.toJson(),
    };
  }

  Future<void> _onSendCustomer(
    CustomerInfoSendCustomerRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.driverEndPoint;
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      event.completer?.completeError(StateError('No auth token'));
      return;
    }
    try {
      final response = await post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(_driverProfileUpdatePayload(event.customer)),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      try {
        await _refreshDriverAfterSave(emit, token);
      } catch (_) {
        // POST succeeded; follow-up GET is best-effort (avoids false "save failed").
      }
      event.completer?.complete();
    } catch (error, st) {
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  Future<void> _refreshDriverAfterSave(
    Emitter<CustomerInfoState> emit,
    String token,
  ) async {
    final url = Urls.rootUrl + Urls.driverEndPoint;
    final response = await get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid driver profile response');
    }
    final driver = Driver.fromJson(decoded);
    emit(state.copyWith(driver: driver, token: token));
  }

  Future<void> _onFetchShopData(
    CustomerInfoFetchShopDataRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.shopEndPoint;
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body) as dynamic;
      final shopData = Shop.fromJson(extractedData);
      emit(state.copyWith(shop: shopData));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onSearchTransactionItems(
    CustomerInfoSearchTransactionItemsRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.transactionsEndPoint + state.searchEndPoint;
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      emit(
        state.copyWith(
          transactionItems: [],
          clearSearchDetails: true,
        ),
      );
      event.completer?.complete();
      return;
    }
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final transactionMain = TransactionMain.fromJson(extractedData);
        emit(
          state.copyWith(
            transactionItems: transactionMain.transactions,
            searchDetails: transactionMain.searchDetail,
            token: token,
          ),
        );
      } else {
        emit(
          state.copyWith(
            transactionItems: [],
            clearSearchDetails: true,
          ),
        );
      }
      event.completer?.complete();
    } catch (error, st) {
      emit(
        state.copyWith(
          transactionItems: [],
          clearSearchDetails: true,
        ),
      );
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveItem(
    CustomerInfoRetrieveItemRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.collectsEndPoint + '/${event.collectId}';
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body) as dynamic;
      final transaction = Transaction.fromJson(extractedData);
      emit(state.copyWith(transactionItem: transaction));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onGetProvinces(
    CustomerInfoGetProvincesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.provincesEndPoint;
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        final provinces =
            extractedData.map((i) => Province.fromJson(i)).toList();
        emit(state.copyWith(provincesItems: provinces));
      } else {
        emit(state.copyWith(provincesItems: []));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onGetCities(
    CustomerInfoGetCitiesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.provincesEndPoint + '${event.provinceId}';
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        final cities = extractedData.map((i) => City.fromJson(i)).toList();
        emit(state.copyWith(citiesItems: cities));
      } else {
        emit(state.copyWith(citiesItems: []));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onGetTypes(
    CustomerInfoGetTypesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.typesEndPoint;
    try {
      final response = await get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        final types = extractedData.map((i) => Status.fromJson(i)).toList();
        emit(state.copyWith(typesItems: types));
      } else {
        emit(state.copyWith(typesItems: []));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onSendClearingRequest(
    CustomerInfoSendClearingRequestRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    try {
      if (event.isLogin) {
        final token = await SecureStorage.getToken();
        if (token == null || token.isEmpty) {
          throw StateError('No auth token');
        }
        final url = Urls.rootUrl + Urls.clearingEndPoint;
        await post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(
            {
              'money': event.money,
              'shaba': event.shaba,
            },
          ),
        );
        emit(state.copyWith(token: token));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }
}
