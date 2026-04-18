import 'package:flutter/material.dart';
import '../core/theme.dart';

class FocusFlowBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;

  const FocusFlowBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85, // Sedikit ditinggikan agar proporsional
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background Bar dengan Lekukan Benar ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 70),
              painter: _BNBCustomPainter(),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      index: 0,
                      currentIndex: currentIndex,
                      onTap: onTap,
                      showIndicator: true, // Untuk garis bawah di icon home
                    ),
                    _NavItem(
                      icon: Icons.assignment_outlined, // Sesuai UI: Ikon list/assignment
                      index: 1,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),
                    const SizedBox(width: 80), // Ruang kosong untuk FAB
                    _NavItem(
                      icon: Icons.calendar_today_outlined,
                      index: 2,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      index: 3,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating Action Button (Plus) ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onFabPressed,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 40,
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
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showIndicator;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.showIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          ),
          if (showIndicator && isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 14,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}

class _BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0); // Start top left
    
    // Lekukan (Notch) di tengah
    path.lineTo(size.width * 0.32, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 12);
    path.arcToPoint(
      Offset(size.width * 0.60, 12),
      radius: const Radius.circular(25.0),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.68, 0);
    
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}