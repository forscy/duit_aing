import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/debt.dart';
import '../../models/enums.dart';
import '../../models/transaction.dart' as model;
import '../../providers/debt_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../providers/wallet_provider.dart';

class DebtListPage extends ConsumerWidget {
  const DebtListPage({super.key});

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d MMM y').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // back
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Hutang & Piutang'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hutang'),
              Tab(text: 'Piutang'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddDebtDialog(context, ref),
            ),
          ],
        ),
        body: debtsAsync.when(
          data: (allDebts) {
            // Sort debts by date, newest first
            final sortedDebts = List<DebtModel>.from(allDebts)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            // Split into hutang and piutang
            final hutang = sortedDebts.where((d) => d.kind == DebtKind.debt).toList();
            final piutang = sortedDebts.where((d) => d.kind == DebtKind.receivable).toList();
            
            // Calculate totals
            final totalHutang = hutang
                .where((d) => d.status == DebtStatus.unpaid)
                .fold(0.0, (sum, d) => sum + d.amount);
            final totalPiutang = piutang
                .where((d) => d.status == DebtStatus.unpaid)
                .fold(0.0, (sum, d) => sum + d.amount);

            return TabBarView(
              children: [
                // Hutang tab
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Hutang:'),
                          Text(                            CurrencyFormatter.format(totalHutang),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: hutang.length,
                        itemBuilder: (context, index) => _buildDebtCard(context, ref, hutang[index]),
                      ),
                    ),
                  ],
                ),
                // Piutang tab
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Piutang:'),
                          Text(                            CurrencyFormatter.format(totalPiutang),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: piutang.length,
                        itemBuilder: (context, index) => _buildDebtCard(context, ref, piutang[index]),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),        ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, WidgetRef ref, DebtModel debt) {
    final formattedAmount = CurrencyFormatter.format(debt.amount);
    final formattedDate = _formatDate(debt.createdAt);
    final formattedPaidDate = debt.paidAt != null ? _formatDate(debt.paidAt!) : null;
      return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    debt.personName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: !debt.isActive ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (!debt.isActive) ...[
                    const SizedBox(width: 8),
                    const Text(
                      '[Nonaktif]',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: debt.kind == DebtKind.debt ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(debt.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  debt.status == DebtStatus.paid ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: debt.status == DebtStatus.paid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  debt.status == DebtStatus.paid 
                      ? 'Lunas pada ${formattedPaidDate}'
                      : 'Dibuat pada $formattedDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showDebtDetailDialog(context, ref, debt),
      ),
    );
  }
  void _showAddDebtDialog(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String personName = '';
        double amount = 0;
        String description = '';
        DebtKind kind = DebtKind.debt;
        String? selectedWalletId;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Tambah Hutang/Piutang'),
            content: walletsAsync.when(
              data: (wallets) => Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<DebtKind>(
                        value: kind,
                        onChanged: (value) => setState(() => kind = value!),
                        items: DebtKind.values.map((k) {
                          return DropdownMenuItem(
                            value: k,
                            child: Text(k == DebtKind.debt ? 'Hutang' : 'Piutang'),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Nama harus diisi' : null,
                        onSaved: (value) => personName = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Jumlah'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Jumlah harus diisi';
                          final number = double.tryParse(value!);
                          if (number == null) return 'Jumlah tidak valid';
                          if (number <= 0) return 'Jumlah harus lebih dari 0';
                          return null;
                        },
                        onSaved: (value) => amount = double.parse(value!),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Keterangan'),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Keterangan harus diisi' : null,
                        onSaved: (value) => description = value!,
                      ),
                      DropdownButtonFormField<String?>(
                        value: selectedWalletId,
                        decoration: const InputDecoration(
                          labelText: 'Dompet (Opsional)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tidak ada dompet'),
                          ),
                          ...wallets.map((wallet) {
                            return DropdownMenuItem<String?>(
                              value: wallet.id,
                              child: Text(wallet.name),
                            );
                          }),
                        ],
                        onChanged: (value) => setState(() => selectedWalletId = value),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState!.save();
                    final debt = DebtModel(
                      id: const Uuid().v4(),
                      walletId: selectedWalletId ?? '',
                      personName: personName,
                      amount: amount,
                      kind: kind,
                      status: DebtStatus.unpaid,
                      description: description,
                      createdAt: Timestamp.now(),
                    );                    // Tambah hutang
                    ref.read(debtServiceProvider).addDebt(debt);
                    
                    // Jika wallet dipilih, buat transaksi
                    if (selectedWalletId?.isNotEmpty ?? false) {
                      final transaction = model.TransactionModel(
                        id: const Uuid().v4(),
                        walletId: selectedWalletId!,
                        amount: amount,
                        description: 'Pencatatan ${kind == DebtKind.debt ? "hutang" : "piutang"} - $personName',
                        type: kind == DebtKind.debt ? TransactionType.income : TransactionType.expense,
                        timestamp: Timestamp.now(),
                      );

                      // Simpan transaksi
                      try {
                        ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error membuat transaksi: ${e.toString()}')),
                          );
                        }
                      }
                    }
                    
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showDebtDetailDialog(BuildContext context, WidgetRef ref, DebtModel debt) {
    final walletsAsync = ref.watch(walletListProvider);
    
    String? selectedPaymentWalletId;
    String previousAmount = '';
    final amountController = TextEditingController(
      text: debt.status == DebtStatus.unpaid 
          ? debt.amount.toString() 
          : '0'
    );
    bool isPartialPayment = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              title: const Text('Detail Hutang/Piutang'),
              content: walletsAsync.when(
                data: (wallets) => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      Text('Nama: ${debt.personName}'),
                      Text('Jumlah: ${CurrencyFormatter.format(debt.amount)}'),
                      Text('Jenis: ${debt.kind == DebtKind.debt ? 'Hutang' : 'Piutang'}'),
                      Text('Status: ${debt.status == DebtStatus.paid ? 'Lunas' : 'Belum Lunas'}'),
                      if (!debt.isActive) const Text('Status: Nonaktif', style: TextStyle(color: Colors.red)),
                      Text('Keterangan: ${debt.description}'),
                      if (debt.walletId.isNotEmpty)
                        Text('Dompet: ${wallets.firstWhere((w) => w.id == debt.walletId).name}'),                      if (debt.status == DebtStatus.unpaid) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [                            
                            Checkbox(
                              value: isPartialPayment,
                              onChanged: (value) {
                                setState(() {
                                  isPartialPayment = value ?? false;
                                });
                                
                                if (!isPartialPayment) {
                                  // Simpan nilai sebelumnya sebelum mengubah ke total
                                  previousAmount = amountController.text;
                                  amountController.text = debt.amount.toString();
                                } else if (previousAmount.isNotEmpty) {
                                  // Kembalikan nilai sebelumnya jika ada
                                  amountController.text = previousAmount;
                                } else {
                                  // Jika tidak ada nilai sebelumnya, kosongkan
                                  amountController.text = '';
                                }
                              },
                            ),
                            const Text('Pembayaran Sebagian'),
                          ],
                        ),
                        if (isPartialPayment) ...[
                          const SizedBox(height: 8),                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah Pembayaran',
                              border: const OutlineInputBorder(),
                              helperText: 'Maksimal: ${CurrencyFormatter.format(debt.amount)}',
                            ),
                            onChanged: (value) {
                              // Update nilai sebelumnya saat user mengetik
                              previousAmount = value;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text('Lunasi dari dompet:'),
                        DropdownButtonFormField<String?>(
                          value: selectedPaymentWalletId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tidak ada dompet'),
                            ),
                            ...wallets.map((wallet) {
                              return DropdownMenuItem<String?>(
                                value: wallet.id,
                                child: Text(wallet.name),
                              );
                            }),
                          ],
                          onChanged: (value) => setState(() => selectedPaymentWalletId = value),
                        ),
                      ],
                    ],
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),                TextButton(
                  onPressed: () async {
                    if (debt.walletId.isNotEmpty) {
                      // Jika akan dinonaktifkan, buat transaksi untuk mengembalikan uang
                      if (debt.isActive) {
                        // Untuk hutang: tarik uang dari dompet (expense)
                        // Untuk piutang: masukkan uang ke dompet (income)
                        final transaction = model.TransactionModel(
                          id: const Uuid().v4(),
                          walletId: debt.walletId,
                          amount: debt.amount,
                          description: 'Pembatalan ${debt.kind == DebtKind.debt ? "hutang" : "piutang"} - ${debt.personName}',
                          type: debt.kind == DebtKind.debt ? TransactionType.expense : TransactionType.income,
                          timestamp: Timestamp.now(),
                        );

                        try {
                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error membuat transaksi: ${e.toString()}')),
                            );
                            return;
                          }
                        }
                      } else {
                        // Jika akan diaktifkan kembali, buat transaksi untuk mengembalikan ke kondisi semula
                        final transaction = model.TransactionModel(
                          id: const Uuid().v4(),
                          walletId: debt.walletId,
                          amount: debt.amount,
                          description: 'Pengaktifan ${debt.kind == DebtKind.debt ? "hutang" : "piutang"} - ${debt.personName}',
                          type: debt.kind == DebtKind.debt ? TransactionType.income : TransactionType.expense,
                          timestamp: Timestamp.now(),
                        );

                        try {
                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error membuat transaksi: ${e.toString()}')),
                            );
                            return;
                          }
                        }
                      }
                    }

                    // Toggle status hutang
                    ref.read(debtServiceProvider).toggleDebtStatus(debt.id, !debt.isActive);
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                          debt.isActive 
                            ? 'Hutang dinonaktifkan dan saldo dompet disesuaikan' 
                            : 'Hutang diaktifkan dan saldo dompet disesuaikan'
                        )),
                      );
                    }
                  },
                  child: Text(debt.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ),
                if (debt.status == DebtStatus.unpaid)
                  TextButton(
                    onPressed: () async {
                      final paymentAmount = double.tryParse(amountController.text);
                      if (paymentAmount == null || paymentAmount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jumlah pembayaran tidak valid')),
                        );
                        return;
                      }
                      
                      if (paymentAmount > debt.amount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jumlah pembayaran melebihi hutang/piutang')),
                        );
                        return;
                      }

                      // Jika wallet dipilih, buat transaksi
                      if (selectedPaymentWalletId != null) {
                        final walletState = ref.read(walletListProvider);
                        final selectedWallet = walletState.when(
                          data: (wallets) => wallets.firstWhere((w) => w.id == selectedPaymentWalletId),
                          loading: () => null,
                          error: (_, __) => null,
                        );

                        if (selectedWallet != null) {
                          if (selectedWallet.balance < paymentAmount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saldo dompet tidak mencukupi')),
                            );
                            return;
                          }

                          // Buat transaksi
                          final transaction = model.TransactionModel(
                            id: const Uuid().v4(),
                            walletId: selectedPaymentWalletId!,
                            amount: paymentAmount,
                            description: 'Pembayaran ${debt.kind == DebtKind.debt ? "hutang" : "piutang"} - ${debt.personName}',
                            type: debt.kind == DebtKind.debt ? TransactionType.expense : TransactionType.income,
                            timestamp: Timestamp.now(),
                          );

                          try {
                            await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                              return;
                            }
                          }
                        }
                      }

                      // Update status hutang
                      final isFullPayment = paymentAmount >= debt.amount;
                      if (isFullPayment) {
                        ref.read(debtServiceProvider).updateDebtStatus(
                          debt.id,
                          newStatus: DebtStatus.paid,
                          paymentWalletId: selectedPaymentWalletId,
                        );
                      } else {
                        // Update jumlah hutang yang tersisa
                        final updatedDebt = DebtModel(
                          id: debt.id,
                          walletId: debt.walletId,
                          personName: debt.personName,
                          amount: debt.amount - paymentAmount,
                          kind: debt.kind,
                          status: DebtStatus.unpaid,
                          description: debt.description,
                          createdAt: debt.createdAt,
                        );
                        ref.read(debtServiceProvider).updateDebt(updatedDebt);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isFullPayment ? 'Hutang/Piutang telah dilunasi' : 'Pembayaran sebagian berhasil')),
                        );
                      }
                    },
                    child: const Text('Lunasi'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
