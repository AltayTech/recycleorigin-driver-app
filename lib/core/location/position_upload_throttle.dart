/// Throttles position uploads by minimum interval.
class PositionUploadThrottle {
  PositionUploadThrottle({this.minInterval = const Duration(seconds: 20)});

  final Duration minInterval;
  DateTime? _lastUploadAt;

  /// Returns true when enough time has passed since the last accepted upload.
  bool shouldUpload(DateTime now) {
    final last = _lastUploadAt;
    if (last == null) {
      return true;
    }
    return now.difference(last) >= minInterval;
  }

  void markUploaded(DateTime now) {
    _lastUploadAt = now;
  }

  void reset() {
    _lastUploadAt = null;
  }
}
