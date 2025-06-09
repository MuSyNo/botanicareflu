import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IrrigationHistoryScreen extends StatefulWidget {
  const IrrigationHistoryScreen({super.key});

  @override
  State<IrrigationHistoryScreen> createState() => _IrrigationHistoryScreenState();
}

class _IrrigationHistoryScreenState extends State<IrrigationHistoryScreen> {
  final db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      db.child('irrigation_history/$uid').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final newEntries = data.entries
              .where((e) => e.value is Map)
              .map((e) => Map<String, dynamic>.from(e.value as Map))
              .toList();

          newEntries.sort((a, b) =>
              (b['timestamp'] as int).compareTo(a['timestamp'] as int));

          setState(() => entries = newEntries);
        } else {
          setState(() => entries = []);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("${t.irrigation} ${t.history}"),
        backgroundColor: AppColors.forestGreen,
      ),
      backgroundColor: AppColors.offWhite,
      body: entries.isEmpty
          ? Center(
        child: Text(
          t.noHistory,
          style: const TextStyle(color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final duration = entry['duration'] ?? 0;
          final timestamp = entry['timestamp'];

          final time = timestamp is int
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : DateTime.now();

          return ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.water_drop_outlined, color: AppColors.forestGreen),
            title: Text("${t.irrigationDuration}: $duration s"),
            subtitle: Text(DateFormat.yMMMd().add_jm().format(time)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
