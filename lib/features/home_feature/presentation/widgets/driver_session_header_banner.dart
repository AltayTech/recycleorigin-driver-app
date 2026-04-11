import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

/// Jalali date and clock shown above warehouse / collection lists in the shell.
class DriverSessionHeaderBanner extends StatelessWidget {
  const DriverSessionHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final now = DateTime.now();
    final jalali = Jalali.fromDateTime(now);

    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 10, right: 16, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 10.10,
              spreadRadius: 10.510,
              offset: Offset.zero,
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 5),
                child: Icon(Icons.calendar_today, color: AppTheme.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  EnArConvertor.localize(
                    context,
                    '${jalali.year}/${jalali.month}/${jalali.day}',
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppTheme.h1),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 5),
                child: Icon(Icons.access_time, color: AppTheme.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  EnArConvertor.localize(
                    context,
                    '${now.hour}:${now.minute}',
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(color: AppTheme.h1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
