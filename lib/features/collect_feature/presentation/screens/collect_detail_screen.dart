import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver collect request detail screen with lifecycle-aware UI.
///
/// Phases:
///   1. Pending acceptance → Accept / Reject buttons
///   2. Accepted → Editable weights + "Confirm Pickup" button
///   3. Picked up → Read-only summary, waiting for admin
///   4. Collected / Cancelled → Completed banner
class CollectDetailScreen extends StatefulWidget {
  static const routeName = '/CollectDetailScreen';

  const CollectDetailScreen({super.key});

  @override
  State<CollectDetailScreen> createState() => _CollectDetailScreenState();
}

class _CollectDetailScreenState extends State<CollectDetailScreen> {
  bool _initialized = false;
  bool _loading = true;
  String? _error;
  RequestWasteItem? _collect;
  final Map<int, TextEditingController> _weightControllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<WastesBloc>().wasteCartItems = [];
      context.read<AuthBloc>().checkCompleted().then((_) => _load());
    }
  }

  @override
  void dispose() {
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final collectId = ModalRoute.of(context)?.settings.arguments;
    if (collectId is! int) {
      if (mounted)
        setState(() {
          _error = 'Invalid request';
          _loading = false;
        });
      return;
    }
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bloc = context.read<WastesBloc>();
      await bloc.retrieveCollectItem(collectId);
      if (!mounted) return;
      final collect = bloc.state.requestWasteItem!;
      final isReadOnly = collect.status.slug == 'collected' ||
          collect.status.slug == 'picked_up' ||
          collect.status.slug == 'cancel';
      await bloc.addInitialWasteCart(
        collect.collect_list,
        true,
        isReadOnly,
      );
      if (!mounted) return;
      _initWeightControllers(bloc.state.wasteCartItems);
      setState(() {
        _collect = collect;
        _loading = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  void _initWeightControllers(List<WasteCart> items) {
    for (final item in items) {
      final id = item.pasmand.id;
      if (!_weightControllers.containsKey(id)) {
        _weightControllers[id] = TextEditingController(
          text: _formatWeight(item.exact_weight),
        );
      } else {
        _weightControllers[id]!.text = _formatWeight(item.exact_weight);
      }
    }
  }

  String _formatWeight(String raw) {
    final v = double.tryParse(raw) ?? 0;
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  _Phase get _phase {
    final c = _collect;
    if (c == null) return _Phase.loading;
    final slug = c.status.slug;
    if (slug == 'collected') return _Phase.completed;
    if (slug == 'cancel') return _Phase.cancelled;
    if (slug == 'picked_up') return _Phase.pickedUp;
    if (c.needsDriverAcceptOrReject) return _Phase.pendingAcceptance;
    return _Phase.accepted;
  }

  bool get _weightsEditable => _phase == _Phase.accepted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.requestDetailTitle,
            style: const TextStyle(color: AppTheme.appBarIconColor)),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
      ),
      drawer: Theme(
        data: theme.copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return _ErrorView(error: _error!, onRetry: _load);
    if (_loading || _collect == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _StatusBanner(phase: _phase, collect: _collect!),
              const SizedBox(height: 16),
              _RequestInfoCard(collect: _collect!),
              const SizedBox(height: 16),
              _SummaryCard(
                  items: context.watch<WastesBloc>().state.wasteCartItems),
              const SizedBox(height: 16),
              _WasteItemsList(
                items: context.watch<WastesBloc>().state.wasteCartItems,
                controllers: _weightControllers,
                editable: _weightsEditable,
                onWeightChanged: _onWeightChanged,
              ),
            ],
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: _ActionArea(
            phase: _phase,
            loading: _loading,
            onAccept: () => _onAccept(_collect!.id),
            onReject: () => _onReject(_collect!.id),
            onConfirmPickup: () => _onConfirmPickup(_collect!.id),
          ),
        ),
      ],
    );
  }

  void _onWeightChanged(int pasmandId, String value) {
    final bloc = context.read<WastesBloc>();
    final items = bloc.state.wasteCartItems;
    final item = items.where((e) => e.pasmand.id == pasmandId).firstOrNull;
    if (item == null) return;
    final weight = double.tryParse(value)?.toStringAsFixed(3) ?? '0.000';
    bloc.updateWasteCart(item, weight, item.isAdded);
  }

  Future<void> _onAccept(int id) async {
    setState(() => _loading = true);
    try {
      await context.read<WastesBloc>().acceptCollectRequest(id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _showSnack(context.l10n.collectAcceptedSuccessMessage, Colors.green);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onReject(int id) async {
    setState(() => _loading = true);
    try {
      await context.read<WastesBloc>().rejectCollectRequest(id);
      if (!mounted) return;
      _showSnack('Request rejected', Colors.orange);
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onConfirmPickup(int id) async {
    final l10n = context.l10n;
    final items = context.read<WastesBloc>().state.wasteCartItems;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmPickupDialog(items: items),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final payload = items
          .map((e) => {
                'pasmand_id': e.pasmand.id,
                'exact_weight': e.exact_weight,
              })
          .toList();
      await context.read<WastesBloc>().confirmPickup(id, payload);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _showSnack(l10n.confirmPickupSuccess, Colors.green);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

enum _Phase {
  loading,
  pendingAcceptance,
  accepted,
  pickedUp,
  completed,
  cancelled
}

// ---------------------------------------------------------------------------
// STATUS BANNER
// ---------------------------------------------------------------------------
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.phase, required this.collect});
  final _Phase phase;
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (IconData icon, Color color, String text) = switch (phase) {
      _Phase.pendingAcceptance => (
          Icons.hourglass_top_rounded,
          Colors.orange,
          l10n.collectRequestStatusPendingDriverAcceptance,
        ),
      _Phase.accepted => (
          Icons.local_shipping_rounded,
          AppTheme.primary,
          l10n.collectAcceptedStateHint,
        ),
      _Phase.pickedUp => (
          Icons.inventory_2_rounded,
          Colors.blue,
          l10n.requestPickedUpHint,
        ),
      _Phase.completed => (
          Icons.check_circle_rounded,
          Colors.green,
          l10n.alreadyCollected,
        ),
      _Phase.cancelled => (
          Icons.cancel_rounded,
          Colors.red.shade400,
          l10n.collectRequestStatusCancelled,
        ),
      _ => (Icons.info_outline, AppTheme.grey, ''),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REQUEST INFO CARD
// ---------------------------------------------------------------------------
class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final addr = collect.address_data;
    return _SectionCard(
      title: l10n.requestInfoLabel,
      icon: Icons.info_outline_rounded,
      children: [
        _InfoRow(
          icon: Icons.bookmark_border_rounded,
          label: l10n.addressLabel,
          value: addr.name.trim().isEmpty ? '—' : addr.name,
        ),
        _InfoRow(
          icon: Icons.location_pin,
          label: l10n.addressLabel,
          value: addr.address,
        ),
        if (addr.latitude.isNotEmpty)
          _InfoRow(
            icon: Icons.my_location_rounded,
            label: 'GPS',
            value: '${addr.latitude}, ${addr.longitude}',
          ),
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: l10n.scheduledTimeLabel,
          value: '${collect.collect_date.day} — ${collect.collect_date.time}',
        ),
        _InfoRow(
          icon: Icons.flag_outlined,
          label: l10n.statusLabel,
          value: collect.requestStatusDisplay(l10n),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SUMMARY CARD (totals)
// ---------------------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});
  final List<WasteCart> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    double estWeight = 0;
    double exactWeight = 0;
    for (final item in items) {
      estWeight += double.tryParse(item.estimated_weight) ?? 0;
      exactWeight += double.tryParse(item.exact_weight) ?? 0;
    }
    return _SectionCard(
      title: l10n.pickupSummaryLabel,
      icon: Icons.summarize_rounded,
      children: [
        _SummaryRow(
          label: l10n.totalItemsLabel,
          value: items.length.toString(),
          icon: Icons.inventory_2_outlined,
        ),
        _SummaryRow(
          label: l10n.totalEstimatedWeightLabel,
          value: '${estWeight.toStringAsFixed(1)} kg',
          icon: Icons.scale_outlined,
        ),
        _SummaryRow(
          label: l10n.totalExactWeightLabel,
          value: '${exactWeight.toStringAsFixed(1)} kg',
          icon: Icons.precision_manufacturing_outlined,
          highlight: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 20, color: highlight ? AppTheme.primary : AppTheme.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  color: AppTheme.black.withValues(alpha: 0.7),
                  fontSize: 13,
                )),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: highlight ? AppTheme.primary : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WASTE ITEMS LIST
// ---------------------------------------------------------------------------
class _WasteItemsList extends StatelessWidget {
  const _WasteItemsList({
    required this.items,
    required this.controllers,
    required this.editable,
    required this.onWeightChanged,
  });
  final List<WasteCart> items;
  final Map<int, TextEditingController> controllers;
  final bool editable;
  final void Function(int pasmandId, String value) onWeightChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.noWasteAdded,
              style: TextStyle(color: AppTheme.grey, fontSize: 15)),
        ),
      );
    }
    return _SectionCard(
      title: l10n.wasteItemsLabel,
      icon: Icons.recycling_rounded,
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _WasteItemTile(
            item: items[i],
            controller: controllers[items[i].pasmand.id],
            editable: editable,
            onChanged: (v) => onWeightChanged(items[i].pasmand.id, v),
          ),
        ],
      ],
    );
  }
}

class _WasteItemTile extends StatelessWidget {
  const _WasteItemTile({
    required this.item,
    required this.controller,
    required this.editable,
    required this.onChanged,
  });
  final WasteCart item;
  final TextEditingController? controller;
  final bool editable;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estW = double.tryParse(item.estimated_weight) ?? 0;
    final estP = double.tryParse(item.estimated_price) ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pasmand.post_title.isNotEmpty
                          ? item.pasmand.post_title
                          : l10n.noneLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.customerEstimateLabel}: '
                      '${estW.toStringAsFixed(1)} kg'
                      '${estP > 0 ? " · ${estP.toStringAsFixed(0)}/kg" : ""}',
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 52),
              Text(
                l10n.exactWeightLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 52),
              if (editable) ...[
                _WeightStepButton(
                  icon: Icons.remove,
                  onTap: () => _step(-1),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: controller,
                    enabled: editable,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: editable ? AppTheme.primary : AppTheme.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      suffixText: 'kg',
                      suffixStyle: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: editable
                          ? AppTheme.primary.withValues(alpha: 0.06)
                          : AppTheme.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: editable
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : AppTheme.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppTheme.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),
              if (editable) ...[
                const SizedBox(width: 8),
                _WeightStepButton(
                  icon: Icons.add,
                  onTap: () => _step(1),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _step(int direction) {
    if (controller == null) return;
    final current = double.tryParse(controller!.text) ?? 0;
    final next = (current + direction).clamp(0, 99999).toDouble();
    final formatted = next == next.truncateToDouble()
        ? next.toStringAsFixed(0)
        : next.toStringAsFixed(2);
    controller!.text = formatted;
    onChanged(formatted);
  }
}

class _WeightStepButton extends StatelessWidget {
  const _WeightStepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ACTION AREA (bottom buttons)
// ---------------------------------------------------------------------------
class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.phase,
    required this.loading,
    required this.onAccept,
    required this.onReject,
    required this.onConfirmPickup,
  });
  final _Phase phase;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onConfirmPickup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (phase) {
      _Phase.pendingAcceptance => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PrimaryButton(
              label: l10n.collectAcceptLabel,
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              onTap: loading ? null : onAccept,
            ),
            const SizedBox(height: 10),
            _PrimaryButton(
              label: l10n.collectRejectLabel,
              icon: Icons.cancel_rounded,
              color: Colors.red.shade400,
              onTap: loading ? null : onReject,
            ),
          ],
        ),
      _Phase.accepted => _PrimaryButton(
          label: l10n.confirmPickupLabel,
          icon: Icons.local_shipping_rounded,
          color: AppTheme.primary,
          onTap: loading ? null : onConfirmPickup,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? color.withValues(alpha: 0.4) : color,
      borderRadius: BorderRadius.circular(14),
      elevation: onTap == null ? 0 : 4,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CONFIRM PICKUP DIALOG
// ---------------------------------------------------------------------------
class _ConfirmPickupDialog extends StatelessWidget {
  const _ConfirmPickupDialog({required this.items});
  final List<WasteCart> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    double totalExact = 0;
    for (final item in items) {
      totalExact += double.tryParse(item.exact_weight) ?? 0;
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.local_shipping_rounded, color: AppTheme.primary, size: 24),
          const SizedBox(width: 10),
          Text(l10n.confirmPickupTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.confirmPickupMessage,
                style: TextStyle(color: AppTheme.grey, height: 1.4)),
            const SizedBox(height: 16),
            const Divider(),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.pasmand.post_title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${double.tryParse(item.exact_weight)?.toStringAsFixed(1) ?? "0"} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalExactWeightLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '${totalExact.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: Text(l10n.confirmLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ERROR VIEW
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(error,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED: Section Card & Info Row
// ---------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.padding,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.black.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
