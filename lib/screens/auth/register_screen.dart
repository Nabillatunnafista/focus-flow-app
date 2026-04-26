import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final err = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );
    
    if (!mounted) return;
    
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err, style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.accent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 160, 
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.school_rounded,
                      size: 90,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ayo Mulai Fokus!\nDaftar akun barumu.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 36),

                CustomInput(
                  label: 'Email',
                  hintText: 'Masukkan email anda',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                CustomInput(
                  label: 'Password',
                  hintText: 'Masukkan password (min. 8 karakter)',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _passCtrl,
                  isPassword: true,
                  obscureText: _obscurePass,
                  onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                    if (v.length < 8) return 'Minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                CustomInput(
                  label: 'Konfirmasi Password',
                  hintText: 'Ulangi password anda',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _confirmCtrl,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar'),
                ),
                const SizedBox(height: 20),

                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                    children: [
                      const TextSpan(text: 'Sudah punya akun?  '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.login),
                          child: Text(
                            'Masuk di sini',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}