import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';

class FinancialSummary extends StatelessWidget {
  const FinancialSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF293462), // Biru tua
            Color(0xFF1A1F38), // Hampir hitam
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Saldo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha:  0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              'Rp ${_formatCurrency(walletController.totalBalance)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha:  0.2)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Icons.account_balance_wallet,
                title: 'Dompet',
                value: '${walletController.walletCount}',
              ),
              _buildInfoItem(
                icon: Icons.arrow_upward,
                title: 'Pemasukan',
                value: 'Rp 0', // Sementara hardcode
              ),
              _buildInfoItem(
                icon: Icons.arrow_downward,
                title: 'Pengeluaran',
                value: 'Rp 0', // Sementara hardcode
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha:  0.8),
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha:  0.7),
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  // Format angka menjadi format mata uang
  String _formatCurrency(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    mathFunc(Match match) => '${match[1]}.';
    return amount.toString().replaceAllMapped(reg, mathFunc);
  }
}
