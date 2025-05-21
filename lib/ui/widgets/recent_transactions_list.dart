import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                child: Text(
                  'See All',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  // Navigate to all transactions
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TransactionItem(
          icon: Icons.music_note,
          iconColor: Colors.green,
          iconBgColor: Colors.green.withOpacity(0.2),
          title: 'Spotify Subscription',
          date: '12:01 am - 21 Jun 2021',
          amount: '-Rp11.90',
          isExpense: true,
        ),
        TransactionItem(
          icon: Icons.shopping_bag,
          iconColor: Colors.blue,
          iconBgColor: Colors.blue.withOpacity(0.2),
          title: 'Online Shopping',
          date: '08:23 pm - 20 Jun 2021',
          amount: '-Rp240.00',
          isExpense: true,
        ),
        TransactionItem(
          icon: Icons.attach_money,
          iconColor: Colors.purple,
          iconBgColor: Colors.purple.withOpacity(0.2),
          title: 'Salary Payment',
          date: '10:00 am - 15 Jun 2021',
          amount: '+Rp1,200.00',
          isExpense: false,
        ),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String date;
  final String amount;
  final bool isExpense;

  const TransactionItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconBgColor,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
