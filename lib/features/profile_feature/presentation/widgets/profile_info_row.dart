import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Read-only label/value row for profile detail screens.
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '—' : value.trim();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  display,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (copyable && display != '—')
                IconButton(
                  tooltip: context.l10n.copyLabel,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: display));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.copiedToClipboardMessage),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
