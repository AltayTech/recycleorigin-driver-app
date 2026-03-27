import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_event.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_state.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/delivery_main.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Delivery queue, stats, and POST delivery to store.
class DeliveriesBloc extends Bloc<DeliveriesEvent, DeliveriesState> {
  DeliveriesBloc() : super(DeliveriesState.initial()) {
    on<DeliveriesSearchParamsChanged>(_onSearchParamsChanged);
    on<DeliveriesSearchBuilderApplied>(_onSearchBuilderApplied);
    on<DeliveriesWasteCartItemsSet>(_onWasteCartItemsSet);
    on<DeliveriesAddWasteCartRequested>(_onAddWasteCart);
    on<DeliveriesAddInitialWasteCartRequested>(_onAddInitialWasteCart);
    on<DeliveriesUpdateWasteCartRequested>(_onUpdateWasteCart);
    on<DeliveriesRemoveWasteCartRequested>(_onRemoveWasteCart);
    on<DeliveriesSendRequestRequested>(_onSendRequest);
    on<DeliveriesSearchCollectItemsRequested>(_onSearchCollectItems);
    on<DeliveriesRetrieveCollectItemRequested>(_onRetrieveCollectItem);
    on<DeliveriesGetCollectedItemsToDeliverRequested>(
        _onGetCollectedItemsToDeliver);
    on<DeliveriesRequestWasteItemSet>(_onRequestWasteItemSet);
  }

  void searchBuilder() => add(DeliveriesSearchBuilderApplied());

  set sPage(int value) => add(DeliveriesSearchParamsChanged(sPage: value));
  set sPerPage(int value) =>
      add(DeliveriesSearchParamsChanged(sPerPage: value));
  set sOrder(String value) => add(DeliveriesSearchParamsChanged(sOrder: value));
  set sOrderBy(String value) =>
      add(DeliveriesSearchParamsChanged(sOrderBy: value));
  set sCategory(Object? value) =>
      add(DeliveriesSearchParamsChanged(sCategory: value));

  set wasteCartItems(List<WasteCart> value) {
    add(DeliveriesWasteCartItemsSet(value));
  }

  DeliveryWasteItem? get deliveriesWasteItem => state.requestWasteItem;

  Future<void> addWasteCart(WasteCart wasteCart, bool isAdded) {
    final c = Completer<void>();
    add(DeliveriesAddWasteCartRequested(wasteCart, isAdded, completer: c));
    return c.future;
  }

  Future<void> addInitialWasteCart(List<Collect> wastesCart, bool isAdded) {
    final c = Completer<void>();
    add(DeliveriesAddInitialWasteCartRequested(wastesCart, isAdded,
        completer: c));
    return c.future;
  }

  Future<void> updateWasteCart(
    WasteCart waste,
    String exactWeight,
    bool isAdded,
  ) {
    final c = Completer<void>();
    add(DeliveriesUpdateWasteCartRequested(
      waste,
      exactWeight,
      isAdded,
      completer: c,
    ));
    return c.future;
  }

  Future<void> removeWasteCart(int wasteId) {
    final c = Completer<void>();
    add(DeliveriesRemoveWasteCartRequested(wasteId, completer: c));
    return c.future;
  }

  Future<void> sendRequest(int storeId, bool isLogin) {
    final c = Completer<void>();
    add(DeliveriesSendRequestRequested(storeId, isLogin, completer: c));
    return c.future;
  }

  Future<void> searchCollectItems() {
    final c = Completer<void>();
    add(DeliveriesSearchCollectItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveCollectItem(int collectId) {
    final c = Completer<void>();
    add(DeliveriesRetrieveCollectItemRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> getCollectedItemsToDeliver() {
    final c = Completer<void>();
    add(DeliveriesGetCollectedItemsToDeliverRequested(completer: c));
    return c.future;
  }

  void _onSearchParamsChanged(
    DeliveriesSearchParamsChanged event,
    Emitter<DeliveriesState> emit,
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
    DeliveriesSearchBuilderApplied event,
    Emitter<DeliveriesState> emit,
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
    DeliveriesWasteCartItemsSet event,
    Emitter<DeliveriesState> emit,
  ) {
    emit(state.copyWith(wasteCartItems: event.items));
  }

  void _onRequestWasteItemSet(
    DeliveriesRequestWasteItemSet event,
    Emitter<DeliveriesState> emit,
  ) {
    emit(state.copyWith(requestWasteItem: event.value));
  }

  Future<void> _onAddWasteCart(
    DeliveriesAddWasteCartRequested event,
    Emitter<DeliveriesState> emit,
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
    DeliveriesAddInitialWasteCartRequested event,
    Emitter<DeliveriesState> emit,
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
            exact_price: c.estimated_price,
            exact_weight: c.estimated_weight,
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
    DeliveriesUpdateWasteCartRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    try {
      final next = List<WasteCart>.from(state.wasteCartItems);
      next
          .firstWhere((prod) => prod.pasmand.id == event.waste.pasmand.id)
          .exact_weight = event.exactWeight.toString();
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
    DeliveriesRemoveWasteCartRequested event,
    Emitter<DeliveriesState> emit,
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
    DeliveriesSendRequestRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    try {
      if (event.isLogin) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token')!;
        final url = Urls.rootUrl +
            Urls.deliveriesEndPoint +
            '?store_id=${event.storeId}';
        await post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
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
    DeliveriesSearchCollectItemsRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.deliveriesEndPoint + state.searchEndPoint;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(
          state.copyWith(
            deliveriesItems: [],
            clearSearchDetails: true,
          ),
        );
        event.completer?.complete();
        return;
      }
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
        final deliveryMain = DeliveryMain.fromJson(extractedData);
        emit(
          state.copyWith(
            deliveriesItems: deliveryMain.requestWasteItem,
            searchDetails: deliveryMain.searchDetail,
            token: token,
          ),
        );
      } else {
        emit(
          state.copyWith(
            deliveriesItems: [],
            clearSearchDetails: true,
          ),
        );
      }
      event.completer?.complete();
    } catch (error, st) {
      emit(
        state.copyWith(
          deliveriesItems: [],
          clearSearchDetails: true,
        ),
      );
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveCollectItem(
    DeliveriesRetrieveCollectItemRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.deliveriesEndPoint + '/${event.collectId}';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')!;
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final extractedData = json.decode(response.body) as dynamic;
      final item = DeliveryWasteItem.fromJson(extractedData);
      emit(state.copyWith(requestWasteItem: item, token: token));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onGetCollectedItemsToDeliver(
    DeliveriesGetCollectedItemsToDeliverRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    final url = Urls.rootUrl + Urls.deliveriesEndPoint + '/stat';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')!;
      final response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List;
        final collects = extractedData.map((i) => Collect.fromJson(i)).toList();
        emit(
          state.copyWith(
            toDeliveryCollectItems: collects,
            token: token,
          ),
        );
      } else {
        emit(state.copyWith(toDeliveryCollectItems: []));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }
}
