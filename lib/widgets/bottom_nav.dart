// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';
import '../core/theme.dart';

class FocusFlowBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;
  final bool showFab;

  const FocusFlowBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
    this.showFab = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.bottom > 0 ? 96 : 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── BACKGROUND NAVBAR DENGAN LEKUKAN HALUS TENGAH & PINGGIR FLAT ──
          Positioned.fill(
            top: 12,
            child: CustomPaint(
              painter: _SmoothNotchFlatEdgePainter(),
              child: SafeArea(
                top: false,
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Beranda',
                        index: 0,
                        currentIndex: currentIndex,
                        onTap: onTap,
                      ),
                      _NavItem(
                        icon: Icons.fact_check_outlined,
                        label: 'Tugas',
                        index: 1,
                        currentIndex: currentIndex,
                        onTap: onTap,
                      ),
                      
                      const SizedBox(width: 68), // Spacer area kosong tengah

                      _NavItem(
                        icon: Icons.calendar_month_outlined,
                        label: 'Kalender',
                        index: 2,
                        currentIndex: currentIndex,
                        onTap: onTap,
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profil',
                        index: 3,
                        currentIndex: currentIndex,
                        onTap: onTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── TOMBOL FLOATING ACTION BUTTON (FAB) MELAYANG PERFECT ──
          if (showFab)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onFabPressed,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.45),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.45),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SENI MATEMATIKA: LEKUKAN TENGAH HALUS & PINGGIRAN FLAT LURUS TEPAT ───
class _SmoothNotchFlatEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();

    // Mulai langsung dari titik (0,0) di kiri atas secara lurus flat tanpa radius lengkungan
    path.moveTo(0, 0);

    final double center = size.width / 2;
    const double notchWidth = 84.0; 
    const double notchHeight = 34.0;

    final double startX = center - (notchWidth / 2);
    final double endX = center + (notchWidth / 2);

    // Garis lurus horizontal dari pojok kiri menuju awal lekukan tengah
    path.lineTo(startX, 0);

    // Membuat lengkungan transisi turun ke tengah bawah secara smooth (Cubic Bezier)
    path.cubicTo(
      startX + (notchWidth * 0.18), 0,
      startX + (notchWidth * 0.12), notchHeight,
      startX + (notchWidth * 0.40), notchHeight,
    );
    
    // Dasar rata dasar lekukan
    path.lineTo(endX - (notchWidth * 0.40), notchHeight);

    // Lengkungan naik kembali ke kanan atas secara simetris halus
    path.cubicTo(
      endX - (notchWidth * 0.12), notchHeight,
      endX - (notchWidth * 0.18), 0,
      endX, 0,
    );

    // Garis lurus mendatar sampai ke ujung pojok kanan atas murni lurus flat
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Menggambar efek bayangan halus mengikuti bentuk path flat edge ini
    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 8.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}