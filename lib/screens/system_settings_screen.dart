import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_colors.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.systemSettings),
        backgroundColor: AppColors.forestGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t.about),
            subtitle: Text(t.firmwareVersion),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(t.syncTimeWithDevice),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.syncComingSoon)),
              );
            },
          ),
        ],
      ),
    );
  }
}
