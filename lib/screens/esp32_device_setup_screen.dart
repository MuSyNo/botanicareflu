import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../app_colors.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

class ESP32DeviceSetupScreen extends StatefulWidget {
  const ESP32DeviceSetupScreen({super.key});

  @override
  State<ESP32DeviceSetupScreen> createState() => _ESP32DeviceSetupScreenState();
}

class _ESP32DeviceSetupScreenState extends State<ESP32DeviceSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _cropNameController = TextEditingController();
  final _zoneController = TextEditingController();

  bool _saving = false;

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _saving = false);
      return;
    }

    final ref = FirebaseDatabase.instance.ref("plants/$uid/crops").push();

    await ref.set({
      "name": _cropNameController.text.trim(),
      "zone": _zoneController.text.trim(),
      "deviceIp": _ipController.text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Device added successfully.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _cropNameController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.addCrop),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(t.cropName, _cropNameController, TextInputType.text),
              _buildTextField(t.zone, _zoneController, TextInputType.text),
              _buildTextField(
                "ESP32 Device IP (e.g. 192.168.4.1)",
                _ipController,
                TextInputType.text,
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
                  onPressed: _saving ? null : _saveDevice,
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? t.saving : t.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      TextInputType inputType, {
        FormFieldValidator<String>? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        validator: validator ??
                (value) =>
            value == null || value.trim().isEmpty ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
