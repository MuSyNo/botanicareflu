import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/crop.dart';
import '../app_colors.dart';
import '../utils/device_ip_scanner.dart';

class AddCropScreen extends StatefulWidget {
  final Crop? editCrop;

  const AddCropScreen({super.key, this.editCrop});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final ipController = TextEditingController();
  final customTypeController = TextEditingController();
  final customZoneController = TextEditingController();

  String? selectedType;
  String? selectedZone;

  final typeOptions = ['Vegetable', 'Herb', 'Fruit', 'Grain', 'Other'];
  final zoneOptions = ['Zone A', 'Zone B', 'Zone C', 'Other'];

  bool get isOtherType => selectedType == 'Other';
  bool get isOtherZone => selectedZone == 'Other';

  @override
  void initState() {
    super.initState();
    if (widget.editCrop != null) {
      final crop = widget.editCrop!;
      nameController.text = crop.name;
      descController.text = crop.description ?? '';
      ipController.text = crop.deviceIp ?? '';
      selectedType = typeOptions.contains(crop.type) ? crop.type : 'Other';
      if (isOtherType) customTypeController.text = crop.type;
      selectedZone = zoneOptions.contains(crop.zone) ? crop.zone : 'Other';
      if (isOtherZone) customZoneController.text = crop.zone;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final name = nameController.text.trim();
    final type = isOtherType ? customTypeController.text.trim() : selectedType!;
    final zone = isOtherZone ? customZoneController.text.trim() : selectedZone!;
    final description = descController.text.trim();
    final deviceIp = ipController.text.trim();

    final cropMap = {
      'name': name,
      'type': type,
      'zone': zone,
      if (description.isNotEmpty) 'description': description,
      if (deviceIp.isNotEmpty) 'deviceIp': deviceIp,
    };

    final cropsRef = FirebaseFirestore.instance
        .collection('plants')
        .doc(uid)
        .collection('crops');

    if (widget.editCrop == null) {
      await cropsRef.add(cropMap);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🌱 Crop added successfully")),
      );
    } else {
      await cropsRef.doc(widget.editCrop!.id).update(cropMap);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Crop updated successfully")),
      );
    }

    Navigator.pop(context);
  }

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split('.');
    if (parts.length != 4) return 'Invalid IP address';
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return 'Invalid IP address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editCrop != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Crop" : "Add Crop"),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Crop Name", nameController, required: true),
              _buildDropdownField("Crop Type", typeOptions, selectedType, (val) {
                setState(() => selectedType = val);
              }),
              if (isOtherType)
                _buildTextField("Custom Type", customTypeController, required: true),
              _buildDropdownField("Zone", zoneOptions, selectedZone, (val) {
                setState(() => selectedZone = val);
              }),
              if (isOtherZone)
                _buildTextField("Custom Zone", customZoneController, required: true),
              _buildTextField("Optional Description", descController),
              _buildTextField("ESP32 Device IP", ipController, validator: _validateIp),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🔍 Scanning network...")),
                    );
                    final foundIp = await scanForEsp32Device();

                    if (!mounted) return;

                    if (foundIp != null) {
                      ipController.text = foundIp;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("✅ Device found at $foundIp")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ Device not found.")),
                      );
                    }
                  },
                  icon: const Icon(Icons.wifi_find),
                  label: const Text("Scan for ESP32"),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  onPressed: _submit,
                  label: Text(isEditing ? "Update Crop" : "Save Crop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) {
          if (required && (val == null || val.trim().isEmpty)) {
            return "$label is required";
          }
          return validator != null ? validator(val) : null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, String? value, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    ipController.dispose();
    customTypeController.dispose();
    customZoneController.dispose();
    super.dispose();
  }
}
