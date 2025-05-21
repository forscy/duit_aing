import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../models/wallet.dart';
import 'wallet_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletService _walletService = WalletService();

  // Mendapatkan collection reference untuk transactions
  CollectionReference get _transactionsRef => _firestore.collection('transactions');

  // Mendapatkan stream transaksi untuk dompet tertentu
  Stream<List<Transaction>> getTransactionsStream(String walletId) {
    return _transactionsRef
        .where('walletId', isEqualTo: walletId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Transaction.fromMap(data);
          }).toList());
  }

  // Mendapatkan transaksi berdasarkan ID
  Future<Transaction?> getTransactionById(String transactionId) async {
    try {
      final docSnapshot = await _transactionsRef.doc(transactionId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Transaction.fromMap(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting transaction by ID: $e');
      return null;
    }
  }

  // Membuat transaksi baru
  Future<String> createTransaction({
    required String walletId,
    required double amount,
    required String description,
    required TransactionType type,
    String? destinationWalletId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    
    // Validasi jumlah transaksi
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    
    // Validasi transfer
    if (type == TransactionType.transfer) {
      if (destinationWalletId == null) {
        throw Exception('Destination wallet is required for transfers');
      }
      if (destinationWalletId == walletId) {
        throw Exception('Cannot transfer to the same wallet');
      }
    }
    
    // Mulai transaction batch untuk atomic operation
    final batch = _firestore.batch();
    
    try {
      // 1. Dapatkan dompet sumber
      final sourceWallet = await _walletService.getWalletById(walletId);
      if (sourceWallet == null) {
        throw Exception('Source wallet not found');
      }
      
      // 2. Perbarui saldo dompet sumber
      double updatedSourceBalance = sourceWallet.balance;
      
      switch (type) {
        case TransactionType.income:
          updatedSourceBalance += amount;
          break;
        case TransactionType.expense:
        case TransactionType.transfer:
          // Cek saldo cukup
          if (sourceWallet.balance < amount) {
            throw Exception('Insufficient balance');
          }
          updatedSourceBalance -= amount;
          break;
      }
      
      // Update saldo dompet sumber
      batch.update(_firestore.collection('wallets').doc(walletId), {
        'balance': updatedSourceBalance
      });
      
      // 3. Jika transfer, update juga saldo dompet tujuan
      if (type == TransactionType.transfer && destinationWalletId != null) {
        final destWallet = await _walletService.getWalletById(destinationWalletId);
        if (destWallet == null) {
          throw Exception('Destination wallet not found');
        }
        
        // Update saldo dompet tujuan
        batch.update(_firestore.collection('wallets').doc(destinationWalletId), {
          'balance': destWallet.balance + amount
        });
      }
      
      // 4. Buat dokumen transaksi baru
      final transactionData = {
        'walletId': walletId,
        'amount': amount,
        'description': description,
        'type': type.toString().split('.').last,
        'destinationWalletId': type == TransactionType.transfer ? destinationWalletId : null,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      final newTransactionRef = _transactionsRef.doc();
      batch.set(newTransactionRef, transactionData);
      
      // 5. Commit batch update
      await batch.commit();
      
      return newTransactionRef.id;
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Menghapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // 1. Dapatkan transaksi
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }
      
      // 2. Dapatkan wallet yang terkait
      final sourceWallet = await _walletService.getWalletById(transaction.walletId);
      if (sourceWallet == null) {
        throw Exception('Source wallet not found');
      }
      
      // Check access rights
      if (sourceWallet.ownerId != user.uid && !sourceWallet.sharedWith.contains(user.email)) {
        throw Exception('You don\'t have permission to delete this transaction');
      }
      
      // Mulai transaction batch untuk atomic operation
      final batch = _firestore.batch();
      
      // 3. Kembalikan saldo wallet ke kondisi sebelumnya
      double updatedSourceBalance = sourceWallet.balance;
      
      switch (transaction.type) {
        case TransactionType.income:
          updatedSourceBalance -= transaction.amount;
          break;
        case TransactionType.expense:
        case TransactionType.transfer:
          updatedSourceBalance += transaction.amount;
          break;
      }
      
      // Update saldo dompet sumber
      batch.update(_firestore.collection('wallets').doc(transaction.walletId), {
        'balance': updatedSourceBalance
      });
      
      // 4. Jika transfer, kembalikan juga saldo dompet tujuan
      if (transaction.type == TransactionType.transfer && transaction.destinationWalletId != null) {
        final destWallet = await _walletService.getWalletById(transaction.destinationWalletId!);
        if (destWallet != null) {
          // Update saldo dompet tujuan
          batch.update(_firestore.collection('wallets').doc(transaction.destinationWalletId!), {
            'balance': destWallet.balance - transaction.amount
          });
        }
      }
      
      // 5. Hapus transaksi
      batch.delete(_transactionsRef.doc(transactionId));
      
      // 6. Commit batch update
      await batch.commit();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
