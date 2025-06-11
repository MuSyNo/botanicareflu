import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_screen.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import '../app_colors.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LoginScreen({super.key, required this.onLocaleChange});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool rememberMe = false;
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() => rememberMe = true);
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() => isLoading = true);
    final t = AppLocalizations.of(context)!;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _saveCredentials();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = t.userNotFound;
          break;
        case 'wrong-password':
          message = t.wrongPassword;
          break;
        case 'invalid-email':
          message = t.invalidEmail;
          break;
        default:
          message = e.message ?? t.loginFailed;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.login} ${t.failed}: $message')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 32),
                SizedBox(
                  height: 100,
                  child: Image.asset(
                    'assets/logo.png',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.appTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.login,
                  style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildTextField(t.email, _emailController, TextInputType.emailAddress, Icons.email),
                const SizedBox(height: 16),
                _buildTextField(
                  t.password,
                  _passwordController,
                  TextInputType.text,
                  Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) => setState(() => rememberMe = val ?? false),
                    ),
                    Text(t.rememberMe),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                      ),
                      child: Text(
                        t.forgotPassword,
                        style: const TextStyle(color: AppColors.tealBlue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.leafGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      t.login,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.noAccount, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: Text(
                        t.register,
                        style: const TextStyle(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      TextInputType type,
      IconData icon, {
        bool isPassword = false,
      }) {
    return StatefulBuilder(
      builder: (context, setFieldState) => TextFormField(
        controller: controller,
        obscureText: isPassword && !showPassword,
        keyboardType: type,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setFieldState(() => showPassword = !showPassword),
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
        value == null || value.isEmpty ? '$label ${AppLocalizations.of(context)!.isRequired}' : null,
      ),
    );
  }
}
