import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// App version and copyright footer on the profile tab.
class ProfileAppVersionFooter extends StatefulWidget {
  const ProfileAppVersionFooter({super.key});

  @override
  State<ProfileAppVersionFooter> createState() =>
      _ProfileAppVersionFooterState();
}

class _ProfileAppVersionFooterState extends State<ProfileAppVersionFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = AppInfoService.instance;
      if (!info.isInitialized) {
        await info.initialize();
      }
      if (mounted) {
        setState(() {
          _version = info.shortVersion;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _version = 'v1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = DateTime.now().year.toString();

    return Column(
      children: <Widget>[
        if (_version.isNotEmpty)
          Text(
            l10n.appVersionLabel(_version),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.secondaryText,
                ),
          ),
        const SizedBox(height: 4),
        Text(
          l10n.profileCopyrightLabel(year, l10n.appTitle),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.secondaryText.withValues(alpha: 0.85),
              ),
        ),
      ],
    );
  }
}
