import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../screens/dashboard_screen.dart';
import '../screens/irrigation_control_screen.dart';
import '../screens/soil_health_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/settings_screen.dart';
import '../gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Widget> get screens => const [
    DashboardScreen(),
    IrrigationControlScreen(),
    SoilHealthScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.darkGray,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard, size: 26),
            label: t.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.water_drop, size: 26),
            label: t.irrigation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grass, size: 26),
            label: t.soilHealth,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_active, size: 26),
            label: t.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings, size: 26),
            label: t.settings,
          ),
        ],
      ),
    );
  }
}
