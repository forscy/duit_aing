import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Model untuk representasi undangan dompet
class WalletInvitation {
  /// Email pengguna yang diundang
  final String email;
  
  /// Status undangan (pending/accepted/rejected)
  final InvitationStatus status;
  
  /// Waktu undangan dibuat
  final Timestamp createdAt;
  
  /// Constructor untuk WalletInvitation
  WalletInvitation({
    required this.email,
    required this.status,
    required this.createdAt,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory WalletInvitation.fromMap(Map<String, dynamic> map) {
    return WalletInvitation(
      email: map['email'] ?? '',
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString() == 'InvitationStatus.${map['status'] ?? 'pending'}',
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: map['createdAt'] != null 
                ? (map['createdAt'] as Timestamp)
                : Timestamp.now(),
    );
  }
  
  /// Konversi objek ke Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
    };
  }
  
  /// Membuat salinan WalletInvitation dengan nilai yang baru
  WalletInvitation copyWith({
    String? email,
    InvitationStatus? status,
    Timestamp? createdAt,
  }) {
    return WalletInvitation(
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model untuk representasi dompet
class WalletModel {
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
  
  /// Daftar undangan yang tertunda untuk dompet ini
  final List<WalletInvitation> invitations;
  
  /// Waktu pembuatan dompet
  final Timestamp createdAt;
  
  /// Constructor untuk WalletModel
  WalletModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.balance,
    required this.visibility,
    required this.sharedWith,
    required this.invitations,
    required this.createdAt,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    // Parse invitations list
    List<WalletInvitation> invitationsList = [];
    if (map['invitations'] != null) {
      invitationsList = List<Map<String, dynamic>>.from(map['invitations'])
        .map((inviteMap) => WalletInvitation.fromMap(inviteMap))
        .toList();
    }
    
    return WalletModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      visibility: WalletVisibility.values.firstWhere(
        (e) => e.toString() == 'WalletVisibility.${map['visibility'] ?? 'private'}',
        orElse: () => WalletVisibility.private,
      ),
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      invitations: invitationsList,
      createdAt: map['createdAt'] != null 
                ? (map['createdAt'] as Timestamp)
                : Timestamp.now(),
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
      'invitations': invitations.map((invitation) => invitation.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
  
  /// Membuat salinan WalletModel dengan nilai yang baru
  WalletModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    double? balance,
    WalletVisibility? visibility,
    List<String>? sharedWith,
    List<WalletInvitation>? invitations,
    Timestamp? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      visibility: visibility ?? this.visibility,
      sharedWith: sharedWith ?? this.sharedWith,
      invitations: invitations ?? this.invitations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Menambahkan undangan baru ke dompet
  WalletModel addInvitation(String email) {
    // Periksa apakah email sudah diundang atau sudah dalam daftar sharedWith
    if (sharedWith.contains(email) || 
        invitations.any((invitation) => invitation.email == email)) {
      return this;  // Tidak ada perubahan jika sudah diundang
    }
    
    // Buat undangan baru
    final newInvitation = WalletInvitation(
      email: email,
      status: InvitationStatus.pending,
      createdAt: Timestamp.now(),
    );
    
    // Tambahkan ke daftar undangan
    final updatedInvitations = List<WalletInvitation>.from(invitations)
      ..add(newInvitation);
    
    // Buat salinan wallet dengan undangan yang diperbarui
    return copyWith(invitations: updatedInvitations);
  }
  
  /// Memperbarui status undangan
  WalletModel updateInvitationStatus(String email, InvitationStatus newStatus) {
    final updatedInvitations = invitations.map((invitation) {
      if (invitation.email == email) {
        return invitation.copyWith(status: newStatus);
      }
      return invitation;
    }).toList();
    
    // Jika undangan diterima, tambahkan email ke daftar sharedWith
    List<String> updatedSharedWith = List<String>.from(sharedWith);
    if (newStatus == InvitationStatus.accepted) {
      if (!updatedSharedWith.contains(email)) {
        updatedSharedWith.add(email);
      }
    }
    
    return copyWith(
      invitations: updatedInvitations,
      sharedWith: updatedSharedWith,
    );
  }
}

/// Shorthand dari Firestore Timestamp untuk model
 