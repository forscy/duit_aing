import 'package:get/get.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../services/transaction_service.dart';
import 'wallet_controller.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  final WalletController _walletController = Get.find<WalletController>();
  
  // Observable list untuk transaksi dalam dompet yang dipilih
  final RxList<Transaction> transactions = <Transaction>[].obs;
  
  // Status loading
  final RxBool isLoading = false.obs;
  
  // Filter
  final Rx<TransactionType?> filterType = Rx<TransactionType?>(null);
  
  // Current wallet ID
  final Rx<String?> currentWalletId = Rx<String?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Listen to wallet selection changes
    ever(_walletController.selectedWalletId, (String? walletId) {
      if (walletId != null) {
        loadTransactionsForWallet(walletId);
      }
    });
  }    // Menyiapkan stream untuk mendengarkan perubahan pada transaksi
  void setupTransactionsStream(String walletId) {
    currentWalletId.value = walletId;
    
    // Mendengarkan stream dari transaction service
    _transactionService.getTransactionsStream(walletId).listen(
      (dynamic transactionsList) {
        if (transactionsList is List) {
          final typedList = List<Transaction>.from(transactionsList);
          transactions.assignAll(typedList);
        }
      },
      onError: (e) {
        print('Error in transactions stream: $e');
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat memuat daftar transaksi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    );
  }
  
  // Memuat transaksi untuk dompet tertentu
  void loadTransactionsForWallet(String walletId) {
    setupTransactionsStream(walletId);
  }
  
  // Menambahkan transaksi baru
  Future<void> addTransaction({
    required String walletId,
    required double amount,
    required String description,
    required TransactionType type,
    String? destinationWalletId,
  }) async {
    try {
      isLoading.value = true;
      
      await _transactionService.createTransaction(
        walletId: walletId,
        amount: amount,
        description: description,
        type: type,
        destinationWalletId: destinationWalletId,
      );
      
      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        'Sukses',
        'Transaksi berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan transaksi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Menghapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    try {
      isLoading.value = true;
      
      await _transactionService.deleteTransaction(transactionId);
      
      Get.snackbar(
        'Sukses',
        'Transaksi berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus transaksi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mendapatkan transaksi berdasarkan filter tipe
  List<Transaction> get filteredTransactions {
    if (filterType.value == null) {
      return transactions;
    }
    
    return transactions.where((t) => t.type == filterType.value).toList();
  }
  
  // Filter transaksi berdasarkan tipe
  void setFilter(TransactionType? type) {
    filterType.value = type;
  }
  
  // Reset filter
  void resetFilter() {
    filterType.value = null;
  }
  
  // Mendapatkan jumlah pemasukan pada periode tertentu (bisa diperluas)
  double get totalIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }
  
  // Mendapatkan jumlah pengeluaran pada periode tertentu
  double get totalExpense {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }
  
  // Mendapatkan jumlah transfer keluar
  double get totalTransferOut {
    return transactions
        .where((t) => t.type == TransactionType.transfer)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }
}
