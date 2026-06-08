// lib/screens/info/ikuti_kami_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

class IkutiKamiScreen extends StatelessWidget {
  const IkutiKamiScreen({super.key});

  final List<Map<String, dynamic>> _socialLinks = const [
    {
      'platform': 'Instagram',
      'handle': '@focusflow.app',
      'desc': 'Tips belajar, update fitur, & konten produktivitas',
      'icon': Icons.camera_alt_rounded,
      'color': Color(0xFFE1306C),
      'gradient': [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
    },
    {
      'platform': 'Twitter / X',
      'handle': '@focusflow_id',
      'desc': 'Update terbaru & diskusi seputar dunia perkuliahan',
      'icon': Icons.alternate_email_rounded,
      'color': Color(0xFF1DA1F2),
      'gradient': [Color(0xFF1DA1F2), Color(0xFF0d8ecf)],
    },
    {
      'platform': 'YouTube',
      'handle': 'FocusFlow Indonesia',
      'desc': 'Tutorial lengkap & video cara penggunaan aplikasi',
      'icon': Icons.play_circle_fill_rounded,
      'color': Color(0xFFFF0000),
      'gradient': [Color(0xFFFF0000), Color(0xFFcc0000)],
    },
    {
      'platform': 'TikTok',
      'handle': '@focusflow.id',
      'desc': 'Konten short produktivitas & hack belajar mahasiswa',
      'icon': Icons.music_note_rounded,
      'color': Color(0xFF010101),
      'gradient': [Color(0xFF010101), Color(0xFF69C9D0)],
    },
    {
      'platform': 'LinkedIn',
      'handle': 'FocusFlow App',
      'desc': 'Berita perusahaan & lowongan kerja tim FocusFlow',
      'icon': Icons.work_rounded,
      'color': Color(0xFF0077B5),
      'gradient': [Color(0xFF0077B5), Color(0xFF005885)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // ── Banner ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.diversity_3_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Bergabunglah dengan\nKomunitas FocusFlow!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ikuti kami di berbagai platform dan jadilah\nbagian dari ribuan mahasiswa produktif.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Platform Sosial Kami',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Social Cards ─────────────────────────────────
                  ..._socialLinks.map((s) => _SocialCard(data: s)),

                  const SizedBox(height: 24),

                  // ── Share App ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.share_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bagikan FocusFlow ke temanmu!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ajak teman-teman kuliah kamu untuk lebih produktif bersama FocusFlow.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(
                                text:
                                    'https://focusflow.gedangan.my.id'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Link berhasil disalin!',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'focusflow.gedangan.my.id',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Ikuti Kami',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social Card ──────────────────────────────────────────────
class _SocialCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SocialCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Color> gradient = List<Color>.from(data['gradient']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (data['color'] as Color).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    data['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['platform'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        data['handle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: data['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['desc'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
