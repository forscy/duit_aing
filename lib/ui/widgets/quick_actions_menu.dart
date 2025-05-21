import 'package:flutter/material.dart';

class QuickActionsMenu extends StatelessWidget {
  const QuickActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.send,
        'color': Colors.blue,
        'label': 'Send',
        'onTap': () {},
      },
      {
        'icon': Icons.payment,
        'color': Colors.red,
        'label': 'Pay',
        'onTap': () {},
      },
      {
        'icon': Icons.account_balance_wallet,
        'color': Colors.green,
        'label': 'Receive',
        'onTap': () {},
      },
      {
        'icon': Icons.receipt_long,
        'color': Colors.purple,
        'label': 'Bill',
        'onTap': () {},
      },
      {
        'icon': Icons.card_giftcard,
        'color': Colors.orange,
        'label': 'Voucher',
        'onTap': () {},
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) {
        return _buildActionItem(
          context,
          icon: action['icon'],
          color: action['color'],
          label: action['label'],
          onTap: action['onTap'],
        );
      }).toList(),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
