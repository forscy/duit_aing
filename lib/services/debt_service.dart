import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../models/enums.dart';

class DebtService {
  final FirebaseFirestore _firestore;

  DebtService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _debtsCollection =>
      _firestore.collection('debts');

  /// Menambahkan hutang/piutang baru
  Future<void> addDebt(DebtModel debt) async {
    await _debtsCollection.doc(debt.id).set(debt.toMap());
  }

  /// Mengupdate status hutang/piutang
  Future<void> updateDebtStatus(String debtId, {
    required DebtStatus newStatus,
    String? paymentWalletId,
  }) async {
    await _debtsCollection.doc(debtId).update({
      'status': newStatus.toString().split('.').last,
      'paidAt': newStatus == DebtStatus.paid ? Timestamp.now() : null,
      'paymentWalletId': paymentWalletId,
    });
  }

  /// Update data hutang
  Future<void> updateDebt(DebtModel debt) async {
    try {
      await _firestore.collection('debts').doc(debt.id).update(debt.toMap());
    } catch (e) {
      debugPrint('Error updating debt: $e');
      rethrow;
    }
  }

  /// Toggle status aktif/nonaktif hutang
  Future<void> toggleDebtStatus(String debtId, bool isActive) async {
    try {
      await _firestore.collection('debts').doc(debtId).update({
        'isActive': isActive,
      });
    } catch (e) {
      debugPrint('Error toggling debt status: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua hutang/piutang
  Stream<List<DebtModel>> getDebts() {
    return _debtsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtModel.fromMap(doc.data()))
            .toList());
  }

  /// Mendapatkan hutang/piutang berdasarkan wallet
  Stream<List<DebtModel>> getDebtsByWallet(String walletId) {
    return _debtsCollection
        .where('walletId', isEqualTo: walletId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtModel.fromMap(doc.data()))
            .toList());
  }

  /// Mendapatkan hutang/piutang yang belum dibayar
  Stream<List<DebtModel>> getUnpaidDebts() {
    return _debtsCollection
        .where('status', isEqualTo: DebtStatus.unpaid.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtModel.fromMap(doc.data()))
            .toList());
  }
}
