import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/crop.dart';
import '../screens/add_crop_screen.dart'; // Dart is case-sensitive
import '../app_colors.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  List<Crop> crops = [];
  Map<String, bool> onlineStatus = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('plants')
        .doc(uid)
        .collection('crops')
        .get();

    final list = snapshot.docs.map((doc) => Crop.fromMap(doc.id, doc.data())).toList();

    setState(() {
      crops = list;
      loading = false;
    });

    for (final crop in list) {
      _checkDeviceStatus(crop);
    }
  }

  Future<void> _checkDeviceStatus(Crop crop) async {
    final ip = crop.deviceIp;
    if (ip == null || ip.isEmpty) return;

    try {
      final response = await http
          .get(Uri.parse('http://$ip/ping'))
          .timeout(const Duration(seconds: 2));

      setState(() {
        onlineStatus[crop.id] = response.statusCode == 200;
      });
    } catch (_) {
      setState(() {
        onlineStatus[crop.id] = false;
      });
    }
  }

  Future<void> _deleteCrop(Crop crop) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('plants')
        .doc(uid)
        .collection('crops')
        .doc(crop.id)
        .delete();

    setState(() {
      crops.remove(crop);
      onlineStatus.remove(crop.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Crop deleted")),
    );
  }

  Future<void> _editCrop(Crop crop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCropScreen(editCrop: crop)),
    );
    _loadCrops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Crops"),
        backgroundColor: AppColors.forestGreen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : crops.isEmpty
          ? const Center(child: Text("No crops added yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          final isOnline = onlineStatus[crop.id];

          return Dismissible(
            key: Key(crop.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteCrop(crop),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  crop.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Type: ${crop.type} • Zone: ${crop.zone}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (crop.deviceIp != null && crop.deviceIp!.isNotEmpty)
                      GestureDetector(
                        onTap: () => _checkDeviceStatus(crop),
                        child: Tooltip(
                          message: isOnline == true
                              ? "Online (${crop.deviceIp})"
                              : "Offline (${crop.deviceIp})",
                          child: Icon(
                            isOnline == true ? Icons.wifi : Icons.wifi_off,
                            color: isOnline == true ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit crop",
                      onPressed: () => _editCrop(crop),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.forestGreen,
        tooltip: "Add Crop",
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCropScreen()),
          );
          _loadCrops();
        },
      ),
    );
  }
}
