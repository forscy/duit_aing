import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/enums.dart';

class AddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onAddWallet;
  final VoidCallback onAddTransaction;

  const AddOptionsBottomSheet({
    super.key,
    required this.onAddWallet,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor),
            title: Text('Add New Wallet'),
            onTap: () {
              Navigator.pop(context);
              onAddWallet();
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
            title: Text('Add New Transaction'),
            onTap: () {
              Navigator.pop(context);
              onAddTransaction();
            },
          ),
        ],
      ),
    );
  }
}

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({super.key});

  @override
  State<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends State<AddWalletDialog> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  WalletVisibility visibility = WalletVisibility.private;

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Wallet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Wallet Name',
                    hintText: 'Enter wallet name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: balanceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: 'Enter initial balance',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 15),
                Text(
                  'Visibility:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<WalletVisibility>(
                        title: Text('Private'),
                        subtitle: Text('Only you can access'),
                        value: WalletVisibility.private,
                        groupValue: visibility,
                        onChanged: (value) => setState(() => visibility = value!),
                      ),
                      Divider(height: 1),
                      RadioListTile<WalletVisibility>(
                        title: Text('Shared'),
                        subtitle: Text('Can be shared with others'),
                        value: WalletVisibility.shared,
                        groupValue: visibility,
                        onChanged: (value) => setState(() => visibility = value!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate input
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter a wallet name',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(alpha: 0.7),
                              colorText: Colors.white,
                            );
                            return;
                          }
                          
                          final balance = double.tryParse(balanceController.text.replaceAll(',', '.'));
                          if (balance == null) {
                            Get.snackbar(
                              'Error',
                              'Please enter a valid balance',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(alpha: 0.7),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // Add wallet
                          final controller = Get.find<WalletController>();
                          controller.addWallet(
                            nameController.text.trim(),
                            balance,
                            visibility,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
