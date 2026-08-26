import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_event.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_state.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/delivery_main.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/waste_cart.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

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
      _onGetCollectedItemsToDeliver,
    );
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
    add(
      DeliveriesAddInitialWasteCartRequested(wastesCart, isAdded, completer: c),
    );
    return c.future;
  }

  Future<void> updateWasteCart(
    WasteCart waste,
    String exactWeight,
    bool isAdded,
  ) {
    final c = Completer<void>();
    add(
      DeliveriesUpdateWasteCartRequested(
        waste,
        exactWeight,
        isAdded,
        completer: c,
      ),
    );
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
              .firstWhere((prod) => prod.waste.id == event.wasteCart.waste.id)
              .isAdded =
          event.isAdded;
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
            waste: c.waste,
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
          .firstWhere((prod) => prod.waste.id == event.waste.waste.id)
          .exact_weight = event.exactWeight
          .toString();
      next.firstWhere((prod) => prod.waste.id == event.waste.waste.id).isAdded =
          event.isAdded;
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
        state.wasteCartItems.firstWhere(
          (prod) => prod.waste.id == event.wasteId,
        ),
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
        await ApiProvider.client.post<dynamic>(
          'recycleorigin/v1${Urls.deliveriesEndPoint}',
          queryParameters: {'store_id': event.storeId},
        );
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
    final path =
        'recycleorigin/v1${Urls.deliveriesEndPoint}${state.searchEndPoint}';
    try {
      final result = await ApiProvider.client.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData != null) {
        final deliveryMain = DeliveryMain.fromJson(extractedData);
        emit(
          state.copyWith(
            deliveriesItems: deliveryMain.requestWasteItem,
            searchDetails: deliveryMain.searchDetail,
          ),
        );
      } else {
        emit(state.copyWith(deliveriesItems: [], clearSearchDetails: true));
      }
      event.completer?.complete();
    } catch (error, st) {
      emit(state.copyWith(deliveriesItems: [], clearSearchDetails: true));
      event.completer?.completeError(error, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveCollectItem(
    DeliveriesRetrieveCollectItemRequested event,
    Emitter<DeliveriesState> emit,
  ) async {
    final path =
        'recycleorigin/v1${Urls.deliveriesEndPoint}/${event.collectId}';
    try {
      final result = await ApiProvider.client.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData == null) {
        throw Exception(result.errorOrNull ?? 'Delivery not found');
      }
      final item = DeliveryWasteItem.fromJson(extractedData);
      emit(state.copyWith(requestWasteItem: item));
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
    final path = 'recycleorigin/v1${Urls.deliveriesEndPoint}/stat';
    try {
      final result = await ApiProvider.client.get<List<dynamic>>(
        path,
        parser: (data) => data as List<dynamic>,
      );
      final extractedData = result.valueOrNull ?? <dynamic>[];
      final collects = extractedData.map((i) => Collect.fromJson(i)).toList();
      emit(state.copyWith(toDeliveryCollectItems: collects));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }
}
