// lib/screens/info/tentang_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  static const _appVersion = '1.0.0';
  static const _buildNumber = '1';

  final List<Map<String, String>> _teamMembers = const [
    {
      'name': 'Syahrul',
      'role': 'Project Owner & Backend Integration',
      'initials': 'SY',
    },
    {
      'name': 'Angel',
      'role': 'Scrum Master & Frontend UI Layout',
      'initials': 'AN',
    },
    {
      'name': 'Alsahera',
      'role': 'Frontend Developer - UI Slicing',
      'initials': 'AL',
    },
    {
      'name': 'Nafista',
      'role': 'Frontend Developer - API Integration',
      'initials': 'NA',
    },
    {
      'name': 'Gavin',
      'role': 'Backend Developer - REST API & Auth',
      'initials': 'GA',
    },
    {
      'name': 'Agis',
      'role': 'Backend Developer - Push Notif & Cloud',
      'initials': 'AG',
    },
  ];

  final List<Map<String, dynamic>> _techStack = const [
    {
      'name': 'Flutter',
      'desc': 'Framework UI cross-platform',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF54C5F8),
    },
    {
      'name': 'Go (Golang)',
      'desc': 'Backend REST API',
      'icon': Icons.dns_rounded,
      'color': Color(0xFF00ACD7),
    },
    {
      'name': 'PostgreSQL',
      'desc': 'Database relasional',
      'icon': Icons.storage_rounded,
      'color': Color(0xFF336791),
    },
    {
      'name': 'Provider',
      'desc': 'State management Flutter',
      'icon': Icons.hub_rounded,
      'color': Color(0xFF9B7EBD),
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
                  // ── App Identity Card ────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6B3FA0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FocusFlow',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Smart Study Planner for Students',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Versi $_appVersion (Build $_buildNumber)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Deskripsi ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Tentang Aplikasi',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'FocusFlow adalah aplikasi manajemen tugas dan belajar yang dirancang khusus untuk mahasiswa. Dengan FocusFlow, kamu bisa mengatur jadwal kuliah, deadline tugas, dan kalender akademik dalam satu platform yang mudah digunakan.\n\nDibuat dengan ❤️ untuk membantu mahasiswa tetap fokus, terorganisir, dan produktif sepanjang semester.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Tim Developer ────────────────────────────────
                  _SectionLabel(label: 'Tim Developer'),
                  const SizedBox(height: 12),
                  ..._teamMembers.map((m) => _TeamCard(member: m)),

                  const SizedBox(height: 16),

                  // ── Tech Stack ───────────────────────────────────
                  _SectionLabel(label: 'Teknologi yang Digunakan'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    children: _techStack
                        .map((t) => _TechCard(tech: t))
                        .toList(),
                  ),

                  const SizedBox(height: 16),

                  // ── Legal ────────────────────────────────────────
                  _SectionLabel(label: 'Legal'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _LegalItem(
                          icon: Icons.gavel_rounded,
                          label: 'Syarat & Ketentuan',
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _LegalItem(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Kebijakan Privasi',
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Copyright ────────────────────────────────────
                  Center(
                    child: Text(
                      '© 2025 FocusFlow. All rights reserved.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Made with ❤️ in Indonesia',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
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
            'Tentang',
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

// ── Section Label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

// ── Team Member Card ─────────────────────────────────────────
class _TeamCard extends StatelessWidget {
  final Map<String, String> member;
  const _TeamCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                member['initials']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member['name']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                member['role']!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tech Stack Card ──────────────────────────────────────────
class _TechCard extends StatelessWidget {
  final Map<String, dynamic> tech;
  const _TechCard({required this.tech});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (tech['color'] as Color).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (tech['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tech['icon'] as IconData,
              color: tech['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tech['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  tech['desc'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legal Item ───────────────────────────────────────────────
class _LegalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _LegalItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
