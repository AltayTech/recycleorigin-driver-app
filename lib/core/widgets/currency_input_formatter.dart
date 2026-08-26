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

    double value = double.parse(newValue.text);
    totalPricevalue = value;
    final formatter = intl.NumberFormat.decimalPattern();

    String newText = formatter.format(value / 1);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
