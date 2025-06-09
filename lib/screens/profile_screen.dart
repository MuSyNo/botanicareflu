import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref();
  String? uid;

  bool isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid;
    _emailController.text = user?.email ?? '';
    _loadProfile();
    _loadPreferences();
  }

  Future<void> _loadProfile() async {
    if (uid == null) return;
    final snapshot = await dbRef.child('users/$uid/profile').get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode', _darkMode);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || uid == null) return;

    setState(() => isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      await dbRef.child('users/$uid/profile').update(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.saveFailed}: $e")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.changePasswordNotice)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.profile),
        backgroundColor: AppColors.forestGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(t.fullName, _nameController, TextInputType.name),
              _buildTextField(t.email, _emailController, TextInputType.emailAddress, enabled: false),
              _buildTextField(t.phone, _phoneController, TextInputType.phone),
              _buildTextField(t.address, _addressController, TextInputType.streetAddress),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(t.enableNotifications),
                value: _notificationsEnabled,
                onChanged: (val) {
                  if (_notificationsEnabled != val) {
                    setState(() => _notificationsEnabled = val);
                    _savePreferences();
                  }
                },
              ),
              SwitchListTile(
                title: Text(t.darkMode),
                value: _darkMode,
                onChanged: (val) {
                  if (_darkMode != val) {
                    setState(() => _darkMode = val);
                    _savePreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.restartAppToApply)),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: Text(t.saveProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock_outline),
                label: Text(t.changePassword),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.leafGreen,
                  side: const BorderSide(color: AppColors.leafGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(48),
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
        bool enabled = true,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: inputType,
        validator: (value) => value == null || value.isEmpty ? '$label ${AppLocalizations.of(context)!.isRequired}' : null,
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
