import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_models.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_repository.dart';

/// Thread view for one ticket (driver).
class DriverSupportTicketDetailScreen extends StatefulWidget {
  const DriverSupportTicketDetailScreen({super.key});

  static const routeName = '/driverSupportTicketDetail';

  @override
  State<DriverSupportTicketDetailScreen> createState() =>
      _DriverSupportTicketDetailScreenState();
}

class _DriverSupportTicketDetailScreenState
    extends State<DriverSupportTicketDetailScreen> {
  final _repo = DriverSupportTicketRepository();
  final _reply = TextEditingController();
  String? _ticketId;
  SupportTicket? _ticket;
  List<SupportTicketMessage> _messages = <SupportTicketMessage>[];
  bool _loading = true;
  String? _error;
  bool _sending = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticketId ??= ModalRoute.of(context)?.settings.arguments as String?;
    if (!_started && _ticketId != null) {
      _started = true;
      _load();
    }
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _ticketId;
    if (id == null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final t = await _repo.getTicket(id);
    final m = await _repo.listMessages(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _ticket = t;
      _messages = m?.items ?? <SupportTicketMessage>[];
      if (t == null) {
        _error = 'Not found';
      }
    });
  }

  bool get _canReply => (_ticket?.status ?? '') != 'closed';

  Future<void> _send() async {
    final text = _reply.text.trim();
    final id = _ticketId;
    if (text.isEmpty || id == null) {
      return;
    }
    setState(() => _sending = true);
    final msg = await _repo.postMessage(id, text);
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    if (msg != null) {
      _reply.clear();
      setState(
        () => _messages = <SupportTicketMessage>[..._messages, msg],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket',
          style: TextStyle(color: AppTheme.bg),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : () => _load(),
            icon: Icon(Icons.refresh, color: AppTheme.appBarIconColor),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    if (_ticket != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Material(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _ticket!.subject,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_ticket!.ticketNumber} · ${_ticket!.status}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final m = _messages[i];
                          final fromUser = m.isFromUser;
                          return Align(
                            alignment: fromUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.85,
                              ),
                              decoration: BoxDecoration(
                                color: fromUser
                                    ? AppTheme.primary.withValues(alpha: 0.15)
                                    : AppTheme.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(m.content),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_canReply)
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _reply,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: 'Reply…',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                onPressed: _sending ? null : _send,
                                icon: _sending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
