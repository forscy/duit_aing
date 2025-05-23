import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart' as model;
import 'package:duit_aing/providers/transaction_provider.dart';
import 'package:duit_aing/utils/currency_formatter.dart';

class TransactionsList extends ConsumerWidget {
  final String walletId;
  final Function(BuildContext context, WidgetRef ref, model.TransactionModel transaction) onTransactionLongPress;

  const TransactionsList({
    Key? key,
    required this.walletId,
    required this.onTransactionLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(walletTransactionsProvider(walletId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Transaksi',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(
                child: Text('Belum ada transaksi'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(context, ref, transaction);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ],
    );
  }
  Widget _buildTransactionItem(BuildContext context, WidgetRef ref, model.TransactionModel transaction) {
    final bool isExpense = transaction.type == TransactionType.expense;
    final bool isTransfer = transaction.type == TransactionType.transfer;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onLongPress: () => onTransactionLongPress(context, ref, transaction),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction.type, transaction.isActive).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: _getTransactionColor(transaction.type, transaction.isActive),
          ),
        ),
        title: Text(
          transaction.description.isEmpty ? 
            _getTransactionTypeText(transaction.type) : 
            transaction.description,
          style: !transaction.isActive 
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : null,
        ),
        subtitle: Row(
          children: [
            Text(_getTransactionTypeText(transaction.type) +
                ' • ' +
                _formatDate(transaction.timestamp.toDate())),
            if (!transaction.isActive) ...[
              const SizedBox(width: 4),
              const Text(
                '• Dibatalkan',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        trailing: Text(
          '${isExpense ? "-" : isTransfer ? "→" : "+"} ${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            color: !transaction.isActive 
                ? Colors.grey
                : transaction.type == TransactionType.expense 
                    ? Colors.red 
                    : transaction.type == TransactionType.income 
                        ? Colors.green 
                        : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Color _getTransactionColor(TransactionType type, bool isActive) {
    if (!isActive) return Colors.grey;
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.add_circle;
      case TransactionType.expense:
        return Icons.remove_circle;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
