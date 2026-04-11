import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/buton_bottom.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/screens/clear_screen.dart';
import 'package:recycleorigindriver/features/wallet_feature/business/entities/wallet.dart';
import 'package:recycleorigindriver/features/wallet_feature/business/entities/wallet_transaction.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/walletScreen';

  const WalletScreen({super.key, this.embedInShell = false});

  /// When true, renders only scrollable content for use inside [NavigationBottomScreen].
  final bool embedInShell;

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _page = 1;
  int _maxPage = 1;
  Wallet _wallet = const Wallet();
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _page < _maxPage) {
        _loadMore();
      }
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadData() async {
    final isLogin = context.read<AuthBloc>().state.isAuth;
    if (!isLogin) return;

    setState(() => _isLoading = true);

    try {
      final headers = await _authHeaders();

      final walletUrl = Uri.parse(Urls.rootUrl + Urls.walletEndPoint);
      final walletResp = await http.get(walletUrl, headers: headers);
      if (walletResp.statusCode == 200 && mounted) {
        final data = jsonDecode(walletResp.body) as Map<String, dynamic>;
        final walletJson = data['wallet'] as Map<String, dynamic>?;
        if (walletJson != null) {
          _wallet = Wallet.fromJson(walletJson);
        }
      }

      _page = 1;
      final txUrl = Uri.parse(
        Urls.rootUrl + Urls.walletTransactionsEndPoint,
      ).replace(queryParameters: {'page': '1', 'per_page': '20'});
      final txResp = await http.get(txUrl, headers: headers);
      if (txResp.statusCode == 200 && mounted) {
        final txData = jsonDecode(txResp.body) as Map<String, dynamic>;
        final txList = txData['data'] as List<dynamic>? ?? [];
        _transactions = txList
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final details = txData['details'] as Map<String, dynamic>?;
        _maxPage = details?['max_pages'] as int? ?? 1;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    try {
      _page++;
      final headers = await _authHeaders();
      final txUrl = Uri.parse(
        Urls.rootUrl + Urls.walletTransactionsEndPoint,
      ).replace(queryParameters: {
        'page': '$_page',
        'per_page': '20',
      });
      final txResp = await http.get(txUrl, headers: headers);
      if (txResp.statusCode == 200 && mounted) {
        final txData = jsonDecode(txResp.body) as Map<String, dynamic>;
        final txList = txData['data'] as List<dynamic>? ?? [];
        final newTx = txList
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _transactions.addAll(newTx);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      case 'GBP':
        return '\u00A3';
      case 'IRR':
        return 'IRR';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().state.isAuth;
    final theme = Theme.of(context);

    final body = !isLogin
        ? _buildNotLoggedIn(context)
        : RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildBalanceCard(context)),
                SliverToBoxAdapter(child: _buildActionBar(context)),
                SliverToBoxAdapter(child: _buildSectionHeader(context)),
                if (_transactions.isEmpty && !_isLoading)
                  SliverToBoxAdapter(child: _buildEmpty(context))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _WalletTxItem(tx: _transactions[i]),
                      childCount: _transactions.length,
                    ),
                  ),
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: AppTheme.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: widget.embedInShell ? 24 : 80,
                  ),
                ),
              ],
            ),
          );

    if (widget.embedInShell) {
      return ColoredBox(
        color: const Color(0xffF9F9F9),
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.l10n.walletLabel),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: body,
      drawer: Theme(
        data: theme.copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final parsed = double.tryParse(_wallet.balance) ?? 0;
    final formatted = intl.NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(parsed);
    final symbol = _currencySymbol(_wallet.currency);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$formatted $symbol',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_wallet.isFrozen) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Wallet Frozen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(ClearScreen.routeName),
        borderRadius: BorderRadius.circular(12),
        child: ButtonBottom(
          width: double.infinity,
          height: 50,
          text: context.l10n.settlementRequestLabel,
          isActive: true,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_transactions.isNotEmpty)
            Text(
              '${_transactions.length} items',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            context.l10n.noTransactionAvailable,
            style: TextStyle(color: AppTheme.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(context.l10n.notLoggedInLabel,
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.l10n.loginToAccountLabel,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _WalletTxItem extends StatelessWidget {
  const _WalletTxItem({required this.tx});

  final WalletTransaction tx;

  IconData get _icon {
    switch (tx.type) {
      case 'driver_commission':
        return Icons.local_shipping;
      case 'collect_reward':
        return Icons.recycling;
      case 'withdrawal':
        return Icons.account_balance;
      case 'admin_adjustment':
        return Icons.admin_panel_settings;
      case 'deposit':
        return Icons.add_circle_outline;
      default:
        return tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  Color get _color => tx.isCredit ? Colors.green.shade600 : Colors.red.shade600;

  @override
  Widget build(BuildContext context) {
    final parsed = double.tryParse(tx.amount) ?? 0;
    final formatted = intl.NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(parsed);
    final prefix = tx.isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.1),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(
          tx.typeLabel,
          style: TextStyle(
            color: AppTheme.h1,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tx.description.isNotEmpty)
              Text(
                tx.description,
                style: TextStyle(color: AppTheme.grey, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (tx.createdAt.isNotEmpty)
              Text(
                _formatDate(tx.createdAt),
                style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Text(
          '$prefix$formatted',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return intl.DateFormat('MMM d, yyyy HH:mm').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
