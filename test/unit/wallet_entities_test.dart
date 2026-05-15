import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/wallet_feature/business/entities/wallet.dart';
import 'package:recycleorigindriver/features/wallet_feature/business/entities/wallet_transaction.dart';

void main() {
  group('Wallet', () {
    test('fromJson maps API fields with defaults', () {
      final w = Wallet.fromJson({
        'id': 5,
        'user_id': 9,
        'balance': '120.5',
        'currency': 'IRR',
        'is_frozen': true,
      });
      expect(w.id, 5);
      expect(w.userId, 9);
      expect(w.balance, '120.5');
      expect(w.currency, 'IRR');
      expect(w.isFrozen, isTrue);
    });

    test('fromJson uses defaults for empty map', () {
      final w = Wallet.fromJson({});
      expect(w.balance, '0');
      expect(w.isFrozen, isFalse);
    });
  });

  group('WalletTransaction', () {
    test('isCredit reflects direction', () {
      expect(
        const WalletTransaction(direction: 'credit').isCredit,
        isTrue,
      );
      expect(
        const WalletTransaction(direction: 'debit').isCredit,
        isFalse,
      );
    });

    test('typeLabel maps known types', () {
      expect(
        const WalletTransaction(type: 'collect_reward').typeLabel,
        'Collection Reward',
      );
      expect(
        const WalletTransaction(type: 'driver_commission').typeLabel,
        'Commission Earned',
      );
      expect(
        const WalletTransaction(type: 'unknown_type').typeLabel,
        'unknown type',
      );
    });

    test('fromJson parses snake_case keys', () {
      final t = WalletTransaction.fromJson({
        'id': 1,
        'balance_after': '10',
        'reference_id': 42,
        'created_at': '2026-01-01',
      });
      expect(t.balanceAfter, '10');
      expect(t.referenceId, 42);
      expect(t.createdAt, '2026-01-01');
    });
  });
}
