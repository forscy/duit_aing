import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart' as transaction_model;
import '../models/wallet.dart';

/// Provider untuk operasi transaksi
final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier();
});

/// Controller notifier untuk transaksi
class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionNotifier() : super(const AsyncValue.data(null));

  /// Method untuk menambah transaksi
  Future<void> addTransaction(transaction_model.Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      // Gunakan transaction Firestore untuk memastikan atomicity
      await _firestore.runTransaction((txn) async {
        // 1. Dapatkan wallet terkait
        final walletDoc = await txn.get(_firestore.collection('wallets').doc(transaction.walletId));
        
        if (!walletDoc.exists) {
          throw Exception('Dompet tidak ditemukan');
        }
        
        // 2. Update wallet balance berdasarkan jenis transaksi
        Wallet wallet = Wallet.fromMap({'id': walletDoc.id, ...walletDoc.data()!});
        double updatedBalance = wallet.balance;
        
        switch (transaction.type) {          case TransactionType.income:
            updatedBalance += transaction.amount;
            break;
          case TransactionType.expense:
            // Check if this transaction would result in negative balance
            if (wallet.balance < transaction.amount) {
              throw Exception('Saldo tidak cukup untuk melakukan transaksi ini');
            }
            updatedBalance -= transaction.amount;
            break;
          case TransactionType.transfer:
            if (transaction.destinationWalletId == null) {
              throw Exception('ID dompet tujuan diperlukan untuk transfer');
            }
            
            // Check if this transfer would result in negative balance
            if (wallet.balance < transaction.amount) {
              throw Exception('Saldo tidak cukup untuk melakukan transfer');
            }
            updatedBalance -= transaction.amount;
            
            // Dapatkan dompet tujuan
            final destWalletDoc = await txn.get(_firestore.collection('wallets').doc(transaction.destinationWalletId));
            if (!destWalletDoc.exists) {
              throw Exception('Dompet tujuan tidak ditemukan');
            }
            
            // Update saldo dompet tujuan
            final destWallet = Wallet.fromMap({'id': destWalletDoc.id, ...destWalletDoc.data()!});
            final updatedDestBalance = destWallet.balance + transaction.amount;
            
            txn.update(_firestore.collection('wallets').doc(transaction.destinationWalletId), {
              'balance': updatedDestBalance,
            });
            break;
        }
        
        // 3. Update saldo wallet sumber
        txn.update(_firestore.collection('wallets').doc(transaction.walletId), {
          'balance': updatedBalance,
        });
        
        // 4. Simpan transaksi
        final transactionRef = _firestore.collection('transactions').doc(transaction.id);
        txn.set(transactionRef, transaction.toMap());
      });
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  /// Mendapatkan transaksi berdasarkan wallet ID
  Stream<List<transaction_model.Transaction>> getTransactionsByWalletId(String walletId) {
    return _firestore
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => transaction_model.Transaction.fromMap({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList();
        });
  }
}

/// Provider untuk stream daftar transaksi berdasarkan wallet
final walletTransactionsProvider = StreamProvider.family<List<transaction_model.Transaction>, String>((ref, walletId) {
  final transactionNotifier = ref.watch(transactionNotifierProvider.notifier);
  return transactionNotifier.getTransactionsByWalletId(walletId);
});
