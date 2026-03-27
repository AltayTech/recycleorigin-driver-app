import 'dart:async';

import 'package:recycleorigindriver/models/request/collect.dart';
import 'package:recycleorigindriver/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/models/request/wasteCart.dart';

abstract class ClearingsEvent {}

final class ClearingsSearchParamsChanged extends ClearingsEvent {
  ClearingsSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sOrder,
    this.sOrderBy,
    this.sCategory,
  });

  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final String? sOrder;
  final String? sOrderBy;
  final Object? sCategory;
}

final class ClearingsSearchBuilderApplied extends ClearingsEvent {
  ClearingsSearchBuilderApplied();
}

final class ClearingsWasteCartItemsSet extends ClearingsEvent {
  ClearingsWasteCartItemsSet(this.items);
  final List<WasteCart> items;
}

final class ClearingsAddWasteCartRequested extends ClearingsEvent {
  ClearingsAddWasteCartRequested(this.wasteCart, this.isAdded,
      {this.completer});
  final WasteCart wasteCart;
  final bool isAdded;
  final Completer<void>? completer;
}

final class ClearingsAddInitialWasteCartRequested extends ClearingsEvent {
  ClearingsAddInitialWasteCartRequested(this.wastesCart, this.isAdded,
      {this.completer});
  final List<Collect> wastesCart;
  final bool isAdded;
  final Completer<void>? completer;
}

final class ClearingsUpdateWasteCartRequested extends ClearingsEvent {
  ClearingsUpdateWasteCartRequested(
    this.waste,
    this.exactWeight,
    this.isAdded, {
    this.completer,
  });
  final WasteCart waste;
  final String exactWeight;
  final bool isAdded;
  final Completer<void>? completer;
}

final class ClearingsRemoveWasteCartRequested extends ClearingsEvent {
  ClearingsRemoveWasteCartRequested(this.wasteId, {this.completer});
  final int wasteId;
  final Completer<void>? completer;
}

final class ClearingsSendRequestRequested extends ClearingsEvent {
  ClearingsSendRequestRequested(this.storeId, this.isLogin,
      {this.completer});
  final int storeId;
  final bool isLogin;
  final Completer<void>? completer;
}

final class ClearingsSearchClearingsItemsRequested extends ClearingsEvent {
  ClearingsSearchClearingsItemsRequested({this.completer});
  final Completer<void>? completer;
}

final class ClearingsRetrieveCollectItemRequested extends ClearingsEvent {
  ClearingsRetrieveCollectItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class ClearingsGetCollectedItemsToDeliverRequested
    extends ClearingsEvent {
  ClearingsGetCollectedItemsToDeliverRequested({this.completer});
  final Completer<void>? completer;
}

final class ClearingsRequestWasteItemSet extends ClearingsEvent {
  ClearingsRequestWasteItemSet(this.value);
  final DeliveryWasteItem value;
}
