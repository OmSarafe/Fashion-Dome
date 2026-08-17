String formatPounds(int valueInPence) {
  return '£${(valueInPence / 100).toStringAsFixed(2)}';
}
