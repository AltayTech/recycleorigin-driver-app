import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycleorigindriver/models/request/collect.dart';

import '../models/request/collect_main.dart';
import '../models/request/request_waste.dart';
import '../models/request/request_waste_item.dart';
import '../models/request/wasteCart.dart';
import '../models/search_detail.dart';
import 'urls.dart';

class Wastes with ChangeNotifier {
  List<WasteCart> _wasteCartItems = [];

  late String _token;

  List<RequestWasteItem> _collectItems = [];

  late SearchDetail _searchDetails;

  late RequestWasteItem _requestWasteItem;

  set requestWasteItem(RequestWasteItem value) {
    _requestWasteItem = value;
  }

  Future<void> addWasteCart(WasteCart wasteCart, bool isAdded) async {
    print('addWasteCart');
    try {
      _wasteCartItems
          .firstWhere((prod) => prod.pasmand.id == wasteCart.pasmand.id)
          .isAdded = isAdded;

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error);
    }
  }

  Future<void> addInitialWasteCart(List<Collect> wastesCart, bool isAdded,
      bool isCollected) async {
    print('addInitialWasteCart');
    try {
      _wasteCartItems.clear();

      for (int i = 0; i < wastesCart.length; i++) {
        _wasteCartItems.add(
          WasteCart(
            pasmand: wastesCart[i].pasmand,
            estimated_weight: wastesCart[i].estimated_weight,
            estimated_price: wastesCart[i].estimated_price,
            exact_price: isCollected ? wastesCart[i].exact_price : wastesCart[i]
                .estimated_price,
            exact_weight: isCollected
                ? wastesCart[i].exact_weight
                : wastesCart[i].estimated_weight,
            isAdded: isAdded,
          ),
        );
      }

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error);
    }
  }

  Future<void> updateWasteCart(WasteCart waste, String exactWeight,
      bool isAdded) async {
    print('updateShopCart');
    try {
      _wasteCartItems
          .firstWhere((prod) => prod.pasmand.id == waste.pasmand.id)
          .exact_weight = exactWeight;
      _wasteCartItems
          .firstWhere((prod) => prod.pasmand.id == waste.pasmand.id)
          .isAdded = isAdded;
      print('finish');

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error);
    }
  }

  Future<void> removeWasteCart(int wasteId) async {
    print('removeShopCart');

    _wasteCartItems.remove(
        _wasteCartItems.firstWhere((prod) => prod.pasmand.id == wasteId));

    notifyListeners();
  }

  String get token => _token;

  List<WasteCart> get wasteCartItems => _wasteCartItems;

  set wasteCartItems(List<WasteCart> value) {
    _wasteCartItems = value;
  }

  Future<void> sendRequest(RequestWaste request, bool isLogin, int id) async {
    print('sendRequest');
    try {
      if (isLogin) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;
        print('tooookkkeeennnnnn  $_token');

        final url = Urls.rootUrl + Urls.collectsEndPoint + '/$id';
        print('url  $url');
        print(jsonEncode(request));

        final response = await put(Uri(path: url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(request));

        final extractedData = json.decode(response.body);
        print(extractedData.toString());
      }
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error);
    }
  }

  late String _selectedHours;
  late Jalali _selectedDay;

  String get selectedHours => _selectedHours;

  Jalali get selectedDay => _selectedDay;

  String searchEndPoint = '';
  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;
  var _sOrder = 'desc';
  var _sOrderBy = 'date';
  var _sCategory;

  void searchBuilder() {
    if (!(searchKey == '')) {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?search=$searchKey';
      searchEndPoint = searchEndPoint + '&page=$_sPage&per_page=$_sPerPage';
    } else {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?page=$_sPage&per_page=$_sPerPage';
    }
    if (!(_sOrder == '')) {
      searchEndPoint = searchEndPoint + '&order=$_sOrder';
    }
    if (!(_sOrderBy == '')) {
      searchEndPoint = searchEndPoint + '&orderby=$_sOrderBy';
    }

    if (!(_sCategory == '' || _sCategory == null)) {
      searchEndPoint = searchEndPoint + '&category=$_sCategory';
    }
    print(searchEndPoint);
  }

  Future<void> searchCollectItems() async {
    print('searchCollectItems');

    final url = Urls.rootUrl + Urls.collectsEndPoint + '$searchEndPoint';
    print(url);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;
      print('tooookkkeeennnnnn  $_token');

      final response = await get(Uri(path: url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      print(response.statusCode);
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        print(extractedData.toString());

        CollectMain collectMain = CollectMain.fromJson(extractedData);
        print(collectMain.searchDetail.max_page.toString());

        _collectItems = collectMain.requestWasteItem;
        _searchDetails = collectMain.searchDetail;
      } else {
        _collectItems = [];
      }
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error);
    }
  }

  Future<void> retrieveCollectItem(int collectId) async {
    print('retrieveCollectItem');

    final url = Urls.rootUrl + Urls.collectsEndPoint + "/$collectId";
    print(url);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;
      print('tooookkkeeennnnnn  $_token');

      final response = await get(Uri(path: url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      final extractedData = json.decode(response.body) as dynamic;
      print(extractedData);

      RequestWasteItem requestWasteItem =
      RequestWasteItem.fromJson(extractedData);
      print(requestWasteItem.id.toString());

      _requestWasteItem = requestWasteItem;
    } catch (error) {
      print(error.toString());
      throw (error);
    }
    notifyListeners();
  }

  get sCategory => _sCategory;

  get sOrderBy => _sOrderBy;

  get sOrder => _sOrder;

  get sPerPage => _sPerPage;

  get sPage => _sPage;

  RequestWasteItem get requestWasteItem => _requestWasteItem;

  SearchDetail get searchDetails => _searchDetails;

  List<RequestWasteItem> get collectItems => _collectItems;

  set sOrderBy(value) {
    _sOrderBy = value;
  }

  set sOrder(value) {
    _sOrder = value;
  }

  set sPerPage(value) {
    _sPerPage = value;
  }

  set sPage(value) {
    _sPage = value;
  }
}
