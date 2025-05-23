import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/wallet.dart';

/// Service untuk mengatur operasi CRUD pada dompet
class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
    /// Method untuk membersihkan state jika diperlukan
  void clearState() {
    // If we need to clear any cached data or state when a user logs out
    // For example, we might want to discard any in-memory wallet data
    debugPrint('WalletService: Clearing state after logout');
    
    // In a more complex implementation, we might have:
    // _cachedWallets.clear();
    // _pendingTransactions.clear();
    // etc.
  }/// Mendapatkan daftar dompet yang dimiliki atau dibagikan ke pengguna
  Stream<List<WalletModel>> getWallets() {
    // Using standard Stream transformation
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(<WalletModel>[]);
    }
    
    return _firestore
        .collection('wallets')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WalletModel.fromMap({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList();
        });
  }
    /// Mendapatkan detail dompet berdasarkan ID
  Future<WalletModel?> getWalletById(String walletId) async {
    final doc = await _firestore.collection('wallets').doc(walletId).get();
    if (!doc.exists) {
      return null;
    }
    return WalletModel.fromMap({'id': doc.id, ...doc.data()!});
  }
  
  /// Mendapatkan stream data wallet untuk memantau perubahan secara reaktif
  Stream<WalletModel?> watchWalletById(String walletId) {
    return _firestore
        .collection('wallets')
        .doc(walletId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return null;
          }
          return WalletModel.fromMap({'id': doc.id, ...doc.data()!});
        });
  }

  /// Membuat dompet baru
  Future<WalletModel> createWallet(String name, WalletVisibility visibility) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User tidak terautentikasi');
    }

    final walletData = {
      'ownerId': user.uid,
      'name': name,
      'balance': 0.0,
      'visibility': visibility.toString().split('.').last,
      'sharedWith': visibility == WalletVisibility.private ? [] : [user.email],
      'invitations': [],
      'createdAt': Timestamp.now(),
    };

    final docRef = await _firestore.collection('wallets').add(walletData);
    
    // Ambil ID dokumen yang baru dibuat dan tambahkan ke data
    final newWallet = WalletModel.fromMap({'id': docRef.id, ...walletData});
    return newWallet;
  }

  /// Mengupdate informasi dompet
  Future<void> updateWallet(WalletModel wallet) async {
    await _firestore
        .collection('wallets')
        .doc(wallet.id)
        .update(wallet.toMap());
  }  /// Menghapus dompet
  Future<void> deleteWallet(String walletId) async {
    try {
      // 1. Hapus transaksi transfer terkait dari dompet lain terlebih dahulu
      await _deleteRelatedTransfers(walletId);
      
      // 2. Dapatkan referensi dompet
      final walletRef = _firestore.collection('wallets').doc(walletId);
      
      // 3. Dapatkan semua transaksi dari dompet
      final transactionsSnapshot = await walletRef.collection('transactions').get();
      
      // 4. Hapus semua transaksi satu per satu
      final batch = _firestore.batch();
      for (var doc in transactionsSnapshot.docs) {
        batch.delete(walletRef.collection('transactions').doc(doc.id));
      }
      
      // 5. Hapus dokumen dompet
      batch.delete(walletRef);
      
      // 6. Commit batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error menghapus dompet: ${e.toString()}');
      throw Exception('Gagal menghapus dompet: ${e.toString()}');
    }
  }

  /// Mengirim undangan untuk berbagi dompet
  Future<void> inviteToWallet(String walletId, String email) async {
    final walletDoc = await _firestore.collection('wallets').doc(walletId).get();
    if (!walletDoc.exists) {
      throw Exception('Dompet tidak ditemukan');
    }

    WalletModel wallet = WalletModel.fromMap({'id': walletDoc.id, ...walletDoc.data()!});
    
    // Tambahkan undangan ke wallet
    wallet = wallet.addInvitation(email);
    
    // Update wallet di Firestore
    await _firestore
        .collection('wallets')
        .doc(walletId)
        .update(wallet.toMap());
  }

  /// Menanggapi undangan dompet
  Future<void> respondToInvitation(
    String walletId, 
    String email, 
    InvitationStatus response
  ) async {
    final walletDoc = await _firestore.collection('wallets').doc(walletId).get();
    if (!walletDoc.exists) {
      throw Exception('Dompet tidak ditemukan');
    }

    WalletModel wallet = WalletModel.fromMap({'id': walletDoc.id, ...walletDoc.data()!});
    
    // Update status undangan
    wallet = wallet.updateInvitationStatus(email, response);
    
    // Update wallet di Firestore
    await _firestore
        .collection('wallets')
        .doc(walletId)
        .update(wallet.toMap());
  }  /// Mendapatkan undangan dompet untuk user saat ini
  Stream<List<Map<String, dynamic>>> getWalletInvitations() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Stream.value([]);
    }

    // Karena tidak bisa melakukan query langsung pada array of objects dengan kondisi tertentu
    // Kita perlu mengambil semua wallet dan memfilternya di client side
    return _firestore
        .collection('wallets')
        .snapshots()
        .map((snapshot) {
          List<Map<String, dynamic>> result = [];
          
          // Get current user again to ensure we're using the most up-to-date user
          final currentUser = _auth.currentUser;
          if (currentUser == null || currentUser.email == null) {
            return [];
          }
          
          for (var doc in snapshot.docs) {
            final wallet = WalletModel.fromMap({'id': doc.id, ...doc.data()});
            
            // Cari undangan yang sesuai dengan email user dan statusnya pending
            final matchingInvitations = wallet.invitations.where(
              (inv) => inv.email == currentUser.email && inv.status == InvitationStatus.pending
            ).toList();
            
            if (matchingInvitations.isNotEmpty) {
              result.add({
                'wallet': wallet,
                'invitation': matchingInvitations.first,
              });
            }
          }
          
          return result;
        });
  }
  
  /// Fungsi bantuan untuk menghapus transaksi transfer terkait dari dompet lain
  Future<void> _deleteRelatedTransfers(String walletId) async {
    try {
      // Dapatkan semua transfer yang terkait dengan dompet ini
      final transfersToWallet = await _firestore
          .collectionGroup('transactions')
          .where('destinationWalletId', isEqualTo: walletId)
          .where('type', isEqualTo: 'transfer')
          .get();
      
      // Hapus atau tandai transfer ini sebagai tidak valid
      final batch = _firestore.batch();
      for (var doc in transfersToWallet.docs) {
        // Dapatkan path lengkap ke dokumen
        final documentPath = doc.reference.path;
        batch.delete(_firestore.doc(documentPath));
      }
      
      if (transfersToWallet.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error menghapus transfer terkait: ${e.toString()}');
      // Kita tetap lanjutkan meski ada error pada bagian ini
    }
  }
}
