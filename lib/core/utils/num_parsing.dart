/// Safe numeric parsing helpers for API string values.
double parseDoubleOr(String? value, [double fallback = 0]) {
  if (value == null || value.trim().isEmpty) {
    return fallback;
  }
  return double.tryParse(value.trim()) ?? fallback;
}

int parseIntOr(String? value, [int fallback = 0]) {
  if (value == null || value.trim().isEmpty) {
    return fallback;
  }
  return int.tryParse(value.trim()) ?? fallback;
}
