import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Search Result Card ──
/// Sesuai slide 12 PPT: card dengan brand name, produk, status,
/// lokasi sekarang, dan badge jarak.
class SearchResultCard extends StatelessWidget {
  final String brandingName;
  final String produk;
  final String statusDagangan; // "ada" / "habis"
  final double jarakKm;
  final double latitude;
  final double longitude;
  final String? fotoProduk;
  final VoidCallback? onTap;
  final VoidCallback? onChat;
  final VoidCallback? onCall;
  final VoidCallback? onRoute;

  const SearchResultCard({
    super.key,
    required this.brandingName,
    required this.produk,
    required this.statusDagangan,
    required this.jarakKm,
    required this.latitude,
    required this.longitude,
    this.fotoProduk,
    this.onTap,
    this.onChat,
    this.onCall,
    this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isAda = statusDagangan == 'ada';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto produk / placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: fotoProduk != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fotoProduk!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.store, color: AppColors.textHint),
                      ),
                    )
                  : const Icon(Icons.store, color: AppColors.textHint),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand name
                  Text(
                    brandingName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Produk
                  Text(
                    produk,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Status
                  Text(
                    isAda ? 'Ada' : 'Habis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAda ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Row(
                    children: [
                      const Text(
                        'Lokasi Sekarang:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // Badge jarak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${jarakKm.toStringAsFixed(1)} KM',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
