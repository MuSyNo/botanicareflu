import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../app_colors.dart';
import '../models/app_notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final db = FirebaseDatabase.instance.ref();
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    db.child("notifications/$uid").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final loaded = data.entries.map((e) {
          final id = e.key;
          final value = e.value;
          if (value is Map) {
            return AppNotification.fromMap(id, Map<String, dynamic>.from(value));
          }
          return null;
        }).whereType<AppNotification>().toList();

        loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        setState(() => notifications = loaded);
      } else {
        setState(() => notifications.clear());
      }
    });
  }

  void _markAsRead(String id) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      db.child("notifications/$uid/$id/read").set(true);
    }
  }

  void _markAllAsRead() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      for (var notif in notifications) {
        db.child("notifications/$uid/${notif.id}/read").set(true);
      }
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.markAllRead)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.notifications),
        backgroundColor: AppColors.forestGreen,
        actions: [
          if (notifications.any((n) => !n.read))
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              tooltip: t.markAllRead,
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text(t.noNotifications, style: const TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final time = DateFormat.yMMMMd().add_jm().format(
            DateTime.fromMillisecondsSinceEpoch(n.timestamp),
          );

          return GestureDetector(
            onTap: () => _markAsRead(n.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: n.read ? Colors.white : AppColors.notificationUnread,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: n.read ? Colors.grey[300] : AppColors.forestGreen,
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text(
                  n.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(n.body),
                    const SizedBox(height: 6),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
