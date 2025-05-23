import 'package:flutter/material.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';

class SharedWithSection extends StatelessWidget {
  final WalletModel wallet;

  const SharedWithSection({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dibagikan dengan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show shared users
              for (var email in wallet.sharedWith) ...[
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(email),
                  subtitle: email == wallet.ownerId ? const Text('Pemilik') : null,
                ),
              ],
              // Show pending invitations
              for (var invitation in wallet.invitations.where(
                (inv) => inv.status == InvitationStatus.pending
              )) ...[
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.person_add_alt_1, color: Colors.white),
                  ),
                  title: Text(invitation.email),
                  subtitle: const Text('Menunggu konfirmasi'),
                  trailing: const Icon(Icons.hourglass_empty),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
