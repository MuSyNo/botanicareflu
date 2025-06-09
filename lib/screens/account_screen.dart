import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final t = AppLocalizations.of(context)!; // ✅ Correct usage for gen-l10n

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.account),
        backgroundColor: AppColors.forestGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.person, size: 72, color: AppColors.forestGreen),
            ),
            const SizedBox(height: 30),

            /// Email
            Text(
              t.emailLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? t.notSignedIn,
              style: const TextStyle(fontSize: 18),
            ),

            /// Optional: Display name
            if (user?.displayName != null) ...[
              const SizedBox(height: 20),
              Text(
                t.accountSettings,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                user!.displayName!,
                style: const TextStyle(fontSize: 18),
              ),
            ],

            /// Optional: Phone number
            if (user?.phoneNumber != null) ...[
              const SizedBox(height: 20),
              Text(
                t.phone,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                user!.phoneNumber!,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
