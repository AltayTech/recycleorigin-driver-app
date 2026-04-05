import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_event.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_state.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/request_waste.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

/// Collect assignments, cart, and collect submission for the driver app.
class WastesBloc extends Bloc<WastesEvent, WastesState> {
  WastesBloc() : super(WastesState.initial()) {
    on<WastesSearchParamsChanged>(_onSearchParamsChanged);
    on<WastesSearchBuilderApplied>(_onSearchBuilderApplied);
    on<WastesWasteCartItemsSet>(_onWasteCartItemsSet);
    on<WastesAddWasteCartRequested>(_onAddWasteCart);
    on<WastesAddInitialWasteCartRequested>(_onAddInitialWasteCart);
    on<WastesUpdateWasteCartRequested>(_onUpdateWasteCart);
    on<WastesRemoveWasteCartRequested>(_onRemoveWasteCart);
    on<WastesSendRequestRequested>(_onSendRequest);
    on<WastesSearchCollectItemsRequested>(_onSearchCollectItems);
    on<WastesRetrieveCollectItemRequested>(_onRetrieveCollectItem);
    on<WastesAcceptCollectRequested>(_onAcceptCollect);
    on<WastesRejectCollectRequested>(_onRejectCollect);
    on<WastesConfirmPickupRequested>(_onConfirmPickup);
    on<WastesRequestWasteItemReplace>(_onReplaceRequestWasteItem);
  }

  void _onReplaceRequestWasteItem(
    WastesRequestWasteItemReplace event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(requestWasteItem: event.value));
  }

  void searchBuilder() => add(WastesSearchBuilderApplied());

  set sPage(int value) => add(WastesSearchParamsChanged(sPage: value));
  set sPerPage(int value) => add(WastesSearchParamsChanged(sPerPage: value));
  set sOrder(String value) => add(WastesSearchParamsChanged(sOrder: value));
  set sOrderBy(String value) => add(WastesSearchParamsChanged(sOrderBy: value));

  set requestWasteItem(RequestWasteItem value) {
    add(WastesRequestWasteItemReplace(value));
  }

  set wasteCartItems(List<WasteCart> value) {
    add(WastesWasteCartItemsSet(value));
  }

  Future<void> addWasteCart(WasteCart wasteCart, bool isAdded) {
    final c = Completer<void>();
    add(WastesAddWasteCartRequested(wasteCart, isAdded, completer: c));
    return c.future;
  }

  Future<void> addInitialWasteCart(
    List<Collect> wastesCart,
    bool isAdded,
    bool isCollected,
  ) {
    final c = Completer<void>();
    add(WastesAddInitialWasteCartRequested(
      wastesCart,
      isAdded,
      isCollected,
      completer: c,
    ));
    return c.future;
  }

  Future<void> updateWasteCart(
    WasteCart waste,
    String exactWeight,
    bool isAdded,
  ) {
    final c = Completer<void>();
    add(WastesUpdateWasteCartRequested(
      waste,
      exactWeight,
      isAdded,
      completer: c,
    ));
    return c.future;
  }

  Future<void> removeWasteCart(int wasteId) {
    final c = Completer<void>();
    add(WastesRemoveWasteCartRequested(wasteId, completer: c));
    return c.future;
  }

  Future<void> sendRequest(RequestWaste request, bool isLogin, int id) {
    final c = Completer<void>();
    add(WastesSendRequestRequested(request, isLogin, id, completer: c));
    return c.future;
  }

  Future<void> searchCollectItems() {
    final c = Completer<void>();
    add(WastesSearchCollectItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveCollectItem(int collectId) {
    final c = Completer<void>();
    add(WastesRetrieveCollectItemRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> acceptCollectRequest(int collectId) {
    final c = Completer<void>();
    add(WastesAcceptCollectRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> rejectCollectRequest(int collectId) {
    final c = Completer<void>();
    add(WastesRejectCollectRequested(collectId, completer: c));
    return c.future;
  }

  /// Sends corrected exact weights for each waste item and confirms pickup.
  Future<void> confirmPickup(
    int collectId,
    List<Map<String, dynamic>> items,
  ) {
    final c = Completer<void>();
    add(WastesConfirmPickupRequested(collectId, items, completer: c));
    return c.future;
  }

  void _onSearchParamsChanged(
    WastesSearchParamsChanged event,
    Emitter<WastesState> emit,
  ) {
    emit(
      state.copyWith(
        searchKey: event.searchKey ?? state.searchKey,
        sPage: event.sPage ?? state.sPage,
        sPerPage: event.sPerPage ?? state.sPerPage,
        sOrder: event.sOrder ?? state.sOrder,
        sOrderBy: event.sOrderBy ?? state.sOrderBy,
        sCategory: event.sCategory ?? state.sCategory,
      ),
    );
  }

  void _onSearchBuilderApplied(
    WastesSearchBuilderApplied event,
    Emitter<WastesState> emit,
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
    if (!(s.sCategory == '' || s.sCategory == null)) {
      searchEndPoint = '$searchEndPoint&category=${s.sCategory}';
    }
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  void _onWasteCartItemsSet(
    WastesWasteCartItemsSet event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(wasteCartItems: event.items));
  }

  Future<void> _onAddWasteCart(
    WastesAddWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      final next = List<WasteCart>.from(state.wasteCartItems);
      next
          .firstWhere((prod) => prod.pasmand.id == event.wasteCart.pasmand.id)
          .isAdded = event.isAdded;
      emit(state.copyWith(wasteCartItems: next));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onAddInitialWasteCart(
    WastesAddInitialWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      final list = <WasteCart>[];
      for (var i = 0; i < event.wastesCart.length; i++) {
        final c = event.wastesCart[i];
        list.add(
          WasteCart(
            pasmand: c.pasmand,
            estimated_weight: c.estimated_weight,
            estimated_price: c.estimated_price,
            exact_price: event.isCollected ? c.exact_price : c.estimated_price,
            exact_weight:
                event.isCollected ? c.exact_weight : c.estimated_weight,
            isAdded: event.isAdded,
          ),
        );
      }
      emit(state.copyWith(wasteCartItems: list));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onUpdateWasteCart(
    WastesUpdateWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      final next = List<WasteCart>.from(state.wasteCartItems);
      next
          .firstWhere((prod) => prod.pasmand.id == event.waste.pasmand.id)
          .exact_weight = event.exactWeight;
      next
          .firstWhere((prod) => prod.pasmand.id == event.waste.pasmand.id)
          .isAdded = event.isAdded;
      emit(state.copyWith(wasteCartItems: next));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onRemoveWasteCart(
    WastesRemoveWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    final next = List<WasteCart>.from(state.wasteCartItems)
      ..remove(
        state.wasteCartItems
            .firstWhere((prod) => prod.pasmand.id == event.wasteId),
      );
    emit(state.copyWith(wasteCartItems: next));
    event.completer?.complete();
  }

  Future<void> _onSendRequest(
    WastesSendRequestRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      if (event.isLogin) {
        final token = await SecureStorage.getToken();
        if (token == null || token.isEmpty) {
          throw StateError('No auth token');
        }
        final url = Urls.rootUrl + Urls.collectsEndPoint + '/${event.id}';
        await put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(event.request),
        );
        emit(state.copyWith(token: token));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onSearchCollectItems(
    WastesSearchCollectItemsRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        emit(
          state.copyWith(
            collectItems: [],
            searchDetails: null,
            clearSearchDetails: true,
          ),
        );
        event.completer?.complete();
        return;
      }
      final url =
          Urls.rootUrl + Urls.driverCollectsEndPoint + state.searchEndPoint;
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>?;
        if (extractedData == null) {
          emit(
            state.copyWith(
              collectItems: [],
              searchDetails: null,
              token: token,
              clearSearchDetails: true,
            ),
          );
          event.completer?.complete();
          return;
        }
        final dataList = extractedData['data'];
        final detailsJson = extractedData['details'];
        List<RequestWasteItem> items = [];
        if (dataList is List) {
          items = dataList
              .map<RequestWasteItem>(
                (dynamic e) =>
                    RequestWasteItem.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
        SearchDetail? details;
        if (detailsJson != null && detailsJson is Map<String, dynamic>) {
          final total = detailsJson['total'];
          final maxPages = detailsJson['max_pages'];
          details = SearchDetail(
            total: total is int ? total : items.length,
            max_page: maxPages is int ? maxPages : 1,
          );
        } else {
          details = SearchDetail(
            total: items.length,
            max_page: items.isEmpty ? 1 : 1,
          );
        }
        emit(
          state.copyWith(
            collectItems: items,
            searchDetails: details,
            token: token,
          ),
        );
      } else {
        emit(
          state.copyWith(
            collectItems: [],
            searchDetails: null,
            clearSearchDetails: true,
          ),
        );
      }
      event.completer?.complete();
    } catch (error, st) {
      emit(
        state.copyWith(
          collectItems: [],
          searchDetails: null,
          clearSearchDetails: true,
        ),
      );
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveCollectItem(
    WastesRetrieveCollectItemRequested event,
    Emitter<WastesState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.collectsEndPoint + '/${event.collectId}';
    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw StateError('No auth token');
      }
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body) as dynamic;
      final item = RequestWasteItem.fromJson(extractedData);
      emit(state.copyWith(requestWasteItem: item, token: token));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onAcceptCollect(
    WastesAcceptCollectRequested event,
    Emitter<WastesState> emit,
  ) async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('No auth token');
    }
    final url = Urls.rootUrl +
        Urls.driverCollectsEndPoint +
        '/${event.collectId}/accept';
    final response = await post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception(body.isNotEmpty ? body : 'Accept failed');
    }
    emit(state.copyWith(token: token));
    event.completer?.complete();
  }

  Future<void> _onRejectCollect(
    WastesRejectCollectRequested event,
    Emitter<WastesState> emit,
  ) async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('No auth token');
    }
    final url = Urls.rootUrl +
        Urls.driverCollectsEndPoint +
        '/${event.collectId}/reject';
    final response = await post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception(body.isNotEmpty ? body : 'Reject failed');
    }
    emit(state.copyWith(token: token));
    event.completer?.complete();
  }

  Future<void> _onConfirmPickup(
    WastesConfirmPickupRequested event,
    Emitter<WastesState> emit,
  ) async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('No auth token');
    }
    final url = Urls.rootUrl +
        Urls.driverCollectsEndPoint +
        '/${event.collectId}/pickup';
    final response = await post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'items': event.items}),
    );
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception(body.isNotEmpty ? body : 'Pickup confirmation failed');
    }
    emit(state.copyWith(token: token));
    event.completer?.complete();
  }
}
