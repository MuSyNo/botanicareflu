import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_colors.dart';
import '../models/soil_health.dart';
import '../models/crop.dart';
import 'latest_soil_irrigation_screen.dart'; // ✅ Corrected import path

class SoilHealthScreen extends StatefulWidget {
  const SoilHealthScreen({super.key});

  @override
  State<SoilHealthScreen> createState() => _SoilHealthScreenState();
}

class _SoilHealthScreenState extends State<SoilHealthScreen> {
  final db = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  final pHController = TextEditingController();
  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();

  String? uid;
  SoilHealth? latest;
  String? selectedCrop;
  List<Crop> cropList = [];
  bool cropsLoading = true;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      db.child('soil_health_entries/$uid/latest').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          setState(() {
            latest = SoilHealth.fromMap(Map<String, dynamic>.from(data));
          });
        }
      });

      FirebaseFirestore.instance
          .collection('plants')
          .doc(uid)
          .collection('crops')
          .get()
          .then((snapshot) {
        setState(() {
          cropList = snapshot.docs.map((doc) => Crop.fromMap(doc.id, doc.data())).toList();
          cropsLoading = false;
        });
      });
    }
  }

  void _submit(AppLocalizations t) {
    if (!_formKey.currentState!.validate() || uid == null || selectedCrop == null) return;

    final pH = double.parse(pHController.text.trim());
    final n = int.parse(nController.text.trim());
    final p = int.parse(pController.text.trim());
    final k = int.parse(kController.text.trim());

    final status = _classify(pH, n, p, k);
    final recommendation = _generateRecommendation(pH, n, p, k);

    final entry = SoilHealth(
      pH: pH,
      nitrogen: n,
      phosphorus: p,
      potassium: k,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: status,
      recommendation: recommendation,
      crop: selectedCrop,
    );

    db.child('soil_health_entries/$uid/latest').set(entry.toMap());
    db.child('soil_health_entries/$uid/history').push().set(entry.toMap());

    pHController.clear();
    nController.clear();
    pController.clear();
    kController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${t.latestSoilCondition} ${t.updated}')),
    );
  }

  String _classify(double pH, int n, int p, int k) {
    if (pH >= 6.0 && pH <= 7.0 && n > 15 && p > 20 && k > 20) return "Good";
    if (pH >= 5.5 && pH <= 7.5 && n > 10 && p > 15 && k > 15) return "Moderate";
    return "Poor";
  }

  String _generateRecommendation(double pH, int n, int p, int k) {
    final buffer = StringBuffer();
    if (pH < 6.0) buffer.writeln("Raise pH with lime.");
    if (pH > 7.0) buffer.writeln("Lower pH with sulfur.");
    if (n < 15) buffer.writeln("Add nitrogen fertilizer.");
    if (p < 20) buffer.writeln("Add phosphorus.");
    if (k < 20) buffer.writeln("Add potassium.");
    if (buffer.isEmpty) buffer.write("Soil is in good condition.");
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.soilHealth),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (latest != null) _buildLatestCard(latest!, t),
            const SizedBox(height: 20),
            _buildEntryForm(t),
            const SizedBox(height: 16),
            _buildNavigationCards(t),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCard(SoilHealth data, AppLocalizations t) {
    final updated = DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(data.timestamp));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.latestSoilCondition, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("pH: ${data.pH.toStringAsFixed(2)}"),
                Text("N: ${data.nitrogen}"),
                Text("P: ${data.phosphorus}"),
                Text("K: ${data.potassium}"),
              ],
            ),
            Text("${t.status}: ${data.status}"),
            Text("${t.lastUpdated}: $updated"),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined, color: Colors.orange),
                const SizedBox(width: 6),
                Text(t.recommendation, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(data.recommendation),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.copy),
                label: Text(t.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.recommendation));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.copied)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryForm(AppLocalizations t) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(t.soilEntryTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              cropsLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                value: selectedCrop,
                onChanged: (value) => setState(() => selectedCrop = value),
                decoration: InputDecoration(labelText: t.crop),
                items: cropList.map((crop) => DropdownMenuItem(value: crop.name, child: Text(crop.name))).toList(),
                validator: (value) => value == null ? t.selectCrop : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(t.ph, pHController, const Icon(Icons.water_drop_outlined), isDecimal: true),
              _buildTextField(t.nitrogen, nController, const Icon(Icons.flash_on)),
              _buildTextField(t.phosphorus, pController, const Icon(Icons.local_florist)),
              _buildTextField(t.potassium, kController, const Icon(Icons.grass)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  onPressed: () => _submit(t),
                  label: Text(t.submit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Icon icon, {bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.trim().isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildNavigationCards(AppLocalizations t) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.lightGreen.shade50,
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: const Icon(Icons.analytics_outlined, size: 30, color: Colors.green),
            title: Text(t.latestSoilCondition, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(t.viewLatestCondition),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LatestSoilConditionScreen()));
            },
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.teal.shade50,
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: const Icon(Icons.history, size: 30, color: Colors.teal),
            title: Text(t.soilHealthHistory, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(t.viewPastEntries),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/soil-health-history'),
          ),
        ),
      ],
    );
  }
}
