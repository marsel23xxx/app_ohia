import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Pembagi Detail Screen ──
/// Sesuai slide 13 PPT: Header kategori, info pedagang, action buttons
/// (Menu, Telpon, Chat, SMS, Rute), dan Google Map.
///
/// Dependencies (tambahkan di pubspec.yaml):
///   google_maps_flutter: ^2.9.0
///   url_launcher: ^6.3.1
///
/// Setup Google Maps:
/// Android → android/app/src/main/AndroidManifest.xml:
///   <meta-data android:name="com.google.android.geo.API_KEY"
///              android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
/// iOS → ios/Runner/AppDelegate.swift:
///   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
class PembagiDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pembagi;

  const PembagiDetailScreen({super.key, required this.pembagi});

  @override
  State<PembagiDetailScreen> createState() => _PembagiDetailScreenState();
}

class _PembagiDetailScreenState extends State<PembagiDetailScreen> {
  Map<String, dynamic> get data => widget.pembagi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(data['branding_name'] ?? 'Detail'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Kategori ──
            _buildKategoriHeader(),

            // ── Info Card ──
            _buildInfoCard(),

            // ── Action Buttons (Menu, Telpon, Chat, SMS, Rute) ──
            _buildActionButtons(),

            const SizedBox(height: AppSpacing.md),

            // ── Google Map ──
            _buildMap(),

            const SizedBox(height: AppSpacing.lg),

            // ── Detail Tambahan ──
            if (data['katalog_harga'] != null) _buildKatalog(),

            if (data['availability'] != null) _buildJadwal(),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            data['produk'] ?? 'Pedagang Keliling',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isAda = (data['status_dagangan'] ?? 'ada') == 'ada';
    final lokasi = data['lokasi'] ?? data['lokasi_sekarang'];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('Photo',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  )),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['branding_name'] ?? '-',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['detail'] ?? data['produk'] ?? '-',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  isAda ? 'Ada' : 'Habis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isAda ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lokasi Sekarang:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  lokasi != null
                      ? '${lokasi['latitude']}, ${lokasi['longitude']}'
                      : '-',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Jarak badge
          if (data['jarak_km'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${data['jarak_km']} KM',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final actions = [
      {
        'icon': Icons.restaurant_menu,
        'label': 'Menu',
        'color': AppColors.primary
      },
      {'icon': Icons.phone, 'label': 'Telpon', 'color': AppColors.info},
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Chat',
        'color': AppColors.success
      },
      {'icon': Icons.sms_outlined, 'label': 'SMS', 'color': AppColors.accent},
      {'icon': Icons.route, 'label': 'Rute', 'color': AppColors.error},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                onPressed: () => _handleAction(action['label'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: action['color'] as Color,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: Text(
                  action['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'Menu':
        _showKatalogDialog();
        break;
      case 'Telpon':
        // TODO: url_launcher → tel:${data['no_hp']}
        // atau VoIP call
        _showSnack('Menghubungi ${data['no_hp'] ?? '...'}');
        break;
      case 'Chat':
        // TODO: Navigate ke chat screen
        _showSnack('Membuka chat...');
        break;
      case 'SMS':
        // TODO: url_launcher → sms:${data['no_hp']}
        _showSnack('Membuka SMS...');
        break;
      case 'Rute':
        _openGoogleMapsRoute();
        break;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _showKatalogDialog() {
    final katalog = data['katalog_harga'] as List?;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Menu / Katalog Harga'),
        content: katalog != null && katalog.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: katalog.map((item) {
                  return ListTile(
                    title: Text(item['nama'] ?? '-'),
                    trailing: Text('Rp ${item['harga'] ?? '-'}'),
                    dense: true,
                  );
                }).toList(),
              )
            : const Text('Belum ada katalog harga.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _openGoogleMapsRoute() {
    final lokasi = data['lokasi'] ?? data['lokasi_sekarang'];
    if (lokasi == null) return;

    final lat = lokasi['latitude'];
    final lng = lokasi['longitude'];

    final url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng&travelmode=driving';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget _buildMap() {
    final lokasi = data['lokasi'] ?? data['lokasi_sekarang'];
    final lat = (lokasi?['latitude'] ?? -6.5971).toDouble();
    final lng = (lokasi?['longitude'] ?? 106.8060).toDouble();
    final brandName = data['branding_name'] ?? 'Pembagi';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('pembagi'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: brandName),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
          liteModeEnabled: false,
          // Penting: supaya map bisa di-gesture di dalam ScrollView
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer()),
          },
        ),
      ),
    );
  }

  Widget _buildKatalog() {
    final katalog = data['katalog_harga'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Katalog Harga',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AppSpacing.sm),
          ...katalog.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['nama'] ?? '-', style: AppTextStyles.body),
                    Text('Rp ${item['harga'] ?? '-'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildJadwal() {
    final avail = data['availability'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jadwal',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AppSpacing.sm),
          _jadwalRow('Hari',
              '${avail['hari_dari'] ?? '-'} - ${avail['hari_sampai'] ?? '-'}'),
          _jadwalRow('Jam',
              '${avail['jam_dari'] ?? '-'} - ${avail['jam_sampai'] ?? '-'}'),
          if (avail['catatan'] != null) _jadwalRow('Catatan', avail['catatan']),
        ],
      ),
    );
  }

  Widget _jadwalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ),
          Expanded(child: Text(value, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
