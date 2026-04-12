import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_state.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/widgets/collect_item_collect_screen.dart';

/// Assigned collection requests for the driver (home → Collection tab).
class CollectListScreen extends StatefulWidget {
  static const routeName = '/collectListScreen';

  const CollectListScreen({super.key});

  @override
  State<CollectListScreen> createState() => _CollectListScreenState();
}

enum _CollectListSort {
  newestFirst,
  oldestFirst,
  idHighToLow,
  idLowToHigh,
}

class _CollectListScreenState extends State<CollectListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInit = true;
  bool _isLoading = false;
  bool _hasError = false;
  int _page = 1;
  SearchDetail _searchDetail = SearchDetail(total: 0, max_page: 1);
  final List<RequestWasteItem> _items = [];

  _CollectListSort _sort = _CollectListSort.newestFirst;

  /// API [category] query: '' = all; see backend `applyDriverCollectListFilter`.
  String _filterSlug = '';

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
      final bloc = context.read<WastesBloc>();
      _sort = _sortFromState(bloc.state);
      _filterSlug = _filterSlugFromState(bloc.state);
      _reloadFromFirstPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _CollectListSort _sortFromState(WastesState s) {
    final byId = s.sOrderBy == 'id';
    final asc = s.sOrder == 'asc';
    if (byId) {
      return asc ? _CollectListSort.idLowToHigh : _CollectListSort.idHighToLow;
    }
    return asc ? _CollectListSort.oldestFirst : _CollectListSort.newestFirst;
  }

  String _filterSlugFromState(WastesState s) {
    final c = s.sCategory;
    if (c == null) {
      return '';
    }
    return c.toString();
  }

  void _applySortToBloc(WastesBloc bloc, _CollectListSort sort) {
    final (String order, String orderBy) = switch (sort) {
      _CollectListSort.newestFirst => ('desc', 'date'),
      _CollectListSort.oldestFirst => ('asc', 'date'),
      _CollectListSort.idHighToLow => ('desc', 'id'),
      _CollectListSort.idLowToHigh => ('asc', 'id'),
    };
    bloc.sOrder = order;
    bloc.sOrderBy = orderBy;
  }

  void _applyFilterToBloc(WastesBloc bloc, String slug) {
    bloc.sCategory = slug.isEmpty ? '' : slug;
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

  Future<void> _reloadFromFirstPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    try {
      final bloc = context.read<WastesBloc>();
      bloc.sPage = 1;
      _applySortToBloc(bloc, _sort);
      _applyFilterToBloc(bloc, _filterSlug);
      bloc.searchBuilder();
      await bloc.searchCollectItems();
      if (!mounted) {
        return;
      }
      _searchDetail =
          bloc.state.searchDetails ?? SearchDetail(total: 0, max_page: 1);
      _items
        ..clear()
        ..addAll(bloc.state.collectItems);
      _page = 1;
    } catch (e) {
      if (mounted) {
        _hasError = true;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      if (!mounted) {
        return;
      }
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSortSheet(AppLocalizations l10n) async {
    var picked = _sort;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.collectListSortSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<_CollectListSort>(
                  title: Text(l10n.collectListSortNewestFirst),
                  value: _CollectListSort.newestFirst,
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<_CollectListSort>(
                  title: Text(l10n.collectListSortOldestFirst),
                  value: _CollectListSort.oldestFirst,
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<_CollectListSort>(
                  title: Text(l10n.collectListSortIdDesc),
                  value: _CollectListSort.idHighToLow,
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<_CollectListSort>(
                  title: Text(l10n.collectListSortIdAsc),
                  value: _CollectListSort.idLowToHigh,
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == _sort) {
      return;
    }
    setState(() => _sort = picked);
    await _reloadFromFirstPage();
  }

  Future<void> _showFilterSheet(AppLocalizations l10n) async {
    var picked = _filterSlug;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.collectListFilterSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: Text(l10n.collectListFilterAll),
                  value: '',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.collectListFilterNeedsAction),
                  value: 'needs_accept',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.collectRequestStatusInProgress),
                  value: 'in_progress',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.collectRequestStatusPickedUp),
                  value: 'picked_up',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.collectRequestStatusCollected),
                  value: 'collected',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.collectRequestStatusCancelled),
                  value: 'cancelled',
                  groupValue: picked,
                  onChanged: (v) {
                    if (v != null) {
                      picked = v;
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == _filterSlug) {
      return;
    }
    setState(() => _filterSlug = picked);
    await _reloadFromFirstPage();
  }

  Widget _buildListToolbar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled = _isLoading;
    final hasFilter = _filterSlug.isNotEmpty;
    final showSummary = _items.isNotEmpty;
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showSummary) ...[
                _buildToolbarSummary(l10n, theme),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: disabled ? null : () => _showSortSheet(l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: Icon(
                        Icons.sort_rounded,
                        size: 20,
                        color: disabled ? null : colorScheme.primary,
                      ),
                      label: Text(
                        _sortOptionLabel(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          disabled ? null : () => _showFilterSheet(l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: Badge(
                        isLabelVisible: hasFilter,
                        smallSize: 8,
                        child: Icon(
                          Icons.filter_list_rounded,
                          size: 20,
                          color: disabled ? null : colorScheme.primary,
                        ),
                      ),
                      label: Text(
                        hasFilter
                            ? _filterSelectionLabel(l10n)
                            : l10n.collectListFilterTooltip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sortOptionLabel(AppLocalizations l10n) {
    return switch (_sort) {
      _CollectListSort.newestFirst => l10n.collectListSortNewestFirst,
      _CollectListSort.oldestFirst => l10n.collectListSortOldestFirst,
      _CollectListSort.idHighToLow => l10n.collectListSortIdDesc,
      _CollectListSort.idLowToHigh => l10n.collectListSortIdAsc,
    };
  }

  String _filterSelectionLabel(AppLocalizations l10n) {
    return switch (_filterSlug) {
      '' => l10n.collectListFilterAll,
      'needs_accept' => l10n.collectListFilterNeedsAction,
      'in_progress' => l10n.collectRequestStatusInProgress,
      'picked_up' => l10n.collectRequestStatusPickedUp,
      'collected' => l10n.collectRequestStatusCollected,
      'cancelled' => l10n.collectRequestStatusCancelled,
      _ => l10n.collectListFilterTooltip,
    };
  }

  Widget _buildToolbarSummary(AppLocalizations l10n, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final loaded = EnArConvertor.localize(
      context,
      _items.length.toString(),
    );
    final total = EnArConvertor.localize(
      context,
      _searchDetail.total.toString(),
    );
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
    final valueStyle = theme.textTheme.titleSmall?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );
    final sepStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
    );

    final semantic = StringBuffer()
      ..write('${l10n.countWithColon} $loaded')
      ..write(', ${l10n.ofLabel} $total');

    return Semantics(
      label: semantic.toString(),
      container: true,
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.countWithColon, style: labelStyle),
                TextSpan(text: ' ', style: labelStyle),
                TextSpan(text: loaded, style: valueStyle),
                TextSpan(text: ' \u00b7 ', style: sepStyle),
                TextSpan(text: l10n.ofLabel, style: labelStyle),
                TextSpan(text: ' ', style: labelStyle),
                TextSpan(text: total, style: valueStyle),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().state.isAuth;
    final l10n = context.l10n;

    return !isLogin ? _buildNotLoggedIn(l10n) : _buildContent(l10n);
  }

  Widget _buildNotLoggedIn(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.notLoggedInLabel,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.loginToAccountLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_hasError && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              l10n.noRequestAvailable,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadFromFirstPage,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                l10n.retryLabel,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reloadFromFirstPage,
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildListToolbar(l10n)),
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
