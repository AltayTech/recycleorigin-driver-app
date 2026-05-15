import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Whether [operation] from the API indicates a withdrawal (debit).
bool isWithdrawalOperation(String operation) {
  final t = operation.trim().toLowerCase();
  return operation == 'برداشت' ||
      t == 'withdrawal' ||
      t == 'withdraw' ||
      t == 'debit' ||
      t == 'çekim' ||
      t == 'cekim';
}

/// Whether [operation] from the API indicates a deposit (credit).
bool isDepositOperation(String operation) {
  final t = operation.trim().toLowerCase();
  return operation == 'واریز' || t == 'deposit' || t == 'credit';
}

/// Maps known API operation strings to localized labels; otherwise returns
/// [operation] unchanged.
String localizedTransactionOperation(
  AppLocalizations l10n,
  String operation,
) {
  if (isWithdrawalOperation(operation)) {
    return l10n.transactionOperationWithdrawal;
  }
  if (isDepositOperation(operation)) {
    return l10n.transactionOperationDeposit;
  }
  return operation;
}
