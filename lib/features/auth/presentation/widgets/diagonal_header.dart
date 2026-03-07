// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── DiagonalHeader ──
/// Reusable diagonal header widget.
/// Dipakai di Login, Register Step 1, Register Step 3, dll.
///
/// Usage:
/// ```dart
/// DiagonalHeader(
///   title: 'Registrasi',
///   subtitle: 'Lengkapi data diri Anda',
/// )
/// ```
class DiagonalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final bool showBackButton;
  final VoidCallback? onBack;

  const DiagonalHeader({
    super.key,
    this.title = 'OHIA',
    this.subtitle = 'Temukan yang kamu cari',
    this.height = 200,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // Background diagonal
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _DiagonalPainter(),
          ),

          // Back button (optional)
          if (showBackButton)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              ),
            ),

          // Konten header di tengah
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 90,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/ohia-logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback kalau logo belum ada
                        return const Text(
                          'O',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter diagonal ──
class _DiagonalPainter extends CustomPainter {
  final double borderRadius;

  _DiagonalPainter({this.borderRadius = 32});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Bagian ungu
    paint.color = AppColors.accent;
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 1, 0)
      ..lineTo(0, size.height - borderRadius)
      ..close();
    canvas.drawPath(path1, paint);

    // Bagian orange
    paint.color = AppColors.primary;
    final path2 = Path()
      ..moveTo(size.width * 1, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - borderRadius)
      ..quadraticBezierTo(
        size.width, size.height,
        size.width - borderRadius, size.height,
      )
      ..lineTo(borderRadius, size.height)
      ..quadraticBezierTo(
        0, size.height,
        0, size.height - borderRadius,
      )
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
