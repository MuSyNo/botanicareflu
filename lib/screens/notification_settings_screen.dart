import 'package:flutter/material.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

import '../app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool muteNotifications = false;
  bool soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationSettings),
        backgroundColor: AppColors.forestGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(t.muteNotifications),
            subtitle: Text(t.muteNotificationsDescription),
            value: muteNotifications,
            activeColor: AppColors.forestGreen,
            onChanged: (value) => setState(() => muteNotifications = value),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(t.sound),
            subtitle: Text(t.soundDescription),
            value: soundEnabled,
            activeColor: AppColors.forestGreen,
            onChanged: (value) => setState(() => soundEnabled = value),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
