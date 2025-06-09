import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../screens/add_crop_screen.dart';
import '../app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/mqtt_service.dart';
import '../widgets/weather_card.dart';
import 'chatbot_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final mqtt = MqttService();
  String soilMoisture = '--';
  String batteryLevel = '--';
  Map<String, dynamic>? latestSoilHealth;

  bool mqttConnected = false;
  bool esp32Connected = false;
  bool checkingESP32 = false;
  String esp32Ip = 'http://192.168.4.1';

  @override
  void initState() {
    super.initState();
    _initMqtt();
    _checkESP32Connection();
    _fetchLatestSoilHealth();
  }

  Future<void> _fetchLatestSoilHealth() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseDatabase.instance.ref("soil_health_entries/$uid/latest");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        latestSoilHealth = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  Future<void> _initMqtt() async {
    mqtt.onMessageReceived = (topic, msg) {
      setState(() {
        if (topic.contains('soil_moisture')) {
          soilMoisture = '$msg %';
        } else if (topic.contains('battery')) {
          batteryLevel = '$msg %';
        }
      });
    };

    await mqtt.connect();
    setState(() => mqttConnected = mqtt.isConnected);
  }

  Future<void> _checkESP32Connection() async {
    setState(() => checkingESP32 = true);
    final prefs = await SharedPreferences.getInstance();
    esp32Ip = prefs.getString('esp32_ip') ?? 'http://192.168.4.1';

    try {
      final response = await http.get(Uri.parse(esp32Ip)).timeout(const Duration(seconds: 3));
      setState(() => esp32Connected = response.statusCode == 200);
    } catch (_) {
      setState(() => esp32Connected = false);
    } finally {
      setState(() => checkingESP32 = false);
    }
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.dashboard),
        backgroundColor: AppColors.forestGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: t.notifications,
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              FirebaseDatabase.instance.ref("notifications/$uid").push().set({
                'title': "Test Alert",
                'body': "This is a simulated test notification.",
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'read': false,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Test notification sent.")),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConnectionStatus("MQTT", mqttConnected),
            const SizedBox(height: 8),
            _buildConnectionStatus("ESP32", esp32Connected, retry: _checkESP32Connection, loading: checkingESP32),
            const SizedBox(height: 12),
            const WeatherCard(),
            const SizedBox(height: 12),
            _buildSensorCard(Icons.water_drop, t.soilHealth, soilMoisture, AppColors.forestGreen),
            _buildSensorCard(Icons.battery_std, "Battery", batteryLevel, Colors.orange),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: mqttConnected ? () => mqtt.publishValveCommand('1') : null,
              icon: const Icon(Icons.water),
              label: Text(t.irrigateNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            _buildChatbotCard(),
            _buildDashboardCard(
              icon: Icons.add_circle_outline,
              title: "Add Crop",
              subtitle: "Register a new crop and link to an ESP32 device",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropScreen())),
            ),
            _buildDashboardCard(
              icon: Icons.dashboard_customize_outlined,
              title: "Crop Dashboards",
              subtitle: "View individual dashboards for each crop",
              onTap: () => Navigator.pushNamed(context, '/crop-dashboards'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCropScreen())),
        backgroundColor: AppColors.forestGreen,
        child: const Icon(Icons.add),
        tooltip: "Add Crop",
      ),
    );
  }

  Widget _buildConnectionStatus(String label, bool connected, {VoidCallback? retry, bool loading = false}) {
    return Row(
      children: [
        Icon(connected ? Icons.check_circle : Icons.cancel, color: connected ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text("$label: ${connected ? "Connected" : "Disconnected"}", style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        if (retry != null)
          ElevatedButton(
            onPressed: loading ? null : retry,
            child: loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Retry"),
          )
      ],
    );
  }

  Widget _buildSensorCard(IconData icon, String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value, style: TextStyle(fontSize: 16, color: color)),
      ),
    );
  }

  Widget _buildChatbotCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.chat_bubble_outline, size: 36, color: AppColors.forestGreen),
        title: const Text("Need Plant Care Help?"),
        subtitle: const Text("Ask the BotaniCare Assistant for advice"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green.shade50,
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(icon, size: 30, color: AppColors.forestGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
