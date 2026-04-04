import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_models.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_repository.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_create_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_detail_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver support ticket inbox.
class DriverSupportTicketsListScreen extends StatefulWidget {
  const DriverSupportTicketsListScreen({super.key});

  static const routeName = '/driverSupportTickets';

  @override
  State<DriverSupportTicketsListScreen> createState() =>
      _DriverSupportTicketsListScreenState();
}

class _DriverSupportTicketsListScreenState
    extends State<DriverSupportTicketsListScreen> {
  final _repo = DriverSupportTicketRepository();
  PagedTickets? _page;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>();
    if (!auth.state.isAuth) {
      setState(() {
        _loading = false;
        _page = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final p = await _repo.listTickets();
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      if (p == null) {
        _error = 'Could not load tickets';
      } else {
        _page = p;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support tickets',
          style: TextStyle(color: AppTheme.bg),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: <Widget>[
          if (authState.isAuth)
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : () => _load(),
              icon: Icon(Icons.refresh, color: AppTheme.appBarIconColor),
            ),
        ],
      ),
      endDrawer:  MainDrawer(),
      floatingActionButton: authState.isAuth
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  DriverSupportTicketCreateScreen.routeName,
                );
                _load();
              },
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: !authState.isAuth
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.loginRequiredDescription,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(LoginScreen.routeName),
                      child: Text(l10n.loginLabel),
                    ),
                  ],
                ),
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!),
                          TextButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _page == null || _page!.items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Center(child: Text('No tickets yet')),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: _page!.items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final t = _page!.items[i];
                                return ListTile(
                                  tileColor: AppTheme.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text(t.subject),
                                  subtitle: Text(
                                    '${t.ticketNumber} · ${t.status}',
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      DriverSupportTicketDetailScreen.routeName,
                                      arguments: t.id,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
    );
  }
}
