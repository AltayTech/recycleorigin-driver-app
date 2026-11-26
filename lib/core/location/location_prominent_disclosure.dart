import 'package:material_ui/material_ui.dart';

import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Play-required in-app disclosure shown before any OS location prompt.
Future<bool> showDriverLocationDisclosure(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.locationDisclosureTitle),
        content: SingleChildScrollView(
          child: Text(l10n.locationDisclosureBody),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.locationDisclosureNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.locationDisclosureContinue),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Shows the disclosure when needed, then the OS permission prompt.
///
/// Returns true when while-in-use (or always) is already granted or the
/// driver accepts the disclosure and the OS grant succeeds.
Future<bool> confirmLocationAccess({
  required BuildContext context,
  required DriverLocationTracker tracker,
}) async {
  if (await tracker.hasPermission()) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  if (!await tracker.ensureLocationServices()) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }
  if (await tracker.hasPermission()) {
    return true;
  }
  final accepted = await showDriverLocationDisclosure(context);
  if (!accepted || !context.mounted) {
    return false;
  }
  return tracker.requestPermission();
}
