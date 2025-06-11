import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OfflineLogSync {
  static const String _logKey = "offline_logs";

  /// Saves a log entry locally in SharedPreferences.
  /// Logs are stored as a list of JSON-encoded strings.
  static Future<void> saveLog(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_logKey) ?? [];

    entry['timestamp'] ??= DateTime.now().toIso8601String();
    logs.add(jsonEncode(entry));

    await prefs.setStringList(_logKey, logs);
    debugPrint("📦 Offline log saved: ${entry['type'] ?? 'unknown'}");
  }

  /// Syncs all locally saved logs to Firebase and clears the local cache after success.
  static Future<void> syncLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      debugPrint("⚠️ User not authenticated. Cannot sync logs.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_logKey) ?? [];

    if (logs.isEmpty) {
      debugPrint("✅ No offline logs to sync.");
      return;
    }

    final ref = FirebaseDatabase.instance.ref("offline_logs/$uid");

    for (final logJson in logs) {
      try {
        final decoded = jsonDecode(logJson);
        if (decoded is Map<String, dynamic>) {
          await ref.push().set(decoded);
          debugPrint("✅ Synced offline log: ${decoded['type'] ?? 'unknown'}");
        }
      } catch (e) {
        debugPrint("❌ Failed to sync a log entry: $e");
      }
    }

    await prefs.remove(_logKey);
    debugPrint("🧹 Cleared synced offline logs.");
  }

  /// Triggers log sync attempt (e.g., on app start or reconnect).
  static Future<void> trySyncOnReconnect() async {
    try {
      await syncLogs();
    } catch (e) {
      debugPrint("🌐 Unable to sync due to connectivity issue: $e");
    }
  }
}
