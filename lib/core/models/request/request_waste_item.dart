import 'package:flutter/material.dart';

import 'package:recycleorigindriver/l10n/app_localizations.dart';
import '../driver.dart';
import '../region.dart';
import '../status.dart';
import 'address.dart';
import 'collect.dart';
import 'collect_status.dart';
import 'collect_time.dart';

class RequestWasteItem with ChangeNotifier {
  final int id;
  final Status status;
  final Status collect_type;
  final CollectStatus total_collects_price;
  final CollectStatus total_collects_weight;
  final CollectStatus total_collects_number;
  final CollectTime collect_date;
  final Address address_data;
  final List<Collect> collect_list;
  final Driver driver;

  /// From API: false means driver must accept; null = legacy row (treat as accepted).
  final bool? driverAccepted;
  final String requestStatusKey;
  final String requestStatusLabel;

  RequestWasteItem(
      {required this.id,
      required this.status,
      required this.collect_type,
      required this.total_collects_price,
      required this.total_collects_weight,
      required this.total_collects_number,
      required this.collect_date,
      required this.address_data,
      required this.collect_list,
      required this.driver,
      this.driverAccepted,
      this.requestStatusKey = '',
      this.requestStatusLabel = ''});

  /// True when API explicitly requires accept/reject (new assignment flow).
  bool get needsDriverAcceptOrReject => driverAccepted == false;

  /// Localized line for list/detail; falls back to API label or legacy [status].
  String requestStatusDisplay(AppLocalizations l10n) {
    switch (requestStatusKey) {
      case 'pending_assignment':
        return l10n.collectRequestStatusPendingAssignment;
      case 'pending_driver_acceptance':
        return l10n.collectRequestStatusPendingDriverAcceptance;
      case 'driver_accepted':
        return l10n.collectRequestStatusDriverAccepted;
      case 'collected':
        if (requestStatusLabel.isNotEmpty) {
          return requestStatusLabel;
        }
        return l10n.collectRequestStatusCollected;
      case 'cancelled':
        if (requestStatusLabel.isNotEmpty) {
          return requestStatusLabel;
        }
        return l10n.collectRequestStatusCancelled;
      case 'in_progress':
        if (requestStatusLabel.isNotEmpty) {
          return requestStatusLabel;
        }
        return l10n.collectRequestStatusInProgress;
      default:
        if (requestStatusLabel.isNotEmpty) {
          return requestStatusLabel;
        }
        final n = status.name.trim();
        if (n.isNotEmpty && n != '0') {
          return n;
        }
        final s = status.slug.trim();
        if (s.isNotEmpty && s != '0') {
          return s;
        }
        return '—';
    }
  }

  factory RequestWasteItem.fromJson(Map<String, dynamic> parsedJson) {
    final collectList = parsedJson['collect_list'];
    final List<Collect> collectRaw = collectList is List
        ? (collectList)
            .map<Collect>(
                (dynamic i) => Collect.fromJson(i as Map<String, dynamic>))
            .toList()
        : <Collect>[];

    final addressDataJson = parsedJson['address_data'];
    final addressData = addressDataJson is Map<String, dynamic>
        ? Address.fromJson(addressDataJson)
        : Address(
            name: '',
            address: '',
            region: Region(
              term_id: 0,
              name: '',
              collect_hour: [],
            ),
          );

    final driverJson = parsedJson['driver'];
    final driver = driverJson is Map<String, dynamic>
        ? Driver.fromJson(driverJson)
        : Driver.fromJson(null);

    final dynamic daRaw = parsedJson['driver_accepted'];
    final bool? driverAccepted = daRaw is bool ? daRaw : null;

    return RequestWasteItem(
      id: parsedJson['id'] is int
          ? parsedJson['id'] as int
          : int.tryParse(parsedJson['id']?.toString() ?? '0') ?? 0,
      collect_type: parsedJson['collect_type'] != null &&
              parsedJson['collect_type'] is Map
          ? Status.fromJson(parsedJson['collect_type'] as Map<String, dynamic>)
          : Status(term_id: 0, name: '0', slug: '0'),
      status: parsedJson['status'] != null && parsedJson['status'] is Map
          ? Status.fromJson(parsedJson['status'] as Map<String, dynamic>)
          : Status(term_id: 0, name: '0', slug: '0'),
      total_collects_price: parsedJson['total_collects_price'] != null &&
              parsedJson['total_collects_price'] is Map
          ? CollectStatus.fromJson(
              parsedJson['total_collects_price'] as Map<String, dynamic>)
          : CollectStatus(estimated: '0', exact: '0'),
      total_collects_weight: parsedJson['total_collects_weight'] != null &&
              parsedJson['total_collects_weight'] is Map
          ? CollectStatus.fromJson(
              parsedJson['total_collects_weight'] as Map<String, dynamic>)
          : CollectStatus(estimated: '0', exact: '0'),
      total_collects_number: parsedJson['total_collects_number'] != null &&
              parsedJson['total_collects_number'] is Map
          ? CollectStatus.fromJson(
              parsedJson['total_collects_number'] as Map<String, dynamic>)
          : CollectStatus(estimated: '0', exact: '0'),
      collect_date: parsedJson['collect_date'] != null &&
              parsedJson['collect_date'] is Map
          ? CollectTime.fromJson(
              parsedJson['collect_date'] as Map<String, dynamic>)
          : CollectTime(time: '0', day: '0', collect_done_time: '0'),
      address_data: addressData,
      collect_list: collectRaw,
      driver: driver,
      driverAccepted: driverAccepted,
      requestStatusKey: parsedJson['request_status_key'] as String? ?? '',
      requestStatusLabel: parsedJson['request_status_label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    Map address = this.address_data.toJson();
    Map status = this.status.toJson();
    Map driver = this.driver.toJson();
    Map total_price = this.total_collects_price.toJson();
    Map total_weight = this.total_collects_weight.toJson();
    Map total_number = this.total_collects_number.toJson();
    Map collect_time = this.collect_date.toJson();

    List<Map> collect_list = this.collect_list.map((i) => i.toJson()).toList();

    return {
      'id': id,
      'status': status,
      'total_price': total_price,
      'total_weight': total_weight,
      'total_number': total_number,
      'collect_time': collect_time,
      'address_data': address,
      'collect_list': collect_list,
      'driver': driver,
    };
  }
}
