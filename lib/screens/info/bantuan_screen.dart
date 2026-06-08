// lib/screens/info/bantuan_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  int? _expandedIndex;
  final _feedbackCtrl = TextEditingController();
  bool _feedbackSent = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara menambahkan tugas baru?',
      'a':
          'Buka halaman Beranda, lalu tap tombol "+ Tambah Tugas" di bagian bawah layar. Isi judul, deadline, dan mata kuliah, kemudian simpan.',
    },
    {
      'q': 'Apakah data saya tersimpan secara online?',
      'a':
          'Ya! Data tugas dan akun kamu tersimpan di server kami secara aman. Kamu bisa login dari perangkat lain dan data akan tetap tersedia.',
    },
    {
      'q': 'Bagaimana cara mengubah foto profil?',
      'a':
          'Buka halaman Profil → Edit Profil. Tap ikon kamera di atas foto profil kamu, lalu pilih gambar dari galeri atau ambil foto baru.',
    },
    {
      'q': 'Apakah FocusFlow bisa digunakan offline?',
      'a':
          'Untuk saat ini FocusFlow memerlukan koneksi internet untuk menyinkronkan data. Fitur offline sedang dalam pengembangan.',
    },
    {
      'q': 'Bagaimana cara mengaktifkan notifikasi deadline?',
      'a':
          'Saat menambahkan deadline, kamu bisa mengatur pengingat (reminder) dalam waktu tertentu sebelum deadline. Pastikan izin notifikasi sudah diaktifkan di pengaturan HP kamu.',
    },
    {
      'q': 'Bagaimana cara menghapus akun saya?',
      'a':
          'Untuk menghapus akun, silakan hubungi tim support kami melalui email di focusflow.support@gmail.com dengan subjek "Hapus Akun".',
    },
  ];

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _sendFeedback() {
    if (_feedbackCtrl.text.trim().isEmpty) return;
    setState(() {
      _feedbackSent = true;
      _feedbackCtrl.clear();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _feedbackSent = false);
    });
  }

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
                  // ── FAQ Section ──────────────────────────────────
                  _SectionTitle(icon: Icons.quiz_rounded, title: 'Pertanyaan Umum (FAQ)'),
                  const SizedBox(height: 12),
                  ...List.generate(_faqs.length, (i) => _FAQItem(
                    question: _faqs[i]['q']!,
                    answer: _faqs[i]['a']!,
                    isExpanded: _expandedIndex == i,
                    onTap: () => setState(
                      () => _expandedIndex = _expandedIndex == i ? null : i,
                    ),
                  )),

                  const SizedBox(height: 28),

                  // ── Feedback Section ─────────────────────────────
                  _SectionTitle(icon: Icons.rate_review_rounded, title: 'Kirim Umpan Balik'),
                  const SizedBox(height: 12),
                  Container(
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ada saran atau masalah? Ceritakan ke kami!',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _feedbackCtrl,
                          maxLines: 4,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Tulis pesan kamu di sini...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEDE9F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_feedbackSent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Terima kasih! Umpan balik kamu terkirim.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _sendFeedback,
                              icon: const Icon(Icons.send_rounded, size: 16),
                              label: Text(
                                'Kirim Umpan Balik',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Contact Section ──────────────────────────────
                  _SectionTitle(icon: Icons.contact_support_rounded, title: 'Hubungi Kami'),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Icons.email_outlined,
                    label: 'Email Support',
                    value: 'focusflow.support@gmail.com',
                    color: const Color(0xFF4285F4),
                  ),
                  const SizedBox(height: 8),
                  _ContactItem(
                    icon: Icons.access_time_rounded,
                    label: 'Jam Operasional',
                    value: 'Senin – Jumat, 08.00 – 17.00 WIB',
                    color: AppColors.secondary,
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
            'Bantuan & Umpan Balik',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ── FAQ Accordion Item ───────────────────────────────────────
class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
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
        border: Border.all(
          color: isExpanded
              ? AppColors.secondary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(
                  answer,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact Item ─────────────────────────────────────────────
class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
