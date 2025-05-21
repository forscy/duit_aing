import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/wallet.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/enums.dart';

class WalletSummary extends StatelessWidget {
  final Wallet wallet;
  
  const WalletSummary({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet name and visibility
          Row(
            children: [
              Expanded(
                child: Text(
                  wallet.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildVisibilityBadge(wallet.visibility),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Current balance
          Text(
            'Saldo Saat Ini',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            formatter.format(wallet.balance),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Transaction summary
          Obx(() => Row(
            children: [
              // Income summary
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  label: 'Pemasukan',
                  amount: transactionController.totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 8),
              // Expense summary
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  label: 'Pengeluaran',
                  amount: transactionController.totalExpense,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
            ],
          )),
          
          SizedBox(height: 8),
          
          // Shared info
          if (wallet.visibility == WalletVisibility.shared) ...[
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            
            Text(
              'Dibagikan dengan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 8),
            
            ...wallet.sharedWith.map((email) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  if (email == wallet.ownerId)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pemilik',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildVisibilityBadge(WalletVisibility visibility) {
    IconData icon;
    String label;
    Color color;
    
    switch (visibility) {
      case WalletVisibility.private:
        icon = Icons.lock;
        label = 'Privat';
        color = Colors.grey;
        break;
      case WalletVisibility.shared:
        icon = Icons.people;
        label = 'Dibagikan';
        color = Colors.blue;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard({
    required BuildContext context,
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            formatter.format(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
