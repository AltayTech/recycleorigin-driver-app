import 'package:package_info_plus/package_info_plus.dart';

/// Cached [PackageInfo] for version and display name on settings and splash.
class AppInfoService {
  AppInfoService._();

  static final AppInfoService instance = AppInfoService._();

  PackageInfo? _packageInfo;
  bool _isInitialized = false;
  bool _isInitializing = false;

  String get packageName => _packageInfo?.packageName ?? 'recycleorigindriver';

  String get appName => _packageInfo?.appName ?? 'RecycleOrigin Driver';

  String get version => _packageInfo?.version ?? '1.0.0';

  String get buildNumber => _packageInfo?.buildNumber ?? '0';

  String get fullVersion => 'v$version ($buildNumber)';

  /// Short label for footers (e.g. `v1.2.3`).
  String get shortVersion => 'v$version';

  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }
    _isInitializing = true;
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
      return true;
    } catch (_) {
      _isInitialized = false;
      return false;
    } finally {
      _isInitializing = false;
    }
  }
}
