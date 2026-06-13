import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/guide_feature/domain/guide_cms_mapper.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_cms_section.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_driver_steps_section.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_error_view.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_header.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver Help: native workflow steps plus CMS policies and FAQ.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  static const routeName = '/guideScreen';

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      await context.read<CustomerInfoBloc>().fetchShopData();
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<CustomerInfoBloc>().state.shop;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(context.l10n.guideLabel),
        centerTitle: true,
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: _buildBody(context, shop, scheme),
    );
  }

  Widget _buildBody(BuildContext context, Shop? shop, ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError || shop == null) {
      return GuideErrorView(onRetry: _load);
    }

    final cmsSections = guideCmsSectionsForDriver(context.l10n, shop);

    return RefreshIndicator(
      onRefresh: _load,
      color: scheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GuideHeader(shop: shop),
            const SizedBox(height: 24),
            const GuideDriverStepsSection(),
            if (cmsSections.isNotEmpty) ...<Widget>[
              const SizedBox(height: 24),
              GuideCmsSection(sections: cmsSections),
            ],
          ],
        ),
      ),
    );
  }
}
