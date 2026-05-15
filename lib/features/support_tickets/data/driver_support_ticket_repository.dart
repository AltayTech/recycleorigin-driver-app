import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_models.dart';

Map<String, dynamic>? _decodeJsonMap(String body) {
  final dynamic o = jsonDecode(body);
  return o is Map<String, dynamic> ? o : null;
}

/// HTTP client for driver app support tickets (`pasmands/v1/tickets`).
class DriverSupportTicketRepository {
  static String get _root =>
      '${Urls.apiBaseUrl}pasmands/v1/tickets';

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<PagedTickets?> listTickets({int page = 1, int perPage = 20}) async {
    final uri = Uri.parse(_root).replace(
      queryParameters: <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      return null;
    }
    final map = _decodeJsonMap(res.body);
    return map != null ? PagedTickets.fromJsonMap(map) : null;
  }

  Future<SupportTicket?> getTicket(String id) async {
    final uri = Uri.parse('$_root/$id');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      return null;
    }
    final map = _decodeJsonMap(res.body);
    return map != null ? SupportTicket.fromJson(map) : null;
  }

  Future<PagedMessages?> listMessages(
    String ticketId, {
    int page = 1,
    int perPage = 100,
  }) async {
    final uri = Uri.parse('$_root/$ticketId/messages').replace(
      queryParameters: <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      return null;
    }
    final map = _decodeJsonMap(res.body);
    return map != null ? PagedMessages.fromJsonMap(map) : null;
  }

  Future<SupportTicket?> createTicket({
    required String subject,
    required String category,
    required String description,
    String? relatedTripId,
  }) async {
    final uri = Uri.parse(_root);
    final body = <String, dynamic>{
      'subject': subject,
      'category': category,
      'description': description,
    };
    final trip = relatedTripId?.trim();
    if (trip != null && trip.isNotEmpty) {
      final n = int.tryParse(trip);
      if (n != null) {
        body['related_trip_id'] = n;
      }
    }
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      return null;
    }
    final map = _decodeJsonMap(res.body);
    return map != null ? SupportTicket.fromJson(map) : null;
  }

  Future<SupportTicketMessage?> postMessage(
    String ticketId,
    String content,
  ) async {
    final uri = Uri.parse('$_root/$ticketId/messages');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{'content': content}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      return null;
    }
    final map = _decodeJsonMap(res.body);
    return map != null ? SupportTicketMessage.fromJson(map) : null;
  }
}
