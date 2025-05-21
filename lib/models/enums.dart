/// Enum untuk jenis visibilitas dompet
enum WalletVisibility {
  /// Dompet pribadi yang hanya bisa diakses pemilik
  private,
  
  /// Dompet yang dapat dibagikan dengan pengguna lain
  shared
}

/// Enum untuk jenis transaksi
enum TransactionType {
  /// Transaksi pemasukan
  income,
  
  /// Transaksi pengeluaran
  expense,
  
  /// Transaksi transfer ke dompet lain
  transfer
}

/// Enum untuk status hutang/piutang
enum DebtStatus {
  /// Hutang/piutang belum dibayar
  unpaid,
  
  /// Hutang/piutang sudah dibayar lunas
  paid
}

/// Enum untuk jenis hutang/piutang
enum DebtKind {
  /// Uang yang kita hutang ke orang lain
  debt,
  
  /// Uang yang orang lain hutang ke kita
  receivable
}
