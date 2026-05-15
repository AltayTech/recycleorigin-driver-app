import 'dart:async';

import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/request_waste.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';

abstract class WastesEvent {}

final class WastesSearchParamsChanged extends WastesEvent {
  WastesSearchParamsChanged({
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

final class WastesSearchBuilderApplied extends WastesEvent {
  WastesSearchBuilderApplied();
}

final class WastesWasteCartItemsSet extends WastesEvent {
  WastesWasteCartItemsSet(this.items);
  final List<WasteCart> items;
}

final class WastesAddWasteCartRequested extends WastesEvent {
  WastesAddWasteCartRequested(this.wasteCart, this.isAdded, {this.completer});
  final WasteCart wasteCart;
  final bool isAdded;
  final Completer<void>? completer;
}

final class WastesAddInitialWasteCartRequested extends WastesEvent {
  WastesAddInitialWasteCartRequested(
    this.wastesCart,
    this.isAdded,
    this.isCollected, {
    this.completer,
  });
  final List<Collect> wastesCart;
  final bool isAdded;
  final bool isCollected;
  final Completer<void>? completer;
}

final class WastesUpdateWasteCartRequested extends WastesEvent {
  WastesUpdateWasteCartRequested(
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

final class WastesRemoveWasteCartRequested extends WastesEvent {
  WastesRemoveWasteCartRequested(this.wasteId, {this.completer});
  final int wasteId;
  final Completer<void>? completer;
}

final class WastesSendRequestRequested extends WastesEvent {
  WastesSendRequestRequested(this.request, this.isLogin, this.id,
      {this.completer});
  final RequestWaste request;
  final bool isLogin;
  final int id;
  final Completer<void>? completer;
}

final class WastesSearchCollectItemsRequested extends WastesEvent {
  WastesSearchCollectItemsRequested({this.completer});
  final Completer<void>? completer;
}

final class WastesRetrieveCollectItemRequested extends WastesEvent {
  WastesRetrieveCollectItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class WastesAcceptCollectRequested extends WastesEvent {
  WastesAcceptCollectRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class WastesRejectCollectRequested extends WastesEvent {
  WastesRejectCollectRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class WastesConfirmPickupRequested extends WastesEvent {
  WastesConfirmPickupRequested(this.collectId, this.items, {this.completer});
  final int collectId;
  final List<Map<String, dynamic>> items;
  final Completer<void>? completer;
}

final class WastesRateCustomerRequested extends WastesEvent {
  WastesRateCustomerRequested(this.collectId, this.score, this.comment,
      {this.completer});
  final int collectId;
  final int score;
  final String comment;
  final Completer<void>? completer;
}

/// Replaces [WastesBloc.state.requestWasteItem] (legacy setter).
final class WastesRequestWasteItemReplace extends WastesEvent {
  WastesRequestWasteItemReplace(this.value);
  final RequestWasteItem value;
}
