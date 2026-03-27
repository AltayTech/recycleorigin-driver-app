import 'package:recycleorigindriver/models/clearing.dart';
import 'package:recycleorigindriver/models/request/collect.dart';
import 'package:recycleorigindriver/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/models/request/wasteCart.dart';
import 'package:recycleorigindriver/models/search_detail.dart';

/// State for settlement (clearing) list and related delivery helpers.
class ClearingsState {
  const ClearingsState({
    required this.wasteCartItems,
    required this.token,
    required this.deliveriesItems,
    required this.searchDetails,
    required this.requestWasteItem,
    required this.toDeliveryCollectItems,
    required this.searchEndPoint,
    required this.searchKey,
    required this.sPage,
    required this.sPerPage,
    required this.sOrder,
    required this.sOrderBy,
    required this.sCategory,
  });

  final List<WasteCart> wasteCartItems;
  final String token;
  final List<Clearing> deliveriesItems;
  final SearchDetail? searchDetails;
  final DeliveryWasteItem? requestWasteItem;
  final List<Collect> toDeliveryCollectItems;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final Object? sCategory;

  ClearingsState copyWith({
    List<WasteCart>? wasteCartItems,
    String? token,
    List<Clearing>? deliveriesItems,
    SearchDetail? searchDetails,
    DeliveryWasteItem? requestWasteItem,
    List<Collect>? toDeliveryCollectItems,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    Object? sCategory,
    bool clearSearchDetails = false,
    bool clearRequestWasteItem = false,
  }) {
    return ClearingsState(
      wasteCartItems: wasteCartItems ?? this.wasteCartItems,
      token: token ?? this.token,
      deliveriesItems: deliveriesItems ?? this.deliveriesItems,
      searchDetails:
          clearSearchDetails ? null : (searchDetails ?? this.searchDetails),
      requestWasteItem: clearRequestWasteItem
          ? null
          : (requestWasteItem ?? this.requestWasteItem),
      toDeliveryCollectItems:
          toDeliveryCollectItems ?? this.toDeliveryCollectItems,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      sCategory: sCategory ?? this.sCategory,
    );
  }

  static ClearingsState initial() => const ClearingsState(
        wasteCartItems: [],
        token: '',
        deliveriesItems: [],
        searchDetails: null,
        requestWasteItem: null,
        toDeliveryCollectItems: [],
        searchEndPoint: '',
        searchKey: '',
        sPage: 1,
        sPerPage: 10,
        sOrder: 'desc',
        sOrderBy: 'date',
        sCategory: null,
      );
}
