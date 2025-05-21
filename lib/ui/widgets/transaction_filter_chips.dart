import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/enums.dart';
import '../../controllers/transaction_controller.dart';

class TransactionFilterChips extends StatelessWidget {
  const TransactionFilterChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: 'Semua',
              isSelected: transactionController.filterType.value == null,
              onSelected: (_) => transactionController.resetFilter(),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Pemasukan',
              isSelected: transactionController.filterType.value == TransactionType.income,
              onSelected: (_) => transactionController.setFilter(TransactionType.income),
              backgroundColor: Colors.green.withOpacity(0.1),
              selectedColor: Colors.green,
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Pengeluaran',
              isSelected: transactionController.filterType.value == TransactionType.expense,
              onSelected: (_) => transactionController.setFilter(TransactionType.expense),
              backgroundColor: Colors.red.withOpacity(0.1),
              selectedColor: Colors.red,
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: 'Transfer',
              isSelected: transactionController.filterType.value == TransactionType.transfer,
              onSelected: (_) => transactionController.setFilter(TransactionType.transfer),
              backgroundColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? backgroundColor,
    Color? selectedColor,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
      selectedColor: selectedColor ?? Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : selectedColor ?? Theme.of(context).primaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
