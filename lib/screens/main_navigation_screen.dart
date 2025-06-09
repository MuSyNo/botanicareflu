import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dashboard_screen.dart';
import 'account_screen.dart'; // Change to: 'settings_screen.dart' if preferred
import '../app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AccountScreen(), // or: SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.darkGray,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard, size: 26),
            label: t.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 26), // or: Icons.settings
            label: t.account, // or: t.settings
          ),
        ],
      ),
    );
  }
}
