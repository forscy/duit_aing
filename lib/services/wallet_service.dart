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
  Stream<List<Wallet>> getWallets() {
    // Using standard Stream transformation
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(<Wallet>[]);
    }
    
    return _firestore
        .collection('wallets')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Wallet.fromMap({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList();
        });
  }
  
  /// Mendapatkan detail dompet berdasarkan ID
  Future<Wallet?> getWalletById(String walletId) async {
    final doc = await _firestore.collection('wallets').doc(walletId).get();
    if (!doc.exists) {
      return null;
    }
    return Wallet.fromMap({'id': doc.id, ...doc.data()!});
  }

  /// Membuat dompet baru
  Future<Wallet> createWallet(String name, WalletVisibility visibility) async {
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
    final newWallet = Wallet.fromMap({'id': docRef.id, ...walletData});
    return newWallet;
  }

  /// Mengupdate informasi dompet
  Future<void> updateWallet(Wallet wallet) async {
    await _firestore
        .collection('wallets')
        .doc(wallet.id)
        .update(wallet.toMap());
  }

  /// Menghapus dompet
  Future<void> deleteWallet(String walletId) async {
    await _firestore.collection('wallets').doc(walletId).delete();
  }

  /// Mengirim undangan untuk berbagi dompet
  Future<void> inviteToWallet(String walletId, String email) async {
    final walletDoc = await _firestore.collection('wallets').doc(walletId).get();
    if (!walletDoc.exists) {
      throw Exception('Dompet tidak ditemukan');
    }

    Wallet wallet = Wallet.fromMap({'id': walletDoc.id, ...walletDoc.data()!});
    
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

    Wallet wallet = Wallet.fromMap({'id': walletDoc.id, ...walletDoc.data()!});
    
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
            final wallet = Wallet.fromMap({'id': doc.id, ...doc.data()});
            
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
}
