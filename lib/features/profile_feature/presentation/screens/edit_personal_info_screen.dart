import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/models/customer.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/models/personal_data.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/utils/driver_display.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_form_field.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_section_card.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Editable driver personal information form.
class EditPersonalInfoScreen extends StatefulWidget {
  static const routeName = '/edit_personal_info';

  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  final _ostanController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _emailDisplayController = TextEditingController();
  final _phoneDisplayController = TextEditingController();
  final _userTypeDisplayController = TextEditingController();

  final _fnName = FocusNode();
  final _fnFamily = FocusNode();
  final _fnOstan = FocusNode();
  final _fnCity = FocusNode();
  final _fnPost = FocusNode();
  final _fnEmail = FocusNode(canRequestFocus: false);
  final _fnPhone = FocusNode(canRequestFocus: false);
  final _fnUserType = FocusNode(canRequestFocus: false);

  Driver _driver = Driver.fromJson(null);
  bool _saving = false;

  late String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    final d = context.read<CustomerInfoBloc>().state.driver;
    final l10n = context.l10n;
    _driver = d;
    _nameController.text = d.driver_data.fname;
    _familyController.text = d.driver_data.lname;
    _emailDisplayController.text = d.driver_data.email;
    _userTypeDisplayController.text = DriverDisplay.userTypeLabel(d, l10n);
    _ostanController.text = d.driver_data.ostan;
    _cityController.text = d.driver_data.city;
    _postCodeController.text = d.driver_data.postcode;
    final phoneDisplay = d.driver_data.mobile.trim().isNotEmpty
        ? d.driver_data.mobile.trim()
        : d.driver_data.phone.trim();
    _phoneDisplayController.text = phoneDisplay;
    _initialSnapshot = _snapshot();
    if (mounted) {
      setState(() {});
    }
  }

  String _snapshot() {
    return [
      _nameController.text.trim(),
      _familyController.text.trim(),
      _ostanController.text.trim(),
      _cityController.text.trim(),
      _postCodeController.text.trim(),
    ].join('|');
  }

  bool get _hasUnsavedChanges => _snapshot() != _initialSnapshot;

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) {
      return true;
    }
    final l10n = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEditingLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.discardLabel),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _ostanController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    _emailDisplayController.dispose();
    _phoneDisplayController.dispose();
    _userTypeDisplayController.dispose();
    _fnName.dispose();
    _fnFamily.dispose();
    _fnOstan.dispose();
    _fnCity.dispose();
    _fnPost.dispose();
    _fnEmail.dispose();
    _fnPhone.dispose();
    _fnUserType.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    try {
      final customer = Customer(
        id: 0,
        status: _driver.status,
        type: _driver.status,
        personalData: PersonalData(
          phone: _driver.driver_data.phone,
          first_name: _nameController.text.trim(),
          last_name: _familyController.text.trim(),
          email: _driver.driver_data.email,
          ostan: _ostanController.text.trim(),
          city: _cityController.text.trim(),
          postcode: _postCodeController.text.trim(),
          mobile: _driver.driver_data.mobile,
          addresses: [],
        ),
      );
      await context.read<CustomerInfoBloc>().sendCustomer(customer);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.infoEditedSuccess)),
      );
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save driver profile',
        name: 'recycleorigindriver.profile',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileSaveFailedMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              if (await _confirmDiscard() && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          centerTitle: true,
          title: Text(
            l10n.editProfileLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _saving
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : FilledButton.tonal(
                      onPressed: _submit,
                      child: Text(l10n.saveLabel),
                    ),
            ),
          ],
        ),
        drawer: mainDrawerIfRootRoute(context),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              ProfileSectionCard(
                title: l10n.basicInfoSectionTitle,
                children: <Widget>[
                  ProfileFormField(
                    label: l10n.firstNameLabel,
                    controller: _nameController,
                    focusNode: _fnName,
                    nextFocus: _fnFamily,
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.profileNameRequiredMessage;
                      }
                      return null;
                    },
                  ),
                  ProfileFormField(
                    label: l10n.lastNameLabel,
                    controller: _familyController,
                    focusNode: _fnFamily,
                    nextFocus: _fnOstan,
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.profileNameRequiredMessage;
                      }
                      return null;
                    },
                  ),
                  ProfileFormField(
                    label: l10n.userTypeLabel,
                    controller: _userTypeDisplayController,
                    focusNode: _fnUserType,
                    readOnly: true,
                    helperText: l10n.userTypeReadOnlyHint,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileSectionCard(
                title: l10n.contactSectionTitle,
                children: <Widget>[
                  ProfileFormField(
                    label: l10n.emailLabel,
                    controller: _emailDisplayController,
                    focusNode: _fnEmail,
                    readOnly: true,
                    helperText: l10n.emailIsLoginCredentialHint,
                  ),
                  ProfileFormField(
                    label: l10n.mobileLabel,
                    controller: _phoneDisplayController,
                    focusNode: _fnPhone,
                    readOnly: true,
                    helperText: l10n.phoneIsLoginIdentifierHint,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileSectionCard(
                title: l10n.addressSectionTitle,
                children: <Widget>[
                  ProfileFormField(
                    label: l10n.provinceLabel,
                    controller: _ostanController,
                    focusNode: _fnOstan,
                    nextFocus: _fnCity,
                  ),
                  ProfileFormField(
                    label: l10n.cityLabel,
                    controller: _cityController,
                    focusNode: _fnCity,
                    nextFocus: _fnPost,
                  ),
                  ProfileFormField(
                    label: l10n.postalCodeLabel,
                    controller: _postCodeController,
                    focusNode: _fnPost,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (String? v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) {
                        return null;
                      }
                      if (s.length != 5) {
                        return l10n.postalCodeHintMessage;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
