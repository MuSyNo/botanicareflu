import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/soil_health.dart';
import '../app_colors.dart';
import '../gen_l10n/app_localizations.dart';

class LatestSoilConditionScreen extends StatefulWidget {
  const LatestSoilConditionScreen({super.key});

  @override
  State<LatestSoilConditionScreen> createState() => _LatestSoilConditionScreenState();
}

class _LatestSoilConditionScreenState extends State<LatestSoilConditionScreen> {
  SoilHealth? _latest;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestCondition();
  }

  Future<void> _fetchLatestCondition() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .doc('soil_health_entries/$userId/latest')
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          _latest = SoilHealth.fromMap(snapshot.data()!);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("Error loading soil condition: $e");
      setState(() => _loading = false);
    }
  }

  Color _getPHColor(double pH) {
    if (pH < 6.0) return Colors.redAccent;
    if (pH > 7.5) return Colors.deepPurple;
    return Colors.green;
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
      appBar: AppBar(
        title: Text(t.latestSoilCondition),
        backgroundColor: AppColors.forestGreen,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _latest == null
          ? Center(child: Text(t.noHistory))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(t),
            const SizedBox(height: 16),
            _buildPHCard(t),
            const SizedBox(height: 16),
            _buildNPKRow(),
            const SizedBox(height: 16),
            _buildStatusCard(t),
            const SizedBox(height: 16),
            _buildRecommendationCard(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t) {
    final dateStr = DateFormat.yMMMd().add_jm().format(_latest!.dateTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.soilHealthOverview,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "${t.lastUpdated}: $dateStr",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPHCard(AppLocalizations t) {
    final pH = _latest!.pH;
    final label = pH < 6
        ? t.acidic
        : pH > 7.5
        ? t.alkaline
        : t.neutral;

    return Card(
      color: _getPHColor(pH).withOpacity(0.2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.water_drop_outlined),
        title: Text("${t.soilPH}: ${pH.toStringAsFixed(1)} ($label)"),
        subtitle: Text(t.idealPHRange),
      ),
    );
  }

  Widget _buildNPKRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNutrientTile("N", _latest!.nitrogen, Colors.teal),
        _buildNutrientTile("P", _latest!.phosphorus, Colors.indigo),
        _buildNutrientTile("K", _latest!.potassium, Colors.brown),
      ],
    );
  }

  Widget _buildNutrientTile(String label, int value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$value ppm",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusCard(AppLocalizations t) {
    final status = _latest!.status;
    return Card(
      color: _getStatusColor(status),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.eco_outlined),
        title: Text(
          "${t.overallStatus}: $status",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(t.statusBasedOn),
      ),
    );
  }

  Widget _buildRecommendationCard(AppLocalizations t) {
    final text = _latest!.recommendation;
    return Card(
      color: Colors.lightGreen.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.careRecommendation,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(text),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.copiedToClipboard)),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: Text(t.copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
