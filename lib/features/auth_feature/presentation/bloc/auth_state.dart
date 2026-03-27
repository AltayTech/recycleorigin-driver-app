import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/models/token_response_model.dart';

/// Immutable snapshot of authentication and related driver data.
class AuthState {
  const AuthState({
    required this.token,
    required this.isLoggedIn,
    required this.isFirstLogin,
    required this.isFirstLogout,
    required this.isCompleted,
    required this.addressItems,
    required this.selectedAddress,
    required this.regionItems,
    required this.regionData,
    required this.tokenResponseModel,
  });

  final String token;
  final bool isLoggedIn;
  final bool isFirstLogin;
  final bool isFirstLogout;
  final bool isCompleted;
  final List<Address> addressItems;
  final Address selectedAddress;
  final List<Region> regionItems;
  final Region regionData;
  final TokenResponseModel tokenResponseModel;

  bool get isAuth => token.isNotEmpty;

  AuthState copyWith({
    String? token,
    bool? isLoggedIn,
    bool? isFirstLogin,
    bool? isFirstLogout,
    bool? isCompleted,
    List<Address>? addressItems,
    Address? selectedAddress,
    List<Region>? regionItems,
    Region? regionData,
    TokenResponseModel? tokenResponseModel,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      isFirstLogout: isFirstLogout ?? this.isFirstLogout,
      isCompleted: isCompleted ?? this.isCompleted,
      addressItems: addressItems ?? this.addressItems,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      regionItems: regionItems ?? this.regionItems,
      regionData: regionData ?? this.regionData,
      tokenResponseModel: tokenResponseModel ?? this.tokenResponseModel,
    );
  }

  static AuthState initial() {
    return AuthState(
      token: '',
      isLoggedIn: false,
      isFirstLogin: false,
      isFirstLogout: false,
      isCompleted: false,
      addressItems: const [],
      selectedAddress: Address(
        name: '',
        address: '',
        region: Region(
          term_id: 0,
          name: '',
          collect_hour: [],
        ),
      ),
      regionItems: const [],
      regionData: Region(term_id: 0, name: '', collect_hour: []),
      tokenResponseModel: TokenResponseModel(),
    );
  }
}
