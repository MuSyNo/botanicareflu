import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../models/soil_health.dart';
import '../app_colors.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

class SoilHealthHistoryScreen extends StatefulWidget {
  const SoilHealthHistoryScreen({super.key});

  @override
  State<SoilHealthHistoryScreen> createState() => _SoilHealthHistoryScreenState();
}

class _SoilHealthHistoryScreenState extends State<SoilHealthHistoryScreen> {
  final db = FirebaseDatabase.instance.ref();
  List<SoilHealth> entries = [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      db.child('soil_health_entries/$uid').onValue.listen((event) {
        final raw = event.snapshot.value;
        if (raw is Map) {
          raw.remove('latest'); // Exclude the 'latest' key
          final newEntries = raw.entries.map((e) {
            final value = e.value;
            if (value is Map) {
              return SoilHealth.fromMap(Map<String, dynamic>.from(value));
            }
            return null;
          }).whereType<SoilHealth>().toList();

          newEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          setState(() => entries = newEntries);
        } else {
          setState(() => entries.clear());
        }
      });
    }
  }

  String _formatTime(int timestamp) {
    return DateFormat.yMMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green.shade100;
      case 'moderate':
        return Colors.orange.shade100;
      case 'poor':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('${t.soilHealth} ${t.history}'),
        backgroundColor: AppColors.forestGreen,
      ),
      body: entries.isEmpty
          ? Center(
        child: Text(t.noHistory, style: TextStyle(color: Colors.grey[600])),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final e = entries[index];
          return _buildEntryCard(e, t);
        },
      ),
    );
  }

  Widget _buildEntryCard(SoilHealth e, AppLocalizations t) {
    final formattedTime = _formatTime(e.timestamp);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.water_drop, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text("pH: ${e.pH.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
              _buildTag(
                e.pH < 6 ? t.acidic : (e.pH > 7.5 ? t.alkaline : t.neutral),
                e.pH < 6 ? Colors.redAccent : (e.pH > 7.5 ? Colors.deepPurple : Colors.green),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildNPKTag("N", e.nitrogen, Colors.teal),
              const SizedBox(width: 6),
              _buildNPKTag("P", e.phosphorus, Colors.indigo),
              const SizedBox(width: 6),
              _buildNPKTag("K", e.potassium, Colors.brown),
            ]),
            if (e.crop != null && e.crop!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.local_florist, size: 20, color: Colors.brown),
                  const SizedBox(width: 6),
                  Text('${t.crop}: ${e.crop}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(e.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_outlined, size: 20, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text('${t.status}: ${e.status}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(formattedTime, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }

  Widget _buildNPKTag(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
