import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';

/// Immutable state for driver collect list, cart, and collect API calls.
class WastesState {
  const WastesState({
    required this.wasteCartItems,
    required this.token,
    required this.collectItems,
    required this.searchDetails,
    required this.requestWasteItem,
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
  final List<RequestWasteItem> collectItems;
  final SearchDetail? searchDetails;
  final RequestWasteItem? requestWasteItem;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final Object? sCategory;

  WastesState copyWith({
    List<WasteCart>? wasteCartItems,
    String? token,
    List<RequestWasteItem>? collectItems,
    SearchDetail? searchDetails,
    RequestWasteItem? requestWasteItem,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    Object? sCategory,
    bool clearRequestWasteItem = false,
    bool clearSearchDetails = false,
  }) {
    return WastesState(
      wasteCartItems: wasteCartItems ?? this.wasteCartItems,
      token: token ?? this.token,
      collectItems: collectItems ?? this.collectItems,
      searchDetails:
          clearSearchDetails ? null : (searchDetails ?? this.searchDetails),
      requestWasteItem: clearRequestWasteItem
          ? null
          : (requestWasteItem ?? this.requestWasteItem),
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      sCategory: sCategory ?? this.sCategory,
    );
  }

  static WastesState initial() => const WastesState(
        wasteCartItems: [],
        token: '',
        collectItems: [],
        searchDetails: null,
        requestWasteItem: null,
        searchEndPoint: '',
        searchKey: '',
        sPage: 1,
        sPerPage: 10,
        sOrder: 'desc',
        sOrderBy: 'date',
        sCategory: null,
      );
}
