import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/system_settings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/soil_health_history_screen.dart';
import 'utils/alert_monitor.dart';
import 'utils/offline_log_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Handles push messages received while app is in the background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔕 [Background] ${message.notification?.title} - ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Sync offline logs if any
  await OfflineLogSync.trySyncOnReconnect();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notifications
  const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: initSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const BotaniCareApp());
}

class BotaniCareApp extends StatefulWidget {
  const BotaniCareApp({super.key});

  @override
  State<BotaniCareApp> createState() => _BotaniCareAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_BotaniCareAppState>();
    state?._setLocale(newLocale);
  }
}

class _BotaniCareAppState extends State<BotaniCareApp> {
  Locale _locale = const Locale('en');
  late SoilAlertMonitor _soilMonitor;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
    _soilMonitor = SoilAlertMonitor(flutterLocalNotificationsPlugin);
    _soilMonitor.start();

    // Attempt to sync offline logs on reconnect
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        OfflineLogSync.trySyncOnReconnect();
      }
    });
  }

  void _setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  Future<void> _setupPushNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseMessaging.instance.subscribeToTopic(uid);
        }

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          final android = notification?.android;

          if (notification != null && android != null) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'botanicare_channel',
                  'BotaniCare Notifications',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          }
        });
      } else {
        debugPrint("🔕 Notification permission not granted.");
      }
    } catch (e) {
      debugPrint("❌ Error setting up push notifications: $e");
    }
  }

  @override
  void dispose() {
    _soilMonitor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return MaterialApp(
      title: 'BotaniCare',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: isLoggedIn
          ? const HomeScreen()
          : LoginScreen(onLocaleChange: _setLocale),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/account-settings': (context) => const AccountSettingsScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/system-settings': (context) => const SystemSettingsScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/soil-health-history': (context) => const SoilHealthHistoryScreen(),
      },
    );
  }
}
