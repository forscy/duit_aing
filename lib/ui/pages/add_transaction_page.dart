import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart' as model;
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/transaction_provider.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:duit_aing/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

/// Halaman untuk menambahkan transaksi
class AddTransactionPage extends ConsumerStatefulWidget {
  final String walletId;
  final TransactionType? initialType;

  const AddTransactionPage({
    Key? key,
    required this.walletId,
    this.initialType,
  }) : super(key: key);

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late TransactionType _selectedType;
  String? _destinationWalletId;
    @override
  void initState() {
    super.initState();
    // Initialize with provided type or default to expense
    _selectedType = widget.initialType ?? TransactionType.expense;
    
    // Add listener to validate amount as user types
    _amountController.addListener(_validateAmount);
  }
  
  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // Warning message state
  String? _amountWarning;
  
  void _validateAmount() {
    if (_amountController.text.isEmpty) {
      setState(() {
        _amountWarning = null;
      });
      return;
    }
    
    // Only validate for expense and transfer
    if (_selectedType != TransactionType.expense && _selectedType != TransactionType.transfer) {
      setState(() {
        _amountWarning = null;
      });
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _amountWarning = null;
      });
      return;
    }
    
    // Get wallet data
    final walletAsync = ref.read(selectedWalletProvider(widget.walletId));
    walletAsync.whenData((wallet) {
      if (wallet != null && amount > wallet.balance) {
        setState(() {
          _amountWarning = 'Jumlah melebihi saldo yang tersedia';
        });
      } else {
        setState(() {
          _amountWarning = null;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(selectedWalletProvider(widget.walletId));
    final walletsAsync = ref.watch(walletListProvider);
    
    // Daftar wallet lain untuk transfer
    final otherWallets = walletsAsync.when(
      data: (wallets) => wallets.where((w) => w.id != widget.walletId).toList(),
      loading: () => <WalletModel>[],
      error: (_, __) => <WalletModel>[],
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
      ),
      body: walletAsync.when(
        data: (wallet) {
          if (wallet == null) {
            return const Center(
              child: Text('Dompet tidak ditemukan'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletInfo(wallet),
                  const SizedBox(height: 24),
                  _buildTransactionTypeSelector(),
                  const SizedBox(height: 24),
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  if (_selectedType == TransactionType.transfer)
                    _buildDestinationWalletSelector(otherWallets),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildWalletInfo(WalletModel wallet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dompet:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              wallet.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saldo: ${CurrencyFormatter.format(wallet.balance)}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Transaksi:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TransactionType>(
          segments: const [
            ButtonSegment<TransactionType>(
              value: TransactionType.income,
              label: Text('Pemasukan'),
              icon: Icon(Icons.add_circle),
            ),
            ButtonSegment<TransactionType>(
              value: TransactionType.expense,
              label: Text('Pengeluaran'),
              icon: Icon(Icons.remove_circle),
            ),
            ButtonSegment<TransactionType>(
              value: TransactionType.transfer,
              label: Text('Transfer'),
              icon: Icon(Icons.swap_horiz),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<TransactionType> selected) {
            setState(() {
              _selectedType = selected.first;
              // Validate amount when transaction type changes
              _validateAmount();
            });
          },
        ),
      ],
    );
  }
  Widget _buildAmountField() {
    return Consumer(
      builder: (context, ref, _) {
        final walletAsync = ref.watch(selectedWalletProvider(widget.walletId));
        
        return TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Jumlah',
            prefixText: 'Rp ',
            border: const OutlineInputBorder(),
            helperText: (_selectedType == TransactionType.expense || _selectedType == TransactionType.transfer) 
                ? walletAsync.when(
                    data: (wallet) => wallet != null
                        ? 'Saldo tersedia: ${CurrencyFormatter.format(wallet.balance)}'
                        : null,
                    loading: () => 'Memuat saldo...',
                    error: (_, __) => null,
                  )
                : null,
            errorText: _amountWarning,
            errorStyle: const TextStyle(color: Colors.orange),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah tidak boleh kosong';
            }
            
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Jumlah harus lebih besar dari 0';
            }
            
            return null;
          },
        );
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Deskripsi',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Deskripsi tidak boleh kosong';
        }
        return null;
      },
    );
  }
  
  Widget _buildDestinationWalletSelector(List<WalletModel> otherWallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dompet Tujuan:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          value: _destinationWalletId,
          hint: const Text('Pilih dompet tujuan'),
          items: otherWallets.map((wallet) {
            return DropdownMenuItem<String>(
              value: wallet.id,
              child: Text(wallet.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _destinationWalletId = value;
            });
          },
          validator: (value) {
            if (_selectedType == TransactionType.transfer && (value == null || value.isEmpty)) {
              return 'Dompet tujuan harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }
    Widget _buildSubmitButton() {
    return Consumer(
      builder: (context, ref, _) {
        final transactionState = ref.watch(transactionNotifierProvider);
        final isLoading = transactionState is AsyncLoading;
        final walletAsync = ref.watch(selectedWalletProvider(widget.walletId));
        
        // Determine if button should be disabled
        bool isDisabled = isLoading;
        
        if (_amountWarning != null) {
          isDisabled = true;
        }
        
        if (_selectedType == TransactionType.expense || _selectedType == TransactionType.transfer) {
          // Try to parse amount
          final amount = double.tryParse(_amountController.text);
          if (amount != null) {
            walletAsync.whenData((wallet) {
              if (wallet != null && amount > wallet.balance) {
                isDisabled = true;
              }
            });
          }
        }
        
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isDisabled ? null : _submitTransaction,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan Transaksi'),
          ),
        );
      },
    );
  }
    void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse jumlah
        final amount = double.parse(_amountController.text);
        
        // Validasi khusus untuk transfer
        if (_selectedType == TransactionType.transfer && _destinationWalletId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dompet tujuan harus dipilih')),
          );
          return;
        }
        
        // Cek saldo dompet jika transaksi adalah pengeluaran atau transfer
        if (_selectedType == TransactionType.expense || _selectedType == TransactionType.transfer) {
          final walletAsync = await ref.read(selectedWalletProvider(widget.walletId).future);
          
          if (walletAsync == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dompet tidak ditemukan')),
            );
            return;
          }
          
          if (walletAsync.balance < amount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saldo tidak cukup untuk melakukan transaksi ini')),
            );
            return;
          }
        }
        
        // Buat objek transaksi
        final transaction = model.TransactionModel(
          id: const Uuid().v4(),
          walletId: widget.walletId,
          amount: amount,
          description: _descriptionController.text.trim(),
          type: _selectedType,
          destinationWalletId: _selectedType == TransactionType.transfer ? _destinationWalletId : null,
          timestamp: Timestamp.now(),
        );
        
        // Simpan transaksi
        await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
        
        if (context.mounted) {
          context.pop(); // Kembali ke halaman detail wallet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil disimpan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
