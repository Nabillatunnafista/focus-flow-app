import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi Animasi Logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // 2. Langsung jalankan navigasi tunggal
    _startApp();
  }

  Future<void> _startApp() async {
    // Tunggu sebentar agar user bisa lihat logo & animasi loading (misal 3 detik)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Cek status login di background
    final auth = context.read<AuthService>();
    final loggedIn = await auth.tryAutoLogin();

    if (!mounted) return;

    // Pindah ke halaman berikutnya (Hanya SEKALI pindah)
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Warna background SplashScreen
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo Burung Hantu ──────────────────────
                Image.asset(
                  'assets/images/logo.png',
                  width: 200, 
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const _OwlPlaceholder(),
                ),
                const SizedBox(height: 20),
                // ── Nama Aplikasi ──────────────────────────
                Text(
                  'FOCUS FLOW',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // ── Animasi Teks Loading... ────────────────
                const _LoadingText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget animasi titik-titik (Loading...)
class _LoadingText extends StatefulWidget {
  const _LoadingText();
  @override
  State<_LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<_LoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotController.addListener(() {
      int newCount = (_dotController.value * 4).toInt();
      if (newCount != _dotCount) {
        setState(() => _dotCount = newCount);
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Loading${'.' * _dotCount}',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),
    );
  }
}

class _OwlPlaceholder extends StatelessWidget {
  const _OwlPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.school_rounded, size: 52, color: AppColors.primary),
    );
  }
}