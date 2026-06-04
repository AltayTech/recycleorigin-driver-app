import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:recycleorigindriver/core/notifications/driver_push_notification_controller.dart';
import 'package:recycleorigindriver/core/notifications/notification_preferences_service.dart';

/// Manages notification preference state for the settings screen.
class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    NotificationPreferencesService? service,
  }) : _service = service ?? NotificationPreferencesService();

  final NotificationPreferencesService _service;

  Map<String, Map<String, bool>> _prefs =
      NotificationPreferencesService.defaultPrefs();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _savedFlash = false;
  Timer? _saveDebounce;
  Timer? _flashTimer;

  Map<String, Map<String, bool>> get prefs => _prefs;
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  bool get savedFlash => _savedFlash;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _prefs = await _service.fetch();
      _error = null;
    } catch (_) {
      _error = 'load';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setEnabled(String category, String channel, bool value) {
    _prefs.putIfAbsent(
      category,
      () => <String, bool>{'push': true, 'inapp': true},
    );
    _prefs[category]![channel] = value;
    notifyListeners();
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), _persist);
  }

  Future<void> _persist() async {
    _saving = true;
    _savedFlash = false;
    notifyListeners();
    try {
      await _service.save(_prefs);
      await DriverPushNotificationController.instance.syncAfterLogin();
      _error = null;
      _savedFlash = true;
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(seconds: 2), () {
        _savedFlash = false;
        notifyListeners();
      });
    } catch (_) {
      _error = 'save';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }
}
