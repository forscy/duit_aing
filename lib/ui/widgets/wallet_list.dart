import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet.dart';
import 'wallet_card.dart';

class WalletList extends StatelessWidget {
  final WalletController controller;

  const WalletList({
    Key? key,
    required this.controller,
  }) : super(key: key);

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
}
