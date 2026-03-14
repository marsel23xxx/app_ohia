import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_service.dart';

/// ── Emergency Screen ──
/// Tombol Darurat + Kelola Kontak Darurat.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isSending = false;
  bool _isLoadingContacts = true;
  List<Map<String, dynamic>> _contacts = [];
  int? _activeAlertId;

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = ApiClient.create();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final response = await _dio.get('/emergency/contacts');
      setState(() {
        _contacts = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _triggerEmergency() async {
    // Konfirmasi dulu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text('Tombol Darurat'),
          ],
        ),
        content: Text(
          _contacts.isEmpty
              ? 'Anda belum memiliki kontak darurat. Alert akan dikirim tapi tidak ada yang diberitahu.\n\nTambahkan kontak darurat terlebih dahulu?'
              : 'Anda yakin ingin mengirim sinyal darurat?\n\n${_contacts.length} kontak darurat akan diberitahu via WhatsApp beserta lokasi Anda saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('KIRIM ALERT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      // Ambil lokasi saat ini
      final loc = await LocationService().getCurrentLocation();
      if (loc == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mendapatkan lokasi'), backgroundColor: AppColors.error),
          );
        }
        setState(() => _isSending = false);
        return;
      }

      final response = await _dio.post('/emergency/alert', data: {
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'alamat': loc.address,
      });

      final data = response.data['data'];
      setState(() {
        _isSending = false;
        _activeAlertId = data['alert_id'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 Alert terkirim! ${data['notified_count']} kontak diberitahu.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim alert darurat'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _resolveAlert() async {
    if (_activeAlertId == null) return;
    try {
      await _dio.patch('/emergency/alert/$_activeAlertId/resolve');
      setState(() => _activeAlertId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Situasi ditandai aman. Kontak telah diberitahu.'), backgroundColor: AppColors.success),
        );
      }
    } catch (_) {}
  }

  Future<void> _addContact() async {
    final namaCtrl = TextEditingController();
    final noHpCtrl = TextEditingController();
    final hubunganCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kontak Darurat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            const SizedBox(height: 8),
            TextField(controller: noHpCtrl, decoration: const InputDecoration(labelText: 'No HP'), keyboardType: TextInputType.phone),
            const SizedBox(height: 8),
            TextField(controller: hubunganCtrl, decoration: const InputDecoration(labelText: 'Hubungan (opsional)', hintText: 'Ibu, Suami, Teman...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (result != true || namaCtrl.text.isEmpty || noHpCtrl.text.isEmpty) return;

    try {
      await _dio.post('/emergency/contacts', data: {
        'nama': namaCtrl.text.trim(),
        'no_hp': noHpCtrl.text.trim(),
        'hubungan': hubunganCtrl.text.trim(),
      });
      _loadContacts();
    } catch (_) {}
  }

  Future<void> _deleteContact(int id) async {
    try {
      await _dio.delete('/emergency/contacts/$id');
      _loadContacts();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Keamanan - Darurat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tombol Darurat Besar ──
            _buildPanicButton(),
            const SizedBox(height: AppSpacing.md),

            // ── Tombol Aman (kalau ada active alert) ──
            if (_activeAlertId != null) ...[
              OutlinedButton.icon(
                onPressed: _resolveAlert,
                icon: const Icon(Icons.check_circle, color: AppColors.success),
                label: const Text('Tandai Sudah Aman', style: TextStyle(color: AppColors.success)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.success, width: 2),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Kontak Darurat ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kontak Darurat', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.person_add, color: AppColors.primary),
                  onPressed: _addContact,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kontak ini akan diberitahu via WhatsApp saat Anda menekan tombol darurat.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),

            if (_isLoadingContacts)
              const Center(child: CircularProgressIndicator())
            else if (_contacts.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Belum ada kontak darurat', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: _addContact,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Kontak'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 42)),
                    ),
                  ],
                ),
              )
            else
              ..._contacts.map((c) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.error),
                      ),
                      title: Text(c['nama'] ?? '-', style: AppTextStyles.bodyMedium),
                      subtitle: Text('${c['no_hp']}${c['hubungan'] != null && c['hubungan'] != '' ? ' • ${c['hubungan']}' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => _deleteContact(c['id']),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return GestureDetector(
      onTap: _isSending ? null : _triggerEmergency,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSending
                ? [Colors.grey, Colors.grey.shade600]
                : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isSending
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text('Mengirim alert...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 56),
                    SizedBox(height: 8),
                    Text('TOMBOL DARURAT', style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2,
                    )),
                    SizedBox(height: 4),
                    Text('Tekan untuk kirim alert ke kontak darurat', style: TextStyle(
                      color: Colors.white70, fontSize: 12,
                    )),
                  ],
                ),
        ),
      ),
    );
  }
}
