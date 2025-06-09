import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../app_colors.dart';
import '../models/water_usage_entry.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

class WaterUsageChartScreen extends StatefulWidget {
  const WaterUsageChartScreen({super.key});

  @override
  State<WaterUsageChartScreen> createState() => _WaterUsageChartScreenState();
}

class _WaterUsageChartScreenState extends State<WaterUsageChartScreen> {
  final db = FirebaseDatabase.instance.ref();
  List<WaterUsageEntry> data = [];
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      db.child('water_usage/$uid').onValue.listen((event) {
        final raw = event.snapshot.value;
        if (raw is Map) {
          final newData = raw.entries
              .where((e) => e.value is Map)
              .map((e) => WaterUsageEntry.fromMap(Map<String, dynamic>.from(e.value)))
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          setState(() => data = newData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.waterUsage),
        backgroundColor: AppColors.forestGreen,
      ),
      body: data.isEmpty
          ? Center(
        child: Text(
          t.noUsageData,
          style: const TextStyle(color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const Text('');
                    final ts = data[index].timestamp;
                    try {
                      final date = DateTime.fromMillisecondsSinceEpoch(ts);
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.Md().format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    } catch (_) {
                      return const Text('');
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('${value.toInt()}L', style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.liters);
                }).toList(),
                isCurved: true,
                color: AppColors.forestGreen,
                barWidth: 2,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
