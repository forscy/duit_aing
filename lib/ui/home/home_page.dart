import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/enums.dart';
import '../widgets/financial_summary.dart';
import '../widgets/wallet_card.dart';
import '../widgets/add_wallet_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final WalletController walletController = Get.put(WalletController());

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8), // Latar belakang abu-abu terang
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duit Aing',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                'Hai, ${homeController.userName}',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              // Menampilkan menu profil
              _showProfileMenu(context, homeController);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => walletController.fetchWallets(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan keuangan
              FinancialSummary(),
              
              SizedBox(height: 16),
              
              // Label untuk dompet
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dompet Saya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implementasi lihat semua dompet
                      },
                      child: Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),
              
              // Daftar dompet
              Obx(
                () {
                  if (walletController.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (walletController.wallets.isEmpty) {
                    return _buildEmptyWalletState(context);
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: walletController.wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = walletController.wallets[index];
                        return WalletCard(
                          wallet: wallet,
                          onTap: () {
                            // TODO: Navigate to wallet detail
                            Get.toNamed('/wallet/${wallet.id}', arguments: wallet);
                          },
                        );
                      },
                    );
                  }
                },
              ),
              
              SizedBox(height: 80), // Ruang untuk FAB
            ],
          ),
        ),
      ),
      floatingActionButton: AddWalletButton(),
    );
  }
  Widget _buildEmptyWalletState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/6134/6134346.png',
            height: 120,
          ),
          SizedBox(height: 16),
          Text(
            'Belum Ada Dompet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Buat dompet baru untuk mulai mengelola keuanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Tampilkan dialog tambah dompet
              final walletController = Get.find<WalletController>();
              final TextEditingController nameController = TextEditingController();
              final TextEditingController balanceController = TextEditingController();
              final visibilityType = WalletVisibility.private.obs;

              Get.dialog(
                Dialog(
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
                          'Tambah Dompet Baru',
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
                        TextField(
                          controller: balanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Saldo Awal',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tipe Dompet:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Column(
                            children: [
                              RadioListTile<WalletVisibility>(
                                title: Text('Pribadi'),
                                subtitle: Text('Hanya kamu yang dapat mengakses'),
                                value: WalletVisibility.private,
                                groupValue: visibilityType.value,
                                onChanged: (value) => visibilityType.value = value!,
                              ),
                              RadioListTile<WalletVisibility>(
                                title: Text('Bersama'),
                                subtitle: Text('Bisa diakses oleh pengguna lain yang kamu undang'),
                                value: WalletVisibility.shared,
                                groupValue: visibilityType.value,
                                onChanged: (value) => visibilityType.value = value!,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Batal'),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (nameController.text.isEmpty || balanceController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Semua field harus diisi',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                final double initialBalance;
                                try {
                                  initialBalance = double.parse(balanceController.text.replaceAll('.', ''));
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Saldo harus berupa angka',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                // Tambah wallet baru
                                walletController.addWallet(
                                  nameController.text.trim(),
                                  initialBalance,
                                  visibilityType.value,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Simpan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Tambah Dompet'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profil Saya'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigasi ke halaman profil
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigasi ke halaman pengaturan
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Keluar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  controller.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
