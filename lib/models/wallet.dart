import 'package:get/get.dart';
import 'enums.dart';

/// Model untuk representasi dompet
class Wallet {
  /// Identifier unik untuk dompet
  final String id;
  
  /// Identifier pemilik dompet
  final String ownerId;
  
  /// Nama dompet
  final String name;
  
  /// Saldo saat ini di dompet
  final double balance;
  
  /// Jenis visibilitas dompet (private/shared)
  final WalletVisibility visibility;
  
  /// Daftar user yang memiliki akses ke dompet (jika shared)
  final List<String> sharedWith;
  
  /// URL untuk sharing dompet (jika shared)
  final String? shareUrl;
  
  /// Waktu pembuatan dompet
  final DateTime createdAt;
  
  /// Constructor untuk Wallet
  Wallet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.balance,
    required this.visibility,
    required this.sharedWith,
    this.shareUrl,
    required this.createdAt,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      visibility: WalletVisibility.values.firstWhere(
        (e) => e.toString() == 'WalletVisibility.${map['visibility'] ?? 'private'}',
        orElse: () => WalletVisibility.private,
      ),
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      shareUrl: map['shareUrl'],
      createdAt: map['createdAt'] != null 
                ? (map['createdAt'] as Timestamp).toDate() 
                : DateTime.now(),
    );
  }
  
  /// Konversi objek ke Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'balance': balance,
      'visibility': visibility.toString().split('.').last,
      'sharedWith': sharedWith,
      'shareUrl': shareUrl,
      'createdAt': createdAt,
    };
  }
  
  /// Membuat salinan Wallet dengan nilai yang baru
  Wallet copyWith({
    String? id,
    String? ownerId,
    String? name,
    double? balance,
    WalletVisibility? visibility,
    List<String>? sharedWith,
    String? shareUrl,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      visibility: visibility ?? this.visibility,
      sharedWith: sharedWith ?? this.sharedWith,
      shareUrl: shareUrl ?? this.shareUrl,
      createdAt: createdAt ?? this.createdAt,
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
