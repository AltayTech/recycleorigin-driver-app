import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/features/support_tickets/data/driver_support_ticket_repository.dart';
/// Create a support ticket (driver).
class DriverSupportTicketCreateScreen extends StatefulWidget {
  const DriverSupportTicketCreateScreen({super.key});

  static const routeName = '/driverSupportTicketCreate';

  @override
  State<DriverSupportTicketCreateScreen> createState() =>
      _DriverSupportTicketCreateScreenState();
}

class _DriverSupportTicketCreateScreenState
    extends State<DriverSupportTicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _trip = TextEditingController();
  final _repo = DriverSupportTicketRepository();
  String _category = 'general';
  bool _saving = false;

  static const Map<String, String> _categories = <String, String>{
    'general': 'General',
    'payment': 'Payment',
    'technical': 'Technical',
    'account': 'Account',
    'trip_issue': 'Collection / trip',
    'other': 'Other',
  };

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    _trip.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    final t = await _repo.createTicket(
      subject: _subject.text.trim(),
      category: _category,
      description: _body.text.trim(),
      relatedTripId: _trip.text.trim().isEmpty ? null : _trip.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (t != null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create ticket')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New ticket',
          style: TextStyle(color: AppTheme.bg),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Our team will review your ticket and reply here.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.length < 10) {
                  return 'Min 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'general'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _body,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.length < 30) {
                  return 'Min 30 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _trip,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Related request ID (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
