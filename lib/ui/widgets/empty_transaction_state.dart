import 'package:flutter/material.dart';

class EmptyTransactionState extends StatelessWidget {
  final Function()? onAddTransaction;
  
  const EmptyTransactionState({
    super.key,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/6159/6159389.png',
            height: 100,
          ),
          SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Catat transaksi pertamamu untuk mulai melacak keuanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          if (onAddTransaction != null)
            ElevatedButton.icon(
              onPressed: onAddTransaction,
              icon: Icon(Icons.add),
              label: Text('Tambah Transaksi'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
