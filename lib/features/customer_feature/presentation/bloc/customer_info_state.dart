import 'dart:io';

import 'package:recycleorigindriver/core/models/city.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/models/province.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/core/models/status.dart';
import 'package:recycleorigindriver/core/models/transaction.dart';

/// Driver profile, wallet transactions, shop info, and form lookups.
class CustomerInfoState {
  const CustomerInfoState({
    required this.payUrl,
    required this.currentOrderId,
    required this.chequeImageList,
    required this.shop,
    required this.driver,
    required this.token,
    required this.searchEndPoint,
    required this.searchKey,
    required this.sPage,
    required this.sPerPage,
    required this.sOrder,
    required this.sOrderBy,
    required this.transactionItems,
    required this.searchDetails,
    required this.transactionItem,
    required this.provincesItems,
    required this.citiesItems,
    required this.typesItems,
  });

  final String payUrl;
  final int currentOrderId;
  final List<File> chequeImageList;
  final Shop? shop;
  final Driver driver;
  final String token;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final List<Transaction> transactionItems;
  final SearchDetail? searchDetails;
  final Transaction? transactionItem;
  final List<Province> provincesItems;
  final List<City> citiesItems;
  final List<Status> typesItems;

  Driver get driverZero => Driver.fromJson(null);

  CustomerInfoState copyWith({
    String? payUrl,
    int? currentOrderId,
    List<File>? chequeImageList,
    Shop? shop,
    Driver? driver,
    String? token,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    List<Transaction>? transactionItems,
    SearchDetail? searchDetails,
    Transaction? transactionItem,
    List<Province>? provincesItems,
    List<City>? citiesItems,
    List<Status>? typesItems,
    bool clearShop = false,
    bool clearSearchDetails = false,
    bool clearTransactionItem = false,
  }) {
    return CustomerInfoState(
      payUrl: payUrl ?? this.payUrl,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      chequeImageList: chequeImageList ?? this.chequeImageList,
      shop: clearShop ? null : (shop ?? this.shop),
      driver: driver ?? this.driver,
      token: token ?? this.token,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      transactionItems: transactionItems ?? this.transactionItems,
      searchDetails:
          clearSearchDetails ? null : (searchDetails ?? this.searchDetails),
      transactionItem: clearTransactionItem
          ? null
          : (transactionItem ?? this.transactionItem),
      provincesItems: provincesItems ?? this.provincesItems,
      citiesItems: citiesItems ?? this.citiesItems,
      typesItems: typesItems ?? this.typesItems,
    );
  }

  static CustomerInfoState initial() => CustomerInfoState(
        payUrl: '',
        currentOrderId: 0,
        chequeImageList: [],
        shop: null,
        driver: Driver.fromJson(null),
        token: '',
        searchEndPoint: '',
        searchKey: '',
        sPage: 1,
        sPerPage: 10,
        sOrder: 'desc',
        sOrderBy: 'date',
        transactionItems: [],
        searchDetails: null,
        transactionItem: null,
        provincesItems: [],
        citiesItems: [],
        typesItems: [],
      );
}
