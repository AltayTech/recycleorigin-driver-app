import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/token_response_model.dart';

void main() {
  group('TokenResponseModel', () {
    test('fromJson reads token and user fields', () {
      final m = TokenResponseModel.fromJson({
        'token': 'abc',
        'user_email': 'd@d.com',
        'user_nicename': 'nick',
        'user_display_name': 'Display',
      });
      expect(m.token, 'abc');
      expect(m.userEmail, 'd@d.com');
      expect(m.userNicename, 'nick');
      expect(m.userDisplayName, 'Display');
    });

    test('fromJson tolerates missing keys', () {
      final m = TokenResponseModel.fromJson({});
      expect(m.token, isNull);
      expect(m.toJson()['token'], isNull);
    });

    test('toJson includes all keys', () {
      final m = TokenResponseModel(
        token: 't',
        userEmail: 'a@b.c',
      );
      final json = m.toJson();
      expect(json['token'], 't');
      expect(json['user_email'], 'a@b.c');
    });
  });
}
