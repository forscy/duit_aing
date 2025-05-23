import 'package:duit_aing/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionActionsDialog extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionActionsDialog({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(transaction.isActive ? 'Batalkan Transaksi' : 'Aktifkan Transaksi'),
      content: Text(
        transaction.isActive
            ? 'Anda yakin ingin membatalkan transaksi ini?\nTindakan ini akan mengubah saldo dompet.'
            : 'Anda yakin ingin mengaktifkan kembali transaksi ini?\nTindakan ini akan mengubah saldo dompet.',
      ),
      actions: [
        TextButton(
          child: const Text('Tidak'),
          onPressed: () => context.pop(false),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: transaction.isActive ? Colors.red : Colors.green,
          ),
          child: Text(transaction.isActive ? 'Ya, Batalkan' : 'Ya, Aktifkan'),
          onPressed: () => context.pop(true),
        ),
      ],
    );
  }
}
