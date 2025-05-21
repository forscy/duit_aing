import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/enums.dart';

class AddWalletButton extends StatelessWidget {
  const AddWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddWalletDialog(context),
      backgroundColor: Color(0xFFFF6B6B),
      child: Icon(Icons.add),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
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
  }
}
