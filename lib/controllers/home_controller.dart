import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart' as model;

class HomeController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Status loading
  final RxBool isLoading = false.obs;
  
  // User data observable
  final Rx<User?> user = Rx<User?>(null);
  
  // App User data (extended user data dari Firestore)
  final Rx<model.AppUser?> appUser = Rx<model.AppUser?>(null);
  
  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authService.authStateChanges);
    ever(user, _updateAppUser); // Listen untuk perubahan user
  }
  
  // Update AppUser saat Firebase User berubah
  void _updateAppUser(User? firebaseUser) async {
    if (firebaseUser != null) {
      // Ambil data AppUser dari Firestore
      appUser.value = await _authService.getUserData();
    } else {
      appUser.value = null;
    }
  }
  
  // Mendapatkan nama pengguna yang sedang login
  String get userName {
    // Prioritaskan data dari AppUser, jika tidak ada gunakan data dari Firebase User
    if (appUser.value?.displayName != null) {
      return appUser.value!.displayName!;
    } else if (user.value?.displayName != null) {
      return user.value!.displayName!;
    } else if (user.value?.email != null) {
      return user.value!.email!.split('@')[0];
    }
    return 'User';
  }
  
  // Logout
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login'); // Arahkan ke halaman login
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal keluar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update profil pengguna
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      
      // Refresh AppUser data
      appUser.value = await _authService.getUserData();
      
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
