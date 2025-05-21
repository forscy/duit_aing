/// Model untuk data pengguna aplikasi
class AppUser {
  /// Identifier unik untuk pengguna
  final String id;
  
  /// Alamat email pengguna
  final String email;
  
  /// Nama pengguna
  final String? displayName;
  
  /// URL foto profil pengguna
  final String? photoUrl;
  
  /// Waktu pembuatan akun
  final DateTime createdAt;
  
  /// Constructor untuk AppUser
  AppUser({
    required this.id, 
    required this.email, 
    this.displayName, 
    this.photoUrl,
    required this.createdAt,
  });
  
  /// Factory constructor untuk membuat instance dari data Firebase
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null 
                ? (map['createdAt'] as Timestamp).toDate() 
                : DateTime.now(),
    );
  }
  
  /// Konversi objek ke Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
  
  /// Membuat salinan AppUser dengan nilai yang baru
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Firebase Timestamp class (simplified)
class Timestamp {
  final int seconds;
  final int nanoseconds;
  
  Timestamp(this.seconds, this.nanoseconds);
  
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  
  static Timestamp now() {
    final DateTime now = DateTime.now();
    return Timestamp(now.millisecondsSinceEpoch ~/ 1000, 0);
  }
  
  static Timestamp fromDate(DateTime date) {
    return Timestamp(date.millisecondsSinceEpoch ~/ 1000, 0);
  }
}
