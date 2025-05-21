import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/enums.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Function()? onTap;
  final Function()? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Determine icon and color based on transaction type
    IconData typeIcon;
    Color typeColor;
    String prefix;

    switch (transaction.type) {
      case TransactionType.income:
        typeIcon = Icons.arrow_downward;
        typeColor = Colors.green;
        prefix = '+';
        break;
      case TransactionType.expense:
        typeIcon = Icons.arrow_upward;
        typeColor = Colors.red;
        prefix = '-';
        break;
      case TransactionType.transfer:
        typeIcon = Icons.swap_horiz;
        typeColor = Colors.blue;
        prefix = '-';
        break;
    }

    // Format date
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(transaction.timestamp);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Transaction type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 20,
                ),
              ),
              
              SizedBox(width: 12),
              
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    
                    // For transfer transactions, show destination wallet
                    if (transaction.type == TransactionType.transfer && transaction.destinationWalletId != null)
                      Text(
                        'Ke: ${transaction.destinationWalletId}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Transaction amount
              Text(
                '$prefix${formatter.format(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                  fontSize: 15,
                ),
              ),
              
              // Delete option
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
                    // Confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hapus Transaksi'),
                        content: Text('Anda yakin ingin menghapus transaksi ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete!();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
