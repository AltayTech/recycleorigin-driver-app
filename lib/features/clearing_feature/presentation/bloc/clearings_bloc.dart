import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_event.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_state.dart';
import 'package:recycleorigindriver/core/models/clearing_main.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/network/urls.dart';

/// Settlement requests and shared delivery helpers used on the clear screen.
class ClearingsBloc extends Bloc<ClearingsEvent, ClearingsState> {
  ClearingsBloc() : super(ClearingsState.initial()) {
    on<ClearingsSearchParamsChanged>(_onSearchParamsChanged);
    on<ClearingsSearchBuilderApplied>(_onSearchBuilderApplied);
    on<ClearingsWasteCartItemsSet>(_onWasteCartItemsSet);
    on<ClearingsAddWasteCartRequested>(_onAddWasteCart);
    on<ClearingsAddInitialWasteCartRequested>(_onAddInitialWasteCart);
    on<ClearingsUpdateWasteCartRequested>(_onUpdateWasteCart);
    on<ClearingsRemoveWasteCartRequested>(_onRemoveWasteCart);
    on<ClearingsSendRequestRequested>(_onSendRequest);
    on<ClearingsSearchClearingsItemsRequested>(_onSearchClearingsItems);
    on<ClearingsRetrieveCollectItemRequested>(_onRetrieveCollectItem);
    on<ClearingsGetCollectedItemsToDeliverRequested>(
        _onGetCollectedItemsToDeliver);
    on<ClearingsRequestWasteItemSet>(_onRequestWasteItemSet);
  }

  void searchBuilder() => add(ClearingsSearchBuilderApplied());

  set sPage(int value) => add(ClearingsSearchParamsChanged(sPage: value));
  set sPerPage(int value) => add(ClearingsSearchParamsChanged(sPerPage: value));
  set sOrder(String value) => add(ClearingsSearchParamsChanged(sOrder: value));
  set sOrderBy(String value) =>
      add(ClearingsSearchParamsChanged(sOrderBy: value));
  set sCategory(Object? value) =>
      add(ClearingsSearchParamsChanged(sCategory: value));

  set wasteCartItems(List<WasteCart> value) {
    add(ClearingsWasteCartItemsSet(value));
  }

  DeliveryWasteItem? get deliveriesWasteItem => state.requestWasteItem;

  Future<void> addWasteCart(WasteCart wasteCart, bool isAdded) {
    final c = Completer<void>();
    add(ClearingsAddWasteCartRequested(wasteCart, isAdded, completer: c));
    return c.future;
  }

  Future<void> addInitialWasteCart(List<Collect> wastesCart, bool isAdded) {
    final c = Completer<void>();
    add(ClearingsAddInitialWasteCartRequested(wastesCart, isAdded,
        completer: c));
    return c.future;
  }

  Future<void> updateWasteCart(
    WasteCart waste,
    String exactWeight,
    bool isAdded,
  ) {
    final c = Completer<void>();
    add(ClearingsUpdateWasteCartRequested(
      waste,
      exactWeight,
      isAdded,
      completer: c,
    ));
    return c.future;
  }

  Future<void> removeWasteCart(int wasteId) {
    final c = Completer<void>();
    add(ClearingsRemoveWasteCartRequested(wasteId, completer: c));
    return c.future;
  }

  Future<void> sendRequest(int storeId, bool isLogin) {
    final c = Completer<void>();
    add(ClearingsSendRequestRequested(storeId, isLogin, completer: c));
    return c.future;
  }

  Future<void> searchCleaingsItems() {
    final c = Completer<void>();
    add(ClearingsSearchClearingsItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveCollectItem(int collectId) {
    final c = Completer<void>();
    add(ClearingsRetrieveCollectItemRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> getCollectedItemsToDeliver() {
    final c = Completer<void>();
    add(ClearingsGetCollectedItemsToDeliverRequested(completer: c));
    return c.future;
  }

  void _onSearchParamsChanged(
    ClearingsSearchParamsChanged event,
    Emitter<ClearingsState> emit,
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
    ClearingsSearchBuilderApplied event,
    Emitter<ClearingsState> emit,
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
    ClearingsWasteCartItemsSet event,
    Emitter<ClearingsState> emit,
  ) {
    emit(state.copyWith(wasteCartItems: event.items));
  }

  void _onRequestWasteItemSet(
    ClearingsRequestWasteItemSet event,
    Emitter<ClearingsState> emit,
  ) {
    emit(state.copyWith(requestWasteItem: event.value));
  }

  Future<void> _onAddWasteCart(
    ClearingsAddWasteCartRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    try {
      final next = List<WasteCart>.from(state.wasteCartItems);
      next
          .firstWhere((prod) => prod.waste.id == event.wasteCart.waste.id)
          .isAdded = event.isAdded;
      emit(state.copyWith(wasteCartItems: next));
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onAddInitialWasteCart(
    ClearingsAddInitialWasteCartRequested event,
    Emitter<ClearingsState> emit,
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
    ClearingsUpdateWasteCartRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    try {
      final next = List<WasteCart>.from(state.wasteCartItems);
      next
          .firstWhere((prod) => prod.waste.id == event.waste.waste.id)
          .exact_weight = event.exactWeight.toString();
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
    ClearingsRemoveWasteCartRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    final next = List<WasteCart>.from(state.wasteCartItems)
      ..remove(
        state.wasteCartItems
            .firstWhere((prod) => prod.waste.id == event.wasteId),
      );
    emit(state.copyWith(wasteCartItems: next));
    event.completer?.complete();
  }

  Future<void> _onSendRequest(
    ClearingsSendRequestRequested event,
    Emitter<ClearingsState> emit,
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

  Future<void> _onSearchClearingsItems(
    ClearingsSearchClearingsItemsRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.clearingEndPoint}${state.searchEndPoint}';
    try {
      final result = await ApiProvider.client.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData != null) {
        final deliveryMain = ClearingMain.fromJson(extractedData);
        emit(
          state.copyWith(
            deliveriesItems: deliveryMain.clearings,
            searchDetails: deliveryMain.searchDetail,
          ),
        );
      } else {
        emit(state.copyWith(deliveriesItems: []));
      }
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }

  Future<void> _onRetrieveCollectItem(
    ClearingsRetrieveCollectItemRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.deliveriesEndPoint}/${event.collectId}';
    try {
      final result = await ApiProvider.client.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData == null) {
        throw Exception(result.errorOrNull ?? 'Item not found');
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
    ClearingsGetCollectedItemsToDeliverRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.deliveriesEndPoint}/stat';
    try {
      final result = await ApiProvider.client.get<List<dynamic>>(
        path,
        parser: (data) => data as List<dynamic>,
      );
      final extractedData = result.valueOrNull ?? <dynamic>[];
      final collects = extractedData.map((i) => Collect.fromJson(i)).toList();
      emit(
        state.copyWith(
          toDeliveryCollectItems: collects,
        ),
      );
      event.completer?.complete();
    } catch (error) {
      event.completer?.completeError(error);
      rethrow;
    }
  }
}
