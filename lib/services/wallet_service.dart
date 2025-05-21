import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import '../models/wallet.dart';
import '../models/enums.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan collection reference untuk wallets
  CollectionReference get _walletsRef => _firestore.collection('wallets');

  // Mendapatkan stream dompet milik user
  Stream<List<Wallet>> getWalletsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    // Query dompet yang dimiliki oleh pengguna
    final ownedWalletsQuery = _walletsRef
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Wallet.fromMap(data);
          }).toList());

    // Query dompet yang dibagikan kepada pengguna
    final sharedWalletsQuery = _walletsRef
        .where('sharedWith', arrayContains: user.email)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Wallet.fromMap(data);
          }).toList());    // Gabungkan kedua stream
    return rxdart.Rx.combineLatest2(
      ownedWalletsQuery, 
      sharedWalletsQuery, 
      (List<Wallet> owned, List<Wallet> shared) {
        // Filter untuk menghilangkan dompet duplikat jika ada
        final allWallets = [...owned];
        
        // Tambahkan dompet shared yang belum ada di owned
        for (final sharedWallet in shared) {
          if (!allWallets.any((w) => w.id == sharedWallet.id)) {
            allWallets.add(sharedWallet);
          }
        }
        
        return allWallets;
      }
    );
  }

  // Mendapatkan dompet berdasarkan ID
  Future<Wallet?> getWalletById(String walletId) async {
    try {
      final docSnapshot = await _walletsRef.doc(walletId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Wallet.fromMap(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting wallet by ID: $e');
      return null;
    }
  }

  // Membuat dompet baru
  Future<String> createWallet({
    required String name,
    required double initialBalance,
    required WalletVisibility visibility,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    
    try {
      final walletData = {
        'name': name,
        'balance': initialBalance,
        'ownerId': user.uid,
        'visibility': visibility.toString().split('.').last,
        'sharedWith': [user.email], // Pemilik otomatis memiliki akses
        'invitations': [], // Awalnya belum ada undangan
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _walletsRef.add(walletData);
      return docRef.id;
    } catch (e) {
      print('Error creating wallet: $e');
      rethrow;
    }
  }

  // Mengirim undangan untuk akses dompet shared
  Future<void> inviteUserToWallet(String walletId, String targetEmail) async {
    try {
      final wallet = await getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }
      
      // Pastikan pengguna adalah pemilik dompet
      if (wallet.ownerId != _auth.currentUser?.uid) {
        throw Exception('Only wallet owner can invite others');
      }
      
      // Pastikan dompet adalah tipe shared
      if (wallet.visibility != WalletVisibility.shared) {
        throw Exception('Only shared wallets can have invitations');
      }
      
      // Tambahkan undangan baru
      final updatedWallet = wallet.addInvitation(targetEmail);
      
      // Perbarui di Firestore
      await _walletsRef.doc(walletId).update({
        'invitations': updatedWallet.invitations.map((i) => i.toMap()).toList()
      });
    } catch (e) {
      print('Error inviting user to wallet: $e');
      rethrow;
    }
  }

  // Menerima undangan dompet
  Future<void> acceptWalletInvitation(String walletId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final wallet = await getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Pastikan pengguna memiliki undangan ke dompet ini
      final hasInvitation = wallet.invitations.any(
        (invitation) => 
          invitation.email == user.email && 
          invitation.status == InvitationStatus.pending
      );

      if (!hasInvitation) {
        throw Exception('No pending invitation found for this user');
      }

      // Perbarui status undangan
      final updatedWallet = wallet.updateInvitationStatus(
        user.email!, 
        InvitationStatus.accepted
      );

      // Perbarui di Firestore
      await _walletsRef.doc(walletId).update({
        'invitations': updatedWallet.invitations.map((i) => i.toMap()).toList(),
        'sharedWith': updatedWallet.sharedWith,
      });
    } catch (e) {
      print('Error accepting wallet invitation: $e');
      rethrow;
    }
  }
  // Menolak undangan dompet
  Future<void> rejectWalletInvitation(String walletId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final wallet = await getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Perbarui status undangan
      final updatedWallet = wallet.updateInvitationStatus(
        user.email!, 
        InvitationStatus.rejected
      );

      // Perbarui di Firestore
      await _walletsRef.doc(walletId).update({
        'invitations': updatedWallet.invitations.map((i) => i.toMap()).toList(),
      });
    } catch (e) {
      print('Error rejecting wallet invitation: $e');
      rethrow;
    }
  }

  // Mengupdate dompet
  Future<void> updateWallet({
    required String walletId, 
    String? name,
    WalletVisibility? visibility,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final wallet = await getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Pastikan pengguna adalah pemilik dompet
      if (wallet.ownerId != user.uid) {
        throw Exception('Only wallet owner can update wallet properties');
      }

      final Map<String, dynamic> updates = {};
      
      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }
      
      if (visibility != null) {
        updates['visibility'] = visibility.toString().split('.').last;
      }

      if (updates.isNotEmpty) {
        await _walletsRef.doc(walletId).update(updates);
      }
    } catch (e) {
      print('Error updating wallet: $e');
      rethrow;
    }
  }

  // Menghapus dompet
  Future<void> deleteWallet(String walletId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final wallet = await getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Pastikan pengguna adalah pemilik dompet
      if (wallet.ownerId != user.uid) {
        throw Exception('Only wallet owner can delete wallet');
      }

      // Hapus dompet dari Firestore
      await _walletsRef.doc(walletId).delete();
    } catch (e) {
      print('Error deleting wallet: $e');
      rethrow;
    }
  }
}
