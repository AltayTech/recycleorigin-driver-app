import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Jalali calendar date and live device clock for warehouse / collection tabs.
///
/// Updates periodically while visible, refreshes on app resume, and exposes a
/// single merged semantics label for assistive tech.
class DriverSessionHeaderBanner extends StatefulWidget {
  const DriverSessionHeaderBanner({super.key});

  @override
  State<DriverSessionHeaderBanner> createState() =>
      _DriverSessionHeaderBannerState();
}

class _DriverSessionHeaderBannerState extends State<DriverSessionHeaderBanner>
    with WidgetsBindingObserver {
  static const Duration _tickInterval = Duration(seconds: 20);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_tickInterval, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _formatJalali(Jalali j) =>
      '${j.year}/${_twoDigits(j.month)}/${_twoDigits(j.day)}';

  static String _formatTime(DateTime now) =>
      '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final textScaler = MediaQuery.textScalerOf(context);

    final now = DateTime.now();
    final jalali = Jalali.fromDateTime(now);
    final dateRaw = _formatJalali(jalali);
    final timeRaw = _formatTime(now);
    final dateStr = EnArConvertor.localize(context, dateRaw);
    final timeStr = EnArConvertor.localize(context, timeRaw);

    final captionStyle = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    final dateValueStyle = textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    final timeValueStyle = textTheme.titleLarge?.copyWith(
      color: AppTheme.h1,
      fontWeight: FontWeight.w700,
      height: 1.15,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    final iconBg = AppTheme.primary.withValues(alpha: 0.12);
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Semantics(
      container: true,
      label: l10n.driverSessionHeaderSemantic(dateStr, timeStr),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 12,
          bottom: 10,
        ),
        child: Material(
          color: colorScheme.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 320;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SessionSegment(
                        icon: Icons.calendar_month_rounded,
                        iconBackground: iconBg,
                        iconColor: AppTheme.primary,
                        caption: l10n.driverSessionDateCaption,
                        captionStyle: captionStyle,
                        value: dateStr,
                        valueStyle: dateValueStyle,
                        textScaler: textScaler,
                        narrow: true,
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 1, color: borderColor),
                      const SizedBox(height: 12),
                      _SessionSegment(
                        icon: Icons.schedule_rounded,
                        iconBackground: iconBg,
                        iconColor: AppTheme.primary,
                        caption: l10n.driverSessionTimeCaption,
                        captionStyle: captionStyle,
                        value: timeStr,
                        valueStyle: timeValueStyle,
                        textScaler: textScaler,
                        narrow: true,
                        valueAlign: TextAlign.end,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _SessionSegment(
                        icon: Icons.calendar_month_rounded,
                        iconBackground: iconBg,
                        iconColor: AppTheme.primary,
                        caption: l10n.driverSessionDateCaption,
                        captionStyle: captionStyle,
                        value: dateStr,
                        valueStyle: dateValueStyle,
                        textScaler: textScaler,
                        narrow: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        height: 44,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: borderColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _SessionSegment(
                        icon: Icons.schedule_rounded,
                        iconBackground: iconBg,
                        iconColor: AppTheme.primary,
                        caption: l10n.driverSessionTimeCaption,
                        captionStyle: captionStyle,
                        value: timeStr,
                        valueStyle: timeValueStyle,
                        textScaler: textScaler,
                        narrow: false,
                        valueAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionSegment extends StatelessWidget {
  const _SessionSegment({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.caption,
    required this.captionStyle,
    required this.value,
    required this.valueStyle,
    required this.textScaler,
    required this.narrow,
    this.valueAlign = TextAlign.start,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String caption;
  final TextStyle? captionStyle;
  final String value;
  final TextStyle? valueStyle;
  final TextScaler textScaler;
  final bool narrow;
  final TextAlign valueAlign;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: valueAlign,
      textScaler: textScaler,
      style: valueStyle,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ExcludeSemantics(
              child: Icon(icon, size: 22, color: iconColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: narrow
                ? CrossAxisAlignment.start
                : (valueAlign == TextAlign.end
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                caption,
                textAlign: valueAlign,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textScaler: textScaler,
                style: captionStyle,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: valueAlign == TextAlign.end
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: valueText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
