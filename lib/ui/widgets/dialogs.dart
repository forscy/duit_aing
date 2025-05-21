import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/enums.dart';

class AddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onAddWallet;
  final VoidCallback onAddTransaction;

  const AddOptionsBottomSheet({
    Key? key,
    required this.onAddWallet,
    required this.onAddTransaction,
  }) : super(key: key);

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
  const AddWalletDialog({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Wallet Name'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Initial Balance'),
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visibility:'),
                Row(
                  children: [
                    Radio<WalletVisibility>(
                      value: WalletVisibility.private,
                      groupValue: visibility,
                      onChanged: (value) {
                        setState(() => visibility = value!);
                      },
                    ),
                    Text('Private'),
                    Radio<WalletVisibility>(
                      value: WalletVisibility.shared,
                      groupValue: visibility,
                      onChanged: (value) {
                        setState(() => visibility = value!);
                      },
                    ),
                    Text('Shared'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && balanceController.text.isNotEmpty) {
                      final controller = Get.find<WalletController>();
                      controller.addWallet(
                        nameController.text,
                        double.tryParse(balanceController.text) ?? 0,
                        visibility,
                      );
                      Get.back();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
