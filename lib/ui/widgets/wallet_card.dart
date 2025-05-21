import 'package:duit_aing/models/enums.dart';
import 'package:flutter/material.dart';
import '../../models/wallet.dart';
import '../../utils/currency_formatter.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;

  const WalletCard({
    Key? key,
    required this.wallet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  wallet.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    wallet.visibility == WalletVisibility.private ? 'Pribadi' : 'Bersama',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Saldo',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Rp ${_formatCurrency(wallet.balance)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (wallet.visibility == WalletVisibility.shared) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${wallet.sharedWith.length} pengguna',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Mendapatkan warna kartu berdasarkan nama/index
  Color _getCardColor() {
    final List<Color> colors = [
      Color(0xFF6C5CE7), // Ungu
      Color(0xFF00B894), // Mint
      Color(0xFFFC5C65), // Pink
      Color(0xFFFD9644), // Oranye
      Color(0xFF45AAF2), // Biru
    ];

    // Gunakan hashCode untuk distribusi warna
    final colorIndex = wallet.name.hashCode % colors.length;
    return colors[colorIndex.abs()];
  }  String _formatCurrency(double amount) {
    return CurrencyFormatter.format(amount);
  }
}
