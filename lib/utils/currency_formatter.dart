class CurrencyFormatter {
  /// Format angka menjadi format mata uang
  /// Contoh: 1000000 menjadi 1.000.000
  static String format(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    mathFunc(Match match) => '${match[1]}.';
    return amount.toString().replaceAllMapped(reg, mathFunc);
  }
}
