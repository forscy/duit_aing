import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/enums.dart';
import '../widgets/financial_summary.dart';
import '../widgets/wallet_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final walletController = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, authController),
              const SizedBox(height: 20),
              _buildBalanceCard(context, authController),
              const SizedBox(height: 20),
              _buildQuickActionsMenu(context),
              const SizedBox(height: 20),
              _buildRecentTransactions(context),
              const SizedBox(height: 20),
              _buildWalletsList(context, walletController),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Show modal to add new wallet or transaction
          _showAddOptions(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthController authController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 5),
              Obx(() => Text(
                    authController.appUser?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Navigate to profile page
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B8B), // Pink
            Color(0xFFFF8E53), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                authController.appUser?.displayName?.toUpperCase() ?? 'USER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Image.asset(
                'assets/images/logo.png',  // Pastikan logo ada, atau gunakan Icon
                width: 60,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.credit_card, color: Colors.white);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          GetX<WalletController>(
            builder: (controller) => Text(
              'Rp${_formatCurrency(controller.totalBalance)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsMenu(BuildContext context) {
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
        'label': 'Withdraw',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
      ],
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
            backgroundColor: color.withOpacity(0.2),
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

  Widget _buildRecentTransactions(BuildContext context) {
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
        _buildTransactionItem(
          context,
          icon: Icons.music_note,
          iconColor: Colors.green,
          iconBgColor: Colors.green.withOpacity(0.2),
          title: 'Spotify Subscription',
          date: '12:01 am - 21 Jun 2021',
          amount: '-Rp11.90',
          isExpense: true,
        ),
        _buildTransactionItem(
          context,
          icon: Icons.shopping_bag,
          iconColor: Colors.blue,
          iconBgColor: Colors.blue.withOpacity(0.2),
          title: 'Online Shopping',
          date: '08:23 pm - 20 Jun 2021',
          amount: '-Rp240.00',
          isExpense: true,
        ),
        _buildTransactionItem(
          context,
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

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
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

  Widget _buildWalletsList(BuildContext context, WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Wallets',
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
                  // Navigate to all wallets
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: Obx(
            () {
              if (controller.wallets.isEmpty) {
                return Center(
                  child: Text(
                    'No wallets yet. Add one!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: controller.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = controller.wallets[index];
                  return SizedBox(
                    width: 250,
                    child: WalletCard(
                      wallet: wallet,
                      onTap: () {
                        // Navigate to wallet detail
                        Get.toNamed('/wallet/${wallet.id}');
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor),
              title: Text('Add New Wallet'),
              onTap: () {
                Navigator.pop(context);
                // Show add wallet dialog
                _showAddWalletDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
              title: Text('Add New Transaction'),
              onTap: () {
                Navigator.pop(context);
                // Show add transaction dialog
                _showAddTransactionDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final controller = Get.find<WalletController>();
    WalletVisibility visibility = WalletVisibility.private;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Wallet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Wallet Name'),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Initial Balance'),
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visibility:'),
                      Row(
                        children: [
                          Radio<WalletVisibility>(
                            value: WalletVisibility.private,
                            groupValue: visibility,
                            onChanged: (value) {
                              setState(() => visibility = value!);
                            },
                          ),
                          Text('Private'),
                          Radio<WalletVisibility>(
                            value: WalletVisibility.shared,
                            groupValue: visibility,
                            onChanged: (value) {
                              setState(() => visibility = value!);
                            },
                          ),
                          Text('Shared'),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      if (nameController.text.isNotEmpty && balanceController.text.isNotEmpty) {
                        // Create wallet
                        controller.addWallet(
                          nameController.text,
                          double.tryParse(balanceController.text) ?? 0,
                          visibility,
                        );
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    // Implementasi dialog tambah transaksi
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Form tambah transaksi disini
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format angka menjadi format mata uang
  String _formatCurrency(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    return amount.toString().replaceAllMapped(reg, mathFunc);
  }
}
