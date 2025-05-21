import 'package:get/get.dart';
import '../models/wallet.dart';
import '../models/enums.dart';
import '../services/wallet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletController extends GetxController {
  final WalletService _walletService = WalletService();
  
  // Observable list untuk dompet pengguna
  final RxList<Wallet> wallets = <Wallet>[].obs;
  
  // Status loading
  final RxBool isLoading = false.obs;
  
  // Selected wallet ID - untuk operasi yang memerlukan dompet terpilih
  final Rx<String?> selectedWalletId = Rx<String?>(null);
  
  // Getter untuk Firebase auth user
  User? get currentUser => FirebaseAuth.instance.currentUser;
  
  // Getter untuk WalletService
  WalletService get walletService => _walletService;
  
  @override
  void onInit() {
    super.onInit();
    setupWalletsStream();
    fetchWallets();
  }
  
  // Menyiapkan stream untuk mendengarkan perubahan pada dompet
  void setupWalletsStream() {
    // Mendengarkan stream dari wallet service
    _walletService.getWalletsStream().listen(
      (List<Wallet> walletsList) {
        wallets.assignAll(walletsList);
      },
      onError: (e) {
        print('Error in wallets stream: $e');
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat memuat daftar dompet',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    );
  }
  
  // Mengambil daftar dompet pengguna dari Firestore secara manual
  Future<void> fetchWallets() async {
    try {
      isLoading.value = true;
      // Tidak perlu implementasi karena sudah menggunakan stream
      // Ini hanya untuk memastikan isLoading diperbarui dan API tetap konsisten
    } catch (e) {
      print('Error fetching wallets: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil daftar dompet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Menambahkan dompet baru
  Future<void> addWallet(String name, double initialBalance, WalletVisibility visibility) async {
    try {
      isLoading.value = true;
      
      await _walletService.createWallet(
        name: name,
        initialBalance: initialBalance,
        visibility: visibility,
      );
      
      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        'Sukses',
        'Dompet baru berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan dompet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
    // Menghitung total saldo dari semua dompet
  double get totalBalance {
    return wallets.fold(0, (sum, wallet) => sum + wallet.balance);
  }
  
  // Mendapatkan jumlah dompet
  int get walletCount => wallets.length;
  
  // Mengundang pengguna ke dompet shared
  Future<void> inviteUserToWallet(String email, String walletId) async {
    try {
      isLoading.value = true;
      await _walletService.inviteUserToWallet(walletId, email);
      
      Get.snackbar(
        'Sukses',
        'Undangan berhasil dikirim ke $email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengundang pengguna: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Menerima undangan dompet
  Future<void> acceptInvitation(String walletId) async {
    try {
      isLoading.value = true;
      await _walletService.acceptWalletInvitation(walletId);
      
      Get.snackbar(
        'Sukses',
        'Undangan dompet diterima',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menerima undangan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Menolak undangan dompet
  Future<void> rejectInvitation(String walletId) async {
    try {
      isLoading.value = true;
      await _walletService.rejectWalletInvitation(walletId);
      
      Get.snackbar(
        'Sukses',
        'Undangan dompet ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menolak undangan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mendapatkan dompet berdasarkan ID
  Wallet? getWalletById(String walletId) {
    return wallets.firstWhereOrNull((wallet) => wallet.id == walletId);
  }
}
