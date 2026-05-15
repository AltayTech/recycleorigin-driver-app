import 'dart:async';

import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';

abstract class DeliveriesEvent {}

final class DeliveriesSearchParamsChanged extends DeliveriesEvent {
  DeliveriesSearchParamsChanged({
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

final class DeliveriesSearchBuilderApplied extends DeliveriesEvent {
  DeliveriesSearchBuilderApplied();
}

final class DeliveriesWasteCartItemsSet extends DeliveriesEvent {
  DeliveriesWasteCartItemsSet(this.items);
  final List<WasteCart> items;
}

final class DeliveriesAddWasteCartRequested extends DeliveriesEvent {
  DeliveriesAddWasteCartRequested(this.wasteCart, this.isAdded,
      {this.completer});
  final WasteCart wasteCart;
  final bool isAdded;
  final Completer<void>? completer;
}

final class DeliveriesAddInitialWasteCartRequested extends DeliveriesEvent {
  DeliveriesAddInitialWasteCartRequested(this.wastesCart, this.isAdded,
      {this.completer});
  final List<Collect> wastesCart;
  final bool isAdded;
  final Completer<void>? completer;
}

final class DeliveriesUpdateWasteCartRequested extends DeliveriesEvent {
  DeliveriesUpdateWasteCartRequested(
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

final class DeliveriesRemoveWasteCartRequested extends DeliveriesEvent {
  DeliveriesRemoveWasteCartRequested(this.wasteId, {this.completer});
  final int wasteId;
  final Completer<void>? completer;
}

final class DeliveriesSendRequestRequested extends DeliveriesEvent {
  DeliveriesSendRequestRequested(this.storeId, this.isLogin, {this.completer});
  final int storeId;
  final bool isLogin;
  final Completer<void>? completer;
}

final class DeliveriesSearchCollectItemsRequested extends DeliveriesEvent {
  DeliveriesSearchCollectItemsRequested({this.completer});
  final Completer<void>? completer;
}

final class DeliveriesRetrieveCollectItemRequested extends DeliveriesEvent {
  DeliveriesRetrieveCollectItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class DeliveriesGetCollectedItemsToDeliverRequested
    extends DeliveriesEvent {
  DeliveriesGetCollectedItemsToDeliverRequested({this.completer});
  final Completer<void>? completer;
}

final class DeliveriesRequestWasteItemSet extends DeliveriesEvent {
  DeliveriesRequestWasteItemSet(this.value);
  final DeliveryWasteItem value;
}
