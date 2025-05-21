import 'package:get/get.dart';
import 'enums.dart';

/// Model untuk representasi transaksi keuangan
class Transaction {
  /// Identifier unik untuk transaksi
  final String id;
  
  /// Identifier dompet terkait transaksi
  final String walletId;
  
  /// Jumlah transaksi
  final double amount;
  
  /// Deskripsi transaksi
  final String description;
  
  /// Jenis transaksi (income/expense/transfer)
  final TransactionType type;
  
  /// Untuk transaksi transfer, ID dompet tujuan
  final String? destinationWalletId;
  
  /// Waktu terjadinya transaksi
  final DateTime timestamp;
  
  /// Constructor untuk Transaction
  Transaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.description,
    required this.type,
    this.destinationWalletId,
    required this.timestamp,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      walletId: map['walletId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${map['type'] ?? 'expense'}',
        orElse: () => TransactionType.expense,
      ),
      destinationWalletId: map['destinationWalletId'],
      timestamp: map['timestamp'] != null 
                 ? (map['timestamp'] as Timestamp).toDate() 
                 : DateTime.now(),
    );
  }
  
  /// Konversi objek ke Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletId': walletId,
      'amount': amount,
      'description': description,
      'type': type.toString().split('.').last,
      'destinationWalletId': destinationWalletId,
      'timestamp': timestamp,
    };
  }
  
  /// Membuat salinan Transaction dengan nilai yang baru
  Transaction copyWith({
    String? id,
    String? walletId,
    double? amount,
    String? description,
    TransactionType? type,
    String? destinationWalletId,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Shorthand dari Firestore Timestamp untuk model
class Timestamp {
  final int seconds;
  final int nanoseconds;
  
  Timestamp(this.seconds, this.nanoseconds);
  
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
