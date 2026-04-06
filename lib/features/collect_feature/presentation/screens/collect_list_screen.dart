import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/widgets/collect_item_collect_screen.dart';

class CollectListScreen extends StatefulWidget {
  static const routeName = '/collectListScreen';

  const CollectListScreen({super.key});

  @override
  State<CollectListScreen> createState() => _CollectListScreenState();
}

class _CollectListScreenState extends State<CollectListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInit = true;
  bool _isLoading = false;
  bool _hasError = false;
  int _page = 1;
  SearchDetail _searchDetail = SearchDetail(total: 0, max_page: 1);
  final List<RequestWasteItem> _items = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _page < _searchDetail.max_page &&
        !_hasError) {
      _loadMoreItems();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final bloc = context.read<WastesBloc>();
      bloc.sPage = 1;
      bloc.searchBuilder();
      await bloc.searchCollectItems();
      if (!mounted) return;
      _searchDetail =
          bloc.state.searchDetails ?? SearchDetail(total: 0, max_page: 1);
      _items
        ..clear()
        ..addAll(bloc.state.collectItems);
      _page = 1;
    } catch (e) {
      if (mounted) _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoading = true);
    try {
      _page++;
      final bloc = context.read<WastesBloc>();
      bloc.sPage = _page;
      bloc.searchBuilder();
      await bloc.searchCollectItems();
      if (!mounted) return;
      _items.addAll(bloc.state.collectItems);
      _searchDetail =
          bloc.state.searchDetails ?? SearchDetail(total: 0, max_page: 1);
    } catch (e) {
      _page--;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.noRequestAvailable),
            action: SnackBarAction(
              label: context.l10n.retryLabel,
              onPressed: _loadMoreItems,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().state.isAuth;
    final l10n = context.l10n;

    return !isLogin ? _buildNotLoggedIn(l10n) : _buildContent(l10n);
  }

  Widget _buildNotLoggedIn(dynamic l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(l10n.notLoggedInLabel,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.loginToAccountLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic l10n) {
    if (_hasError && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(l10n.noRequestAvailable,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(l10n.retryLabel,
                  style: const TextStyle(color: Colors.white)),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (_items.isNotEmpty) SliverToBoxAdapter(child: _buildStatsRow()),
          _buildRequestsList(),
          if (_isLoading && _items.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _StatChip(
            label: context.l10n.countWithColon,
            value: EnArConvertor.localize(
              context,
              _items.length.toString(),
            ),
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: context.l10n.ofLabel,
            value: EnArConvertor.localize(
              context,
              _searchDetail.total.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading && _items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                context.l10n.noRequestAvailable,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: ChangeNotifierProvider.value(
            value: _items[index],
            child: const CollectItemCollectsScreen(),
          ),
        ),
        childCount: _items.length,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              )),
        ],
      ),
    );
  }
}
