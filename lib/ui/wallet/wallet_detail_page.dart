import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/wallet.dart';
import '../../models/enums.dart';
import '../widgets/wallet_summary.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_transaction_state.dart';
import '../widgets/add_transaction_dialog.dart';

class WalletDetailPage extends StatelessWidget {
  final String walletId;
  const WalletDetailPage({super.key, required this.walletId});
  @override  Widget build(BuildContext context) {
    // Get controllers
    final walletController = Get.find<WalletController>();
    final transactionController = Get.find<TransactionController>();
    
    // Initialize transaction controller with the current wallet ID
    transactionController.loadTransactionsForWallet(walletId);
    
    // Set selected wallet in wallet controller
    walletController.selectedWalletId.value = walletId;
    
    // Use the walletController to get the wallet by ID
    final wallet = walletController.getWalletById(walletId);

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Dompet tidak ditemukan')),
        body: Center(child: Text('Dompet dengan ID tersebut tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          wallet.name,
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showWalletOptions(context, wallet);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reload transactions
          transactionController.loadTransactionsForWallet(walletId);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet summary
              WalletSummary(wallet: wallet),
              
              SizedBox(height: 8),
              
              // Filter chips
              TransactionFilterChips(),
              
              // Transactions label
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Filter button (future implementation)
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        // TODO: Implement advanced filtering
                      },
                    ),
                  ],
                ),
              ),
              
              // Transactions list
              Obx(() {
                if (transactionController.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (transactionController.transactions.isEmpty) {
                  return EmptyTransactionState(
                    onAddTransaction: () => _showAddTransactionDialog(context, walletId),
                  );
                } else {
                  final filteredTransactions = transactionController.filteredTransactions;
                  
                  if (filteredTransactions.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Tidak ada transaksi yang sesuai dengan filter',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          // Future: implement transaction detail
                        },
                        onDelete: () {
                          transactionController.deleteTransaction(transaction.id);
                        },
                      );
                    },
                  );
                }
              }),
              
              SizedBox(height: 80), // Ruang untuk FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context, walletId);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _showAddTransactionDialog(BuildContext context, String walletId) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(walletId: walletId),
    );
  }
  
  void _showWalletOptions(BuildContext context, Wallet wallet) {
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Dompet'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWalletDialog(context, wallet);
                },
              ),
              if (wallet.visibility == WalletVisibility.shared)
                ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Undang Pengguna'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInviteUserDialog(context, wallet.id);
                  },
                ),
              if (wallet.ownerId == Get.find<WalletController>().currentUser?.uid)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus Dompet', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, wallet.id);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _showEditWalletDialog(BuildContext context, Wallet wallet) {
    final walletController = Get.find<WalletController>();
    final nameController = TextEditingController(text: wallet.name);
    final visibilityType = wallet.visibility.obs;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Dompet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Dompet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Visibilitas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  _buildVisibilityOption(
                    context: context,
                    type: WalletVisibility.private,
                    label: 'Privat',
                    description: 'Hanya kamu yang bisa mengakses',
                    icon: Icons.lock,
                    groupValue: visibilityType.value,
                    onChanged: (value) => visibilityType.value = value!,
                  ),
                  SizedBox(width: 8),
                  _buildVisibilityOption(
                    context: context,
                    type: WalletVisibility.shared,
                    label: 'Dibagikan',
                    description: 'Bisa dibagikan dengan pengguna lain',
                    icon: Icons.people,
                    groupValue: visibilityType.value,
                    onChanged: (value) => visibilityType.value = value!,
                  ),
                ],
              )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Update wallet
                      walletController.walletService.updateWallet(
                        walletId: wallet.id,
                        name: nameController.text,
                        visibility: visibilityType.value,
                      );
                    },
                    child: Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVisibilityOption({
    required BuildContext context,
    required WalletVisibility type,
    required String label,
    required String description,
    required IconData icon,
    required WalletVisibility groupValue,
    required Function(WalletVisibility?) onChanged,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: type == groupValue 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: type == groupValue 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: type == groupValue 
                    ? Theme.of(context).primaryColor 
                    : Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showInviteUserDialog(BuildContext context, String walletId) {
    final walletController = Get.find<WalletController>();
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Undang Pengguna',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Masukkan email pengguna yang ingin diundang',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                    onPressed: walletController.isLoading.value
                        ? null
                        : () {
                            Navigator.pop(context);
                            if (emailController.text.isNotEmpty) {
                              walletController.inviteUserToWallet(
                                emailController.text,
                                walletId,
                              );
                            }
                          },
                    child: walletController.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Undang'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, String walletId) {
    final walletController = Get.find<WalletController>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Dompet'),
        content: Text('Yakin ingin menghapus dompet ini? Semua data transaksi akan hilang dan tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              walletController.walletService.deleteWallet(walletId).then((_) {
                Get.back(); // Kembali ke halaman utama
                Get.snackbar(
                  'Sukses',
                  'Dompet berhasil dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }).catchError((error) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus dompet: ${error.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              });
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
