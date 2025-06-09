import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../app_colors.dart';
import '../gen_l10n/app_localizations.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseDatabase.instance.ref("users/$uid/profile").get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final t = AppLocalizations.of(context)!;

    try {
      await FirebaseDatabase.instance.ref("users/$uid/profile").update({
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.updateAccount)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.update} failed: $e")),
      );
    }
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    final t = AppLocalizations.of(context)!;

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.password} must be at least 6 characters")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.resetPassword)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${t.update} password failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.accountSettings),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t.accountSettings),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                value == null || value.trim().length < 3
                    ? "${t.update}: name too short"
                    : null,
              ),

              /// Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: t.phone),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                value == null || value.trim().length < 7
                    ? "Invalid phone number"
                    : null,
              ),

              /// Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: t.address),
                textInputAction: TextInputAction.done,
                validator: (value) =>
                value == null || value.isEmpty ? "${t.address} is required" : null,
              ),

              const SizedBox(height: 20),

              /// Save profile button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(t.save),
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                ),
              ),

              const Divider(height: 40),

              /// New password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: t.password),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 10),

              /// Change password button
              ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                label: Text(t.resetPassword),
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
