import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/crop.dart';
import '../app_colors.dart';
import '../services/mqtt_service.dart';
import '../utils/offline_log_helper.dart';

class CropDashboardScreen extends StatefulWidget {
  const CropDashboardScreen({super.key});

  @override
  State<CropDashboardScreen> createState() => _CropDashboardScreenState();
}

class _CropDashboardScreenState extends State<CropDashboardScreen> with TickerProviderStateMixin {
  List<Crop> crops = [];
  TabController? _tabController;

  final Map<String, MqttService> mqttMap = {};
  final Map<String, String> moisture = {};
  final Map<String, String> battery = {};
  final Map<String, DateTime> lastUpdate = {};
  final Map<String, String> responseMsg = {};

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('plants')
        .doc(uid)
        .collection('crops')
        .get();

    setState(() {
      crops = snapshot.docs.map((doc) => Crop.fromMap(doc.id, doc.data())).toList();
      _tabController = TabController(length: crops.length, vsync: this);

      for (final crop in crops) {
        final mqtt = MqttService();

        mqtt.onMessageReceived = (topic, msg) {
          final now = DateTime.now();
          if (topic.contains("soil_moisture/${crop.id}")) {
            setState(() {
              moisture[crop.id] = "$msg %";
              lastUpdate[crop.id] = now;
            });
          } else if (topic.contains("battery/${crop.id}")) {
            setState(() {
              battery[crop.id] = "$msg %";
              lastUpdate[crop.id] = now;
            });
          } else if (topic.contains("response/${crop.id}")) {
            setState(() {
              responseMsg[crop.id] = msg;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ESP32: $msg")));
          }
        };

        mqtt.connect(topics: [
          "irrigation/sensors/soil_moisture/${crop.id}",
          "irrigation/system/battery/${crop.id}",
          "irrigation/response/${crop.id}",
        ]);

        mqttMap[crop.id] = mqtt;
      }
    });
  }

  @override
  void dispose() {
    for (final mqtt in mqttMap.values) {
      mqtt.disconnect();
    }
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Dashboards"),
        backgroundColor: AppColors.forestGreen,
        bottom: crops.isEmpty
            ? null
            : TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: crops.map((c) => Tab(text: c.name)).toList(),
        ),
      ),
      body: crops.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: crops.map((crop) {
          final last = lastUpdate[crop.id];
          final updateLabel = last != null
              ? "Last updated: ${last.hour.toString().padLeft(2, '0')}:${last.minute.toString().padLeft(2, '0')}"
              : "Awaiting data...";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Zone: ${crop.zone}", style: const TextStyle(fontSize: 16)),
                Text("Type: ${crop.type}"),
                const SizedBox(height: 16),
                Text("Soil Moisture: ${moisture[crop.id] ?? '--'}", style: const TextStyle(fontSize: 16)),
                Text("Battery: ${battery[crop.id] ?? '--'}"),
                const SizedBox(height: 4),
                Text(updateLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final mqtt = mqttMap[crop.id];
                        if (mqtt != null && mqtt.isConnected) {
                          mqtt.publishValveCommand('1');
                        } else {
                          await OfflineLogSync.saveLog({
                            "type": "irrigation",
                            "crop": crop.name,
                            "zone": crop.zone,
                            "timestamp": DateTime.now().toIso8601String(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Log saved locally. Will sync when back online.")),
                          );
                        }
                      },
                      icon: const Icon(Icons.water),
                      label: const Text("Irrigate Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final mqtt = mqttMap[crop.id];
                        if (mqtt != null && mqtt.isConnected) {
                          mqtt.publish("irrigation/calibrate/${crop.id}", "start");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Calibration started.")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("ESP32 not connected.")),
                          );
                        }
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text("Calibrate"),
                    ),
                  ],
                ),
                if (responseMsg[crop.id] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "ESP32 Says: ${responseMsg[crop.id]}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
