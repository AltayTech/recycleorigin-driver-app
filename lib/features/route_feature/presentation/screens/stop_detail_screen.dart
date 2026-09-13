import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/widgets/pickup_location_preview_card.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_list_view_options.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/stop_schedule_format.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/navigation_launcher_sheet.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver-facing stop worksheet: status, customer, schedule, and next action.
class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({super.key, required this.stop});

  final RouteStop stop;

  RouteStop _currentStop(RouteState state) {
    final stops = state.route?.stops;
    if (stops == null) {
      return stop;
    }
    for (final s in stops) {
      if (s.stopId == stop.stopId) {
        return s;
      }
    }
    return stop;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<RouteBloc, RouteState>(
      listenWhen: (prev, next) =>
          next.actionError != null && next.actionError != prev.actionError,
      listener: (context, state) {
        final msg = state.actionError;
        if (msg == null || msg.isEmpty) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
          );
      },
      builder: (context, state) {
        final current = _currentStop(state);
        final busy =
            state.busyStopId != null && state.busyStopId == current.stopId;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.routeStopTitle(current.sequence))),
          body: Column(
            children: <Widget>[
              if (busy) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: <Widget>[
                    _StatusHeader(status: current.status),
                    const SizedBox(height: 16),
                    _AddressCard(stop: current),
                    const SizedBox(height: 12),
                    _CustomerCard(stop: current),
                    const SizedBox(height: 12),
                    _ScheduleCard(stop: current),
                    if (_hasDemand(current)) ...<Widget>[
                      const SizedBox(height: 12),
                      _DemandCard(stop: current),
                    ],
                    if (stopHasMapCoordinates(
                      current.lat,
                      current.lng,
                    )) ...<Widget>[
                      const SizedBox(height: 12),
                      PickupLocationPreviewCard(
                        latitude: current.lat.toString(),
                        longitude: current.lng.toString(),
                        addressLine: current.address,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: busy
                          ? null
                          : () => showNavigationLauncherSheet(context, current),
                      icon: const Icon(Icons.navigation_rounded),
                      label: Text(l10n.routeNavigateButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _StopActionBar(stop: current, busy: busy),
        );
      },
    );
  }
}

bool _hasDemand(RouteStop stop) {
  return formatStopWeightKg(stop.weightKg).isNotEmpty || stop.items.isNotEmpty;
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        StopStatusChip(status: status),
        const Spacer(),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.place_outlined, color: context.brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(stop.address, style: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = stop.customer.name.trim();
    final phone = stop.customer.phone.trim();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.routeCustomerLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(name.isEmpty ? '—' : name, style: theme.textTheme.titleMedium),
            if (phone.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _callCustomer(context, phone),
                  icon: const Icon(Icons.phone_rounded),
                  label: Text('${l10n.routeCallCustomer} $phone'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _callCustomer(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  final ok = await launchUrl(uri);
  if (ok || !context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(context.l10n.routeCallFailed),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final schedule = formatStopSchedule(
      arrival: stop.plannedArrival,
      departure: stop.plannedDeparture,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.schedule_rounded, color: context.brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.routeScheduleLabel,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule ?? l10n.routeNoSchedule,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  const _DemandCard({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final weight = formatStopWeightKg(stop.weightKg);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.routeDemandLabel, style: theme.textTheme.labelLarge),
            if (weight.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                l10n.routeWeightKg(weight),
                style: theme.textTheme.titleMedium,
              ),
            ],
            if (stop.items.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(l10n.routeItemsLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(stop.items.join(', '), style: theme.textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}

class _StopActionBar extends StatelessWidget {
  const _StopActionBar({required this.stop, required this.busy});

  final RouteStop stop;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final skipped = canIncludeRouteStop(stop.status);
    final terminal = stop.status == 'completed' || stop.status == 'failed';

    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (terminal)
                _TerminalBanner(status: stop.status)
              else if (skipped)
                _SkippedActions(stop: stop, busy: busy)
              else
                _ActiveActions(stop: stop, busy: busy, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerminalBanner extends StatelessWidget {
  const _TerminalBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDone = status == 'completed';
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDone ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.error_outline,
              color: isDone
                  ? scheme.onPrimaryContainer
                  : scheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isDone ? l10n.routeStopDoneBanner : l10n.routeStopFailedBanner,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDone
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkippedActions extends StatelessWidget {
  const _SkippedActions({required this.stop, required this.busy});

  final RouteStop stop;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.routeStopSkippedBanner),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: busy
              ? null
              : () => context.read<RouteBloc>().add(
                  RouteStopIncluded(stop.stopId),
                ),
          child: Text(l10n.routeIncludeStopLabel),
        ),
      ],
    );
  }
}

class _ActiveActions extends StatelessWidget {
  const _ActiveActions({
    required this.stop,
    required this.busy,
    required this.l10n,
  });

  final RouteStop stop;
  final bool busy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final arrived = stop.status == 'arrived';
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!arrived) ...<Widget>[
          FilledButton(
            onPressed: busy
                ? null
                : () => context.read<RouteBloc>().add(
                    RouteStopArrived(stop.stopId),
                  ),
            child: Text(l10n.routeArrivedButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: busy ? null : () => _confirmComplete(context),
            child: Text(l10n.routeCompletedButton),
          ),
        ] else ...<Widget>[
          Text(
            l10n.routeCompleteHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: busy ? null : () => _confirmComplete(context),
            child: Text(l10n.routeCompletedButton),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            if (canSkipRouteStop(stop.status))
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _confirmSkip(context),
                  child: Text(l10n.routeSkipStopLabel),
                ),
              ),
            if (canSkipRouteStop(stop.status)) const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => _confirmFail(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                ),
                child: Text(l10n.routeFailedButton),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmComplete(BuildContext context) async {
    final l10n = this.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.routeConfirmCompleteTitle),
        content: Text(l10n.routeConfirmCompleteMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<RouteBloc>().add(RouteStopCompleted(stop.stopId));
    }
  }

  Future<void> _confirmSkip(BuildContext context) async {
    final l10n = this.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.routeConfirmSkipTitle),
        content: Text(l10n.routeConfirmSkipMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<RouteBloc>().add(RouteStopSkipped(stop.stopId));
    }
  }

  Future<void> _confirmFail(BuildContext context) async {
    final l10n = this.l10n;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.routeConfirmFailTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.routeConfirmFailMessage),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 255,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.routeFailReasonLabel),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (ok == true && context.mounted) {
      context.read<RouteBloc>().add(
        RouteStopFailed(stop.stopId, reason: reason),
      );
    }
  }
}
