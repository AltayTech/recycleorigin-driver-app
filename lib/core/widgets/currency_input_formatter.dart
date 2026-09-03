import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

class CurrencyInputFormatter extends TextInputFormatter {
  late double totalPricevalue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final parsed = double.tryParse(newValue.text.replaceAll(',', ''));
    if (parsed == null) {
      return oldValue;
    }
    final value = parsed;
    totalPricevalue = value;
    final formatter = intl.NumberFormat.decimalPattern();

    final newText = formatter.format(value / 1);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
