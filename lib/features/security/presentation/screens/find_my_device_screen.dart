import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

/// ── Find My Device Screen ──
/// Lacak HP berdasarkan IMEI/No HP + PIN.
class FindMyDeviceScreen extends StatefulWidget {
  const FindMyDeviceScreen({super.key});

  @override
  State<FindMyDeviceScreen> createState() => _FindMyDeviceScreenState();
}

class _FindMyDeviceScreenState extends State<FindMyDeviceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final Dio _dio;

  // Track tab
  final _targetController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isTracking = false;
  Map<String, dynamic>? _trackResult;

  // Setup tab
  final _setupPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _imeiController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dio = ApiClient.create();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetController.dispose();
    _pinController.dispose();
    _setupPinController.dispose();
    _confirmPinController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  Future<void> _trackDevice() async {
    if (_targetController.text.isEmpty || _pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan IMEI/No HP dan PIN 6 digit')),
      );
      return;
    }

    setState(() {
      _isTracking = true;
      _trackResult = null;
    });

    try {
      final response = await _dio.post('/device/track', data: {
        'target': _targetController.text.trim(),
        'pin': _pinController.text.trim(),
      });

      setState(() {
        _isTracking = false;
        _trackResult = response.data['data'];
      });
    } on DioException catch (e) {
      setState(() => _isTracking = false);
      if (mounted) {
        final msg = e.response?.data is Map
            ? e.response!.data['message'] ?? 'Gagal melacak device'
            : 'Gagal melacak device';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _setupPin() async {
    if (_setupPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN harus 6 digit')),
      );
      return;
    }
    if (_setupPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN tidak cocok')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _dio.post('/device/setup-pin', data: {
        'pin': _setupPinController.text.trim(),
        'imei': _imeiController.text.trim().isNotEmpty ? _imeiController.text.trim() : null,
      });

      setState(() => _isSaving = false);
      if (mounted) {
        _setupPinController.clear();
        _confirmPinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN berhasil disimpan!'), backgroundColor: AppColors.success),
        );
      }
    } on DioException catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        final msg = e.response?.data is Map ? e.response!.data['message'] ?? 'Gagal' : 'Gagal';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find My Device'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Lacak'),
            Tab(icon: Icon(Icons.settings), text: 'Setup PIN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackTab(),
          _buildSetupTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // TAB 1: LACAK DEVICE
  // ═══════════════════════════════════════
  Widget _buildTrackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Masukkan IMEI atau nomor HP device yang hilang, beserta PIN yang sudah diatur saat registrasi.',
                    style: TextStyle(fontSize: 13, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // IMEI / No HP
          TextFormField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'IMEI atau Nomor HP',
              hintText: 'Masukkan IMEI atau 08xxxxxxxxxx',
              prefixIcon: Icon(Icons.phone_android_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // PIN
          TextFormField(
            controller: _pinController,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'PIN (6 digit)',
              hintText: '••••••',
              prefixIcon: Icon(Icons.lock_outline),
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Track button
          ElevatedButton.icon(
            onPressed: _isTracking ? null : _trackDevice,
            icon: _isTracking
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.location_searching, color: Colors.white),
            label: Text(_isTracking ? 'Melacak...' : 'Lacak Device'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),

          // ── Hasil Tracking ──
          if (_trackResult != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.location_on, color: AppColors.success, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Device Ditemukan!', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success,
                  )),
                  const SizedBox(height: AppSpacing.md),

                  // Koordinat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Latitude', '${_trackResult!['lokasi']['latitude']}'),
                        _infoRow('Longitude', '${_trackResult!['lokasi']['longitude']}'),
                        if (_trackResult!['last_update'] != null)
                          _infoRow('Update Terakhir', _formatDate(_trackResult!['last_update'])),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Buka di Google Maps
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: url_launcher → _trackResult['maps_url']
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka: ${_trackResult!['maps_url']}')),
                      );
                    },
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: const Text('Buka di Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // TAB 2: SETUP PIN
  // ═══════════════════════════════════════
  Widget _buildSetupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PIN ini digunakan untuk memverifikasi identitas saat melacak device. Simpan PIN ini dengan aman!',
                    style: TextStyle(fontSize: 13, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          TextFormField(
            controller: _imeiController,
            decoration: const InputDecoration(
              labelText: 'IMEI Device (opsional)',
              hintText: 'Akan terisi otomatis jika kosong',
              prefixIcon: Icon(Icons.phone_android_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextFormField(
            controller: _setupPinController,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'PIN Baru (6 digit)',
              prefixIcon: Icon(Icons.lock_outline),
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextFormField(
            controller: _confirmPinController,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Konfirmasi PIN',
              prefixIcon: Icon(Icons.lock_outline),
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ElevatedButton(
            onPressed: _isSaving ? null : _setupPin,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Simpan PIN'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
