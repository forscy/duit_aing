import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Model untuk representasi hutang/piutang
class DebtModel {
  /// Identifier unik untuk hutang/piutang
  final String id;
  
  /// Identifier dompet terkait dengan hutang/piutang
  final String walletId;
  
  /// Nama orang terkait dengan hutang/piutang
  final String personName;
  
  /// Jumlah hutang/piutang
  final double amount;
  
  /// Jenis hutang (debt/receivable)
  final DebtKind kind;
  
  /// Status hutang (paid/unpaid)
  final DebtStatus status;
  
  /// Deskripsi hutang/piutang
  final String description;
  
  /// Tanggal hutang dibuat
  final Timestamp createdAt;
  
  /// Tanggal pelunasan (jika sudah dibayar)
  final Timestamp? paidAt;
  
  /// ID dompet yang digunakan untuk membayar hutang (jika sudah dibayar)
  final String? paymentWalletId;
  
  /// Status aktif/nonaktif
  final bool isActive;
  
  /// Constructor untuk DebtModel
  DebtModel({
    required this.id,
    required this.walletId,
    required this.personName,
    required this.amount,
    required this.kind,
    required this.status,
    required this.description,
    required this.createdAt,
    this.paidAt,
    this.paymentWalletId,
    this.isActive = true,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] ?? '',
      walletId: map['walletId'] ?? '',
      personName: map['personName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      kind: DebtKind.values.firstWhere(
        (e) => e.toString() == 'DebtKind.${map['kind'] ?? 'debt'}',
        orElse: () => DebtKind.debt,
      ),
      status: DebtStatus.values.firstWhere(
        (e) => e.toString() == 'DebtStatus.${map['status'] ?? 'unpaid'}',
        orElse: () => DebtStatus.unpaid,
      ),
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null 
                ? (map['createdAt'] as Timestamp)
                : Timestamp.now(),
      paidAt: map['paidAt'] != null 
              ? (map['paidAt'] as Timestamp)
              : null,
      paymentWalletId: map['paymentWalletId'],
      isActive: map['isActive'] ?? true,
    );
  }
  
  /// Konversi objek ke Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletId': walletId,
      'personName': personName,
      'amount': amount,
      'kind': kind.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'createdAt': createdAt,
      'paidAt': paidAt,
      'paymentWalletId': paymentWalletId,
      'isActive': isActive,
    };
  }
  
  /// Membuat salinan DebtModel dengan nilai yang baru
  DebtModel copyWith({
    String? id,
    String? walletId,
    String? personName,
    double? amount,
    DebtKind? kind,
    DebtStatus? status,
    String? description,
    Timestamp? createdAt,
    Timestamp? paidAt,
    String? paymentWalletId,
    bool? isActive,
  }) {
    return DebtModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentWalletId: paymentWalletId ?? this.paymentWalletId,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Shorthand dari Firestore Timestamp untuk model
