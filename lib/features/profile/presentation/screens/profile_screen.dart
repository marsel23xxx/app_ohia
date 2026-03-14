import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

/// ── Profile Screen ──
/// Menampilkan data profil user, status verifikasi, dan opsi edit.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = ApiClient.create();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      setState(() {
        _user = response.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat profil'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? _buildError()
              : CustomScrollView(
                  slivers: [
                    // ── App Bar with profile header ──
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildProfileHeader(),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                          onPressed: _showEditOptions,
                        ),
                      ],
                    ),

                    // ── Content ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            _buildVerificationBanner(),
                            const SizedBox(height: AppSpacing.md),
                            _buildInfoSection('Data Pribadi', [
                              _infoTile(Icons.person_outline, 'Nama Lengkap', _user!['nama_lengkap'] ?? '-'),
                              _infoTile(Icons.credit_card_outlined, 'NIK', _user!['nik'] ?? '-'),
                              _infoTile(Icons.location_city_outlined, 'Kota Lahir', _user!['kota_lahir'] ?? '-'),
                              _infoTile(Icons.cake_outlined, 'Tanggal Lahir', _user!['tanggal_lahir'] ?? '-'),
                              _infoTile(Icons.home_outlined, 'Alamat', _user!['alamat'] ?? '-'),
                            ]),
                            const SizedBox(height: AppSpacing.md),
                            _buildInfoSection('Kontak', [
                              _infoTile(Icons.phone_outlined, 'No HP', _user!['no_hp'] ?? '-'),
                              _infoTile(Icons.email_outlined, 'Email', _user!['email'] ?? '-'),
                            ]),
                            const SizedBox(height: AppSpacing.md),
                            _buildInfoSection('Akun', [
                              _infoTile(Icons.swap_horiz, 'Role Aktif', (_user!['active_role'] ?? 'pencari') == 'pencari' ? '🔍 Pencari' : '📍 Pembagi'),
                              _infoTile(Icons.account_balance_wallet_outlined, 'Saldo', 'Rp ${_user!['saldo'] ?? '0'}'),
                            ]),
                            const SizedBox(height: AppSpacing.lg),

                            // ── Action Buttons ──
                            _buildActionButton(
                              icon: Icons.storefront_outlined,
                              label: 'Setup Profil Pembagi',
                              color: AppColors.primary,
                              onTap: () => Navigator.pushNamed(context, '/pembagi/setup'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildActionButton(
                              icon: Icons.security_outlined,
                              label: 'Setup PIN Find My Device',
                              color: AppColors.info,
                              onTap: () => Navigator.pushNamed(context, '/find-device'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildActionButton(
                              icon: Icons.warning_amber_outlined,
                              label: 'Kelola Kontak Darurat',
                              color: AppColors.error,
                              onTap: () => Navigator.pushNamed(context, '/emergency'),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // ── Logout ──
                            OutlinedButton.icon(
                              onPressed: () async {
                                await ApiClient.clearToken();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                }
                              },
                              icon: const Icon(Icons.logout, color: AppColors.error),
                              label: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── Profile Header ──
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar
            GestureDetector(
              onTap: _pickProfilePhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: _user!['foto_profil'] != null
                        ? ClipOval(
                            child: Image.network(
                              _user!['foto_profil'],
                              width: 86, height: 86, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: AppColors.primary),
                            ),
                          )
                        : const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Nama
            Text(
              _user!['nama_lengkap'] ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 4),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                (_user!['active_role'] ?? 'pencari') == 'pencari' ? '🔍 Pencari' : '📍 Pembagi',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Verification Banner ──
  Widget _buildVerificationBanner() {
    final status = _user!['verifikasi_status'] ?? 'pending';
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case 'approved':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.verified;
        message = 'Akun terverifikasi';
        break;
      case 'submitted':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        icon = Icons.hourglass_top;
        message = 'Verifikasi sedang diproses';
        break;
      case 'rejected':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        message = 'Verifikasi ditolak — silakan ajukan ulang';
        break;
      default:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        icon = Icons.info_outline;
        message = 'Belum verifikasi — lakukan verifikasi akhir';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
          ),
          if (status == 'pending' || status == 'rejected')
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register/step3'),
              child: Text('Verifikasi', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ── Info Section Card ──
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Button ──
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color))),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ── Pick Photo ──
  void _pickProfilePhoto() {
    // TODO: Implement image_picker
    // final picker = ImagePicker();
    // final picked = await picker.pickImage(source: ImageSource.gallery);
    // if (picked != null) { upload to API }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ganti foto akan segera hadir')),
    );
  }

  // ── Edit Options ──
  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Ganti Foto Profil'),
              onTap: () { Navigator.pop(ctx); _pickProfilePhoto(); },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.info),
              title: Text('Switch ke ${(_user!['active_role'] ?? 'pencari') == 'pencari' ? 'Pembagi' : 'Pencari'}'),
              onTap: () async {
                Navigator.pop(ctx);
                final newRole = (_user!['active_role'] ?? 'pencari') == 'pencari' ? 'pembagi' : 'pencari';
                try {
                  await _dio.patch('/auth/switch-role', data: {'role': newRole});
                  _loadProfile();
                } catch (_) {}
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: AppColors.success),
              title: const Text('Verifikasi Akhir'),
              onTap: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/register/step3'); },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          const Text('Gagal memuat profil'),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: _loadProfile, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
