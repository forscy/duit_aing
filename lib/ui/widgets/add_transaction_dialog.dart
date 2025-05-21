import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/enums.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/wallet_controller.dart';

class AddTransactionDialog extends StatefulWidget {
  final String walletId;

  const AddTransactionDialog({
    super.key,
    required this.walletId,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TransactionController _transactionController = Get.find<TransactionController>();
  final WalletController _walletController = Get.find<WalletController>();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  String? _destinationWalletId;
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the current wallet
    final currentWallet = _walletController.getWalletById(widget.walletId);
    
    // Get other wallets for transfer options
    final otherWallets = _walletController.wallets
      .where((wallet) => wallet.id != widget.walletId)
      .toList();
      
    bool showTransferOptions = _selectedType == TransactionType.transfer;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Show currently selected wallet
              if (currentWallet != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Dompet: ${currentWallet.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 16),
              
              // Transaction type selector
              Text(
                'Jenis Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeOption(
                      type: TransactionType.expense,
                      label: 'Pengeluaran',
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    _buildTypeOption(
                      type: TransactionType.income,
                      label: 'Pemasukan',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    _buildTypeOption(
                      type: TransactionType.transfer,
                      label: 'Transfer',
                      icon: Icons.swap_horiz,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Amount input field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Jumlah harus berupa angka positif';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Description input field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              // Transfer options
              if (showTransferOptions) ...[
                SizedBox(height: 16),
                
                Text(
                  'Dompet Tujuan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 8),
                
                if (otherWallets.isEmpty)
                  Text(
                    'Tidak ada dompet lain untuk tujuan transfer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _destinationWalletId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Pilih dompet tujuan',
                    ),
                    items: otherWallets.map((wallet) {
                      return DropdownMenuItem<String>(
                        value: wallet.id,
                        child: Text(wallet.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _destinationWalletId = newValue;
                      });
                    },
                    validator: (value) {
                      if (_selectedType == TransactionType.transfer && (value == null || value.isEmpty)) {
                        return 'Pilih dompet tujuan';
                      }
                      return null;
                    },
                  ),
              ],
              
              SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Batal'),
                  ),
                  SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                    onPressed: _transactionController.isLoading.value
                        ? null
                        : _submitTransaction,
                    child: _transactionController.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Simpan'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypeOption({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    bool isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Reset destination wallet if not transfer
          if (type != TransactionType.transfer) {
            _destinationWalletId = null;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha:  0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha:  0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text);
      final String description = _descriptionController.text;
      
      _transactionController.addTransaction(
        walletId: widget.walletId,
        amount: amount,
        description: description,
        type: _selectedType,
        destinationWalletId: _selectedType == TransactionType.transfer ? _destinationWalletId : null,
      );
    }
  }
}
