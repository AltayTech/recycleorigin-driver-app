import 'dart:async';

import 'package:recycleorigindriver/models/customer.dart';
import 'package:recycleorigindriver/models/driver.dart';

abstract class CustomerInfoEvent {}

final class CustomerInfoGetCustomerRequested extends CustomerInfoEvent {
  CustomerInfoGetCustomerRequested({this.completer});
  final Completer<void>? completer;
}

final class CustomerInfoSendCustomerRequested extends CustomerInfoEvent {
  CustomerInfoSendCustomerRequested(this.customer, {this.completer});
  final Customer customer;
  final Completer<void>? completer;
}

final class CustomerInfoFetchShopDataRequested extends CustomerInfoEvent {
  CustomerInfoFetchShopDataRequested({this.completer});
  final Completer<void>? completer;
}

final class CustomerInfoSearchParamsChanged extends CustomerInfoEvent {
  CustomerInfoSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sOrder,
    this.sOrderBy,
  });

  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final String? sOrder;
  final String? sOrderBy;
}

final class CustomerInfoSearchBuilderApplied extends CustomerInfoEvent {
  CustomerInfoSearchBuilderApplied();
}

final class CustomerInfoSearchTransactionItemsRequested extends CustomerInfoEvent {
  CustomerInfoSearchTransactionItemsRequested({this.completer});
  final Completer<void>? completer;
}

final class CustomerInfoRetrieveItemRequested extends CustomerInfoEvent {
  CustomerInfoRetrieveItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

final class CustomerInfoGetProvincesRequested extends CustomerInfoEvent {
  CustomerInfoGetProvincesRequested({this.completer});
  final Completer<void>? completer;
}

final class CustomerInfoGetCitiesRequested extends CustomerInfoEvent {
  CustomerInfoGetCitiesRequested(this.provinceId, {this.completer});
  final int provinceId;
  final Completer<void>? completer;
}

final class CustomerInfoGetTypesRequested extends CustomerInfoEvent {
  CustomerInfoGetTypesRequested({this.completer});
  final Completer<void>? completer;
}

final class CustomerInfoSendClearingRequestRequested extends CustomerInfoEvent {
  CustomerInfoSendClearingRequestRequested(
    this.money,
    this.shaba,
    this.isLogin, {
    this.completer,
  });
  final String money;
  final String shaba;
  final bool isLogin;
  final Completer<void>? completer;
}

final class CustomerInfoDriverSet extends CustomerInfoEvent {
  CustomerInfoDriverSet(this.driver);
  final Driver driver;
}
