/// JWT login response from backend (same contract as main Recycle Origin app).
class TokenResponseModel {
  TokenResponseModel({
    this.token,
    this.userEmail,
    this.userNicename,
    this.userDisplayName,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      token: json['token']?.toString(),
      userEmail: json['user_email']?.toString(),
      userNicename: json['user_nicename']?.toString(),
      userDisplayName: json['user_display_name']?.toString(),
    );
  }

  final String? token;
  final String? userEmail;
  final String? userNicename;
  final String? userDisplayName;

  Map<String, dynamic> toJson() => {
        'token': token,
        'user_email': userEmail,
        'user_nicename': userNicename,
        'user_display_name': userDisplayName,
      };
}
