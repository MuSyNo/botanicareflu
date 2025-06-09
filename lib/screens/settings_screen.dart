import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_colors.dart';
import '../main.dart';
import '../gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        backgroundColor: AppColors.forestGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(t.notificationSettings),
            onTap: () => Navigator.pushNamed(context, '/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(t.systemSettings),
            onTap: () => Navigator.pushNamed(context, '/system-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(t.helpSupport),
            onTap: () => Navigator.pushNamed(context, '/help-support'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(t.language),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(t.chooseLanguage),
                  children: [
                    SimpleDialogOption(
                      child: const Text("English"),
                      onPressed: () {
                        BotaniCareApp.setLocale(context, const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    SimpleDialogOption(
                      child: const Text("Bahasa Melayu"),
                      onPressed: () {
                        BotaniCareApp.setLocale(context, const Locale('ms'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(t.accountSettings),
            onTap: () => Navigator.pushNamed(context, '/account-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t.about),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'BotaniCare',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 BotaniCare',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
