import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import '../app_colors.dart';
import '../gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.agreeTermsNotice)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      final uid = authResult.user?.uid;
      if (uid != null) {
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'joinedAt': DateTime.now().millisecondsSinceEpoch,
        };
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? t.registrationFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.register} ${t.failed}: $message')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.createAccount),
        backgroundColor: AppColors.forestGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset(
                'assets/logo.png',
                height: 90,
                errorBuilder: (_, __, ___) => const Icon(Icons.agriculture, size: 60, color: AppColors.forestGreen),
              ),
              const SizedBox(height: 16),
              Text(t.register, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
              const SizedBox(height: 8),
              Text(t.registerSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
              const SizedBox(height: 24),

              _buildTextField(controller: _nameController, label: t.fullName, icon: Icons.person),
              _buildTextField(controller: _emailController, label: t.email, icon: Icons.email, inputType: TextInputType.emailAddress),
              _buildTextField(controller: _passwordController, label: t.password, icon: Icons.lock, isPassword: true),
              _buildTextField(controller: _confirmPasswordController, label: t.confirmPassword, icon: Icons.lock_outline, isPassword: true),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.passwordHint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (v) => setState(() => agreeToTerms = v ?? false),
                  ),
                  Expanded(child: Text(t.agreeTermsLabel)),
                ],
              ),

              const SizedBox(height: 12),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(t.register.toUpperCase(), style: const TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.alreadyHaveAccount, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen(onLocaleChange: (_) {})),
                    ),
                    child: Text(t.login, style: const TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "$label ${t.isRequired}";
          if (label == t.password && value.length < 6) return t.passwordTooShort;
          if (label == t.confirmPassword && value != _passwordController.text) return t.passwordMismatch;
          return null;
        },
      ),
    );
  }
}
