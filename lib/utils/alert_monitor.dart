import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SoilAlertMonitor {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  Timer? _timer;

  SoilAlertMonitor(this.notificationsPlugin);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _checkLatestCondition());
    _checkLatestCondition(); // Run once immediately
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkLatestCondition() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final ref = FirebaseDatabase.instance.ref("soil_health_entries/$uid/latest");
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) return;

      final rawData = snapshot.value;
      if (rawData is! Map) return;

      final data = Map<String, dynamic>.from(rawData);
      final double? moisture = (data['moisture'] as num?)?.toDouble();
      final String? status = data['status']?.toString();

      if (moisture != null && moisture < 30) {
        _notify(
          "Low Soil Moisture",
          "Moisture is at ${moisture.toStringAsFixed(1)}%. Please irrigate.",
        );
      } else if (status != null && status.toLowerCase() == "poor") {
        _notify(
          "Poor Soil Condition",
          "Your soil health status is marked as 'Poor'. Please review.",
        );
      }
    } catch (e) {
      print("⚠️ SoilAlertMonitor error: $e");
    }
  }

  void _notify(String title, String body) {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    notificationsPlugin.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'soil_alerts',
          'Soil Alerts',
          channelDescription: 'Notifications for soil moisture and condition warnings',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}
