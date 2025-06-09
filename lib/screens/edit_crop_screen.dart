import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../app_colors.dart';

class EditCropScreen extends StatefulWidget {
  final String cropId;
  final Map<String, dynamic> cropData;

  const EditCropScreen({super.key, required this.cropId, required this.cropData});

  @override
  State<EditCropScreen> createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cropNameController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _customZoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deviceIpController = TextEditingController();

  String _selectedType = '';
  String _selectedZone = '';

  final List<String> cropTypes = ['Vegetable', 'Fruit', 'Herb', 'Other'];
  final List<String> zones = ['Zone 1', 'Zone 2', 'Zone 3', 'Other'];

  @override
  void initState() {
    super.initState();
    final data = widget.cropData;
    _cropNameController.text = data['name'] ?? '';
    _selectedType = cropTypes.contains(data['type']) ? data['type'] : 'Other';
    _selectedZone = zones.contains(data['zone']) ? data['zone'] : 'Other';
    _customTypeController.text = _selectedType == 'Other' ? data['type'] ?? '' : '';
    _customZoneController.text = _selectedZone == 'Other' ? data['zone'] ?? '' : '';
    _descriptionController.text = data['description'] ?? '';
    _deviceIpController.text = data['deviceIp'] ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == 'Other' && _customTypeController.text.trim().isEmpty) {
      _showSnackBar("Please specify a custom crop type");
      return;
    }

    if (_selectedZone == 'Other' && _customZoneController.text.trim().isEmpty) {
      _showSnackBar("Please specify a custom zone");
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final updatedCrop = {
      "name": _cropNameController.text.trim(),
      "type": _selectedType == "Other" ? _customTypeController.text.trim() : _selectedType,
      "zone": _selectedZone == "Other" ? _customZoneController.text.trim() : _selectedZone,
      "description": _descriptionController.text.trim(),
      "deviceIp": _deviceIpController.text.trim(),
      "updated": DateTime.now().millisecondsSinceEpoch,
    };

    await FirebaseDatabase.instance
        .ref("plants/$userId/crops/${widget.cropId}")
        .update(updatedCrop);

    if (context.mounted) {
      _showSnackBar("Crop updated successfully");
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Crop"),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cropNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Crop Name"),
                validator: (value) => value == null || value.trim().isEmpty ? "Crop name is required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Crop Type"),
                items: cropTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedType = value ?? 'Other'),
              ),
              if (_selectedType == 'Other')
                TextFormField(
                  controller: _customTypeController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Custom Crop Type"),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? "Please specify crop type" : null,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedZone,
                decoration: const InputDecoration(labelText: "Zone"),
                items: zones.map((zone) => DropdownMenuItem(value: zone, child: Text(zone))).toList(),
                onChanged: (value) => setState(() => _selectedZone = value ?? 'Other'),
              ),
              if (_selectedZone == 'Other')
                TextFormField(
                  controller: _customZoneController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Custom Zone"),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? "Please specify zone" : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Description (optional)"),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceIpController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: "ESP32 Device IP"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "ESP32 IP is required";
                  }

                  final ipRegex = RegExp(
                      r'^((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$');
                  if (!ipRegex.hasMatch(value.trim())) {
                    return "Enter a valid IP (e.g. 192.168.1.100)";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text("Update Crop"),
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

  @override
  void dispose() {
    _cropNameController.dispose();
    _customTypeController.dispose();
    _customZoneController.dispose();
    _descriptionController.dispose();
    _deviceIpController.dispose();
    super.dispose();
  }
}
