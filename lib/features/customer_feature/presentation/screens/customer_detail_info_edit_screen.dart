import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/models/customer.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/models/personal_data.dart';
import 'package:recycleorigindriver/core/models/status.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class CustomerDetailInfoEditScreen extends StatefulWidget {
  static const routeName = '/customerDetailInfoEditScreen';

  @override
  State<CustomerDetailInfoEditScreen> createState() =>
      _CustomerDetailInfoEditScreenState();
}

class _CustomerDetailInfoEditScreenState
    extends State<CustomerDetailInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  final _emailController = TextEditingController();
  final _ostanController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();

  final _fnName = FocusNode();
  final _fnFamily = FocusNode();
  final _fnEmail = FocusNode();
  final _fnOstan = FocusNode();
  final _fnCity = FocusNode();
  final _fnPost = FocusNode();

  Driver _driver = Driver.fromJson(null);
  List<Status> _types = [];
  bool _typesLoaded = false;
  bool _saving = false;
  late Status _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final bloc = context.read<CustomerInfoBloc>();
    final d = bloc.state.driver;
    _driver = d;
    _selectedType = d.status;
    _nameController.text = d.driver_data.fname;
    _familyController.text = d.driver_data.lname;
    _emailController.text = d.driver_data.email;
    _ostanController.text = d.driver_data.ostan;
    _cityController.text = d.driver_data.city;
    _postCodeController.text = d.driver_data.postcode;

    try {
      await bloc.getTypes();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.connectionRetryMessage)),
        );
      }
    }
    if (!mounted) return;
    final types = bloc.state.typesItems;
    setState(() {
      _types = types;
      _typesLoaded = true;
      _selectedType = _resolveType(d.status, types);
    });
  }

  Status _resolveType(Status current, List<Status> types) {
    if (types.isEmpty) return current;
    final idx = types.indexWhere((t) => t.term_id == current.term_id);
    if (idx >= 0) return types[idx];
    return types.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _emailController.dispose();
    _ostanController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    _fnName.dispose();
    _fnFamily.dispose();
    _fnEmail.dispose();
    _fnOstan.dispose();
    _fnCity.dispose();
    _fnPost.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_typesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.connectionRetryMessage)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    try {
      final customer = Customer(
        id: 0,
        status: _driver.status,
        type: _selectedType,
        personalData: PersonalData(
          phone: _driver.driver_data.phone,
          first_name: _nameController.text.trim(),
          last_name: _familyController.text.trim(),
          email: _emailController.text.trim(),
          ostan: _ostanController.text.trim(),
          city: _cityController.text.trim(),
          postcode: _postCodeController.text.trim(),
          mobile: _driver.driver_data.mobile,
          addresses: [],
        ),
      );
      await context.read<CustomerInfoBloc>().sendCustomer(customer);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.infoEditedSuccess)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileSaveFailedMessage)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? get _typeDropdownValue {
    if (_types.isEmpty) return null;
    final has = _types.any((t) => t.term_id == _selectedType.term_id);
    if (has) return _selectedType.term_id;
    return _types.first.term_id;
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            context.l10n.editProfileLabel,
            style: const TextStyle(),
          ),
          backgroundColor: AppTheme.appBarColor,
          iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        ),
        endDrawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: MainDrawer(),
        ),
        body: !_typesLoaded
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ColoredBox(
                  color: AppTheme.bg,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        context.l10n.personInfoTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: textScale * 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: context.l10n.firstNameLabel,
                        controller: _nameController,
                        focusNode: _fnName,
                        nextFocus: _fnFamily,
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.l10n.profileNameRequiredMessage;
                          }
                          return null;
                        },
                      ),
                      _ProfileField(
                        label: context.l10n.lastNameLabel,
                        controller: _familyController,
                        focusNode: _fnFamily,
                        nextFocus: _fnEmail,
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.l10n.profileNameRequiredMessage;
                          }
                          return null;
                        },
                      ),
                      _ProfileField(
                        label: context.l10n.emailLabel,
                        controller: _emailController,
                        focusNode: _fnEmail,
                        nextFocus: _fnOstan,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return null;
                          if (!s.contains('@')) {
                            return context.l10n.enterEmailValidationMessage;
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Text(
                          context.l10n.userTypeColon,
                          style: TextStyle(
                            color: AppTheme.black,
                            fontSize: textScale * 13,
                          ),
                        ),
                      ),
                      if (_types.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            context.l10n.profileTypesListEmptyHint,
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: textScale * 13,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AppTheme.h1,
                                width: 0.6,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _typeDropdownValue,
                                hint: Text(context.l10n.userTypeLabel),
                                items: _types
                                    .map(
                                      (Status t) => DropdownMenuItem<int>(
                                        value: t.term_id,
                                        child: Text(
                                          t.name,
                                          style: TextStyle(
                                            fontSize: textScale * 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (int? id) {
                                  if (id == null) return;
                                  final Status t = _types.firstWhere(
                                    (Status e) => e.term_id == id,
                                  );
                                  setState(() => _selectedType = t);
                                },
                              ),
                            ),
                          ),
                        ),
                      const Divider(),
                      _ProfileField(
                        label: context.l10n.provinceLabel,
                        controller: _ostanController,
                        focusNode: _fnOstan,
                        nextFocus: _fnCity,
                      ),
                      _ProfileField(
                        label: context.l10n.cityLabel,
                        controller: _cityController,
                        focusNode: _fnCity,
                        nextFocus: _fnPost,
                      ),
                      _ProfileField(
                        label: context.l10n.postalCodeLabel,
                        controller: _postCodeController,
                        focusNode: _fnPost,
                        nextFocus: null,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: _saving
            ? FloatingActionButton(
                onPressed: null,
                backgroundColor: AppTheme.primary,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: _typesLoaded ? _submit : null,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.check, color: Colors.white),
              ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label :',
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: textScale * 14,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction ??
                (nextFocus != null
                    ? TextInputAction.next
                    : TextInputAction.done),
            onFieldSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
            validator: validator,
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: textScale * 14,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
