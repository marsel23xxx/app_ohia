import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Pembagi Profile Setup Screen ──
/// Form untuk user mengisi profil sebagai Pembagi.
/// Mencakup: branding name, kategori, sub kategori, detail produk,
/// mobilitas, jadwal, koneksi, katalog harga.
class PembagiSetupScreen extends StatefulWidget {
  const PembagiSetupScreen({super.key});

  @override
  State<PembagiSetupScreen> createState() => _PembagiSetupScreenState();
}

class _PembagiSetupScreenState extends State<PembagiSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  final _brandingNameController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _detailController = TextEditingController();
  final _catatanJadwalController = TextEditingController();

  String _visibility = 'publik';
  String _mobilitas = 'mobile';
  String? _selectedKategori;
  String? _selectedSubKategori;
  String _hariDari = 'Senin';
  String _hariSampai = 'Sabtu';
  TimeOfDay _jamDari = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamSampai = const TimeOfDay(hour: 17, minute: 0);
  bool _allowChat = true;
  bool _allowCall = false;

  // Katalog harga
  final List<Map<String, String>> _katalog = [];
  final _katalogNamaController = TextEditingController();
  final _katalogHargaController = TextEditingController();

  // Allowed searchers (untuk mode Pribadi)
  final List<String> _allowedSearchers = [];
  final _searcherController = TextEditingController();

  final _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void dispose() {
    _brandingNameController.dispose();
    _deskripsiController.dispose();
    _detailController.dispose();
    _catatanJadwalController.dispose();
    _katalogNamaController.dispose();
    _katalogHargaController.dispose();
    _searcherController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isDari) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isDari ? _jamDari : _jamSampai,
    );
    if (picked != null) {
      setState(() {
        if (isDari) {
          _jamDari = picked;
        } else {
          _jamSampai = picked;
        }
      });
    }
  }

  void _addKatalogItem() {
    if (_katalogNamaController.text.isEmpty || _katalogHargaController.text.isEmpty) return;
    setState(() {
      _katalog.add({
        'nama': _katalogNamaController.text.trim(),
        'harga': _katalogHargaController.text.trim(),
      });
      _katalogNamaController.clear();
      _katalogHargaController.clear();
    });
  }

  void _addSearcher() {
    if (_searcherController.text.trim().isEmpty) return;
    setState(() {
      _allowedSearchers.add(_searcherController.text.trim());
      _searcherController.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // TODO: Call API POST /api/pembagi/profile
      // final data = {
      //   'visibility': _visibility,
      //   'branding_name': _brandingNameController.text,
      //   'deskripsi': _deskripsiController.text,
      //   'detail': _detailController.text,
      //   'mobilitas': _mobilitas,
      //   'hari_dari': _hariDari,
      //   'hari_sampai': _hariSampai,
      //   'jam_dari': '${_jamDari.hour}:${_jamDari.minute}',
      //   'jam_sampai': '${_jamSampai.hour}:${_jamSampai.minute}',
      //   'catatan_jadwal': _catatanJadwalController.text,
      //   'allow_chat': _allowChat,
      //   'allow_call': _allowCall,
      //   'katalog_harga': _katalog,
      // };

      await Future.delayed(const Duration(seconds: 2)); // Simulate

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil Pembagi berhasil disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Setup Profil Pembagi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Tipe Pembagi ──
              _sectionTitle('Tipe Pembagi'),
              _buildVisibilityToggle(),
              const SizedBox(height: AppSpacing.lg),

              // ── 2. Info Bisnis ──
              _sectionTitle('Informasi Bisnis'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _brandingNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Brand / Usaha',
                  hintText: 'Contoh: Baso Pak Warso',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan usaha Anda secara singkat',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: 'Detail Produk',
                  hintText: 'Mie Ayam, Baso, Kwetiauw',
                  prefixIcon: Icon(Icons.list_alt_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 3. Mobilitas ──
              _sectionTitle('Mobilitas'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _choiceChip('Mobile (Keliling)', 'mobile', Icons.directions_walk),
                  const SizedBox(width: AppSpacing.md),
                  _choiceChip('Stay (Tetap)', 'stay', Icons.store),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 4. Jadwal ──
              _sectionTitle('Jadwal Ketersediaan'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Dari', _hariDari, _hari,
                      (v) => setState(() => _hariDari = v!))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDropdown('Sampai', _hariSampai, _hari,
                      (v) => setState(() => _hariSampai = v!))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker('Jam Buka', _jamDari, () => _pickTime(true)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTimePicker('Jam Tutup', _jamSampai, () => _pickTime(false)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _catatanJadwalController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Jadwal',
                  hintText: 'Contoh: Jumat istirahat 11:00 - 14:00',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 5. Koneksi ──
              _sectionTitle('Opsi Koneksi'),
              SwitchListTile(
                title: const Text('Izinkan Chat'),
                subtitle: const Text('Pencari bisa mengirim pesan'),
                value: _allowChat,
                onChanged: (v) => setState(() => _allowChat = v),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Izinkan Telepon'),
                subtitle: const Text('Pencari bisa menelepon (VoIP)'),
                value: _allowCall,
                onChanged: (v) => setState(() => _allowCall = v),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 6. Katalog Harga ──
              _sectionTitle('Katalog Harga'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _katalogNamaController,
                      decoration: const InputDecoration(
                        hintText: 'Nama produk',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _katalogHargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Harga',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: _addKatalogItem,
                  ),
                ],
              ),
              if (_katalog.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                ..._katalog.asMap().entries.map((entry) => Card(
                      child: ListTile(
                        dense: true,
                        title: Text(entry.value['nama']!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Rp ${entry.value['harga']}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              onPressed: () => setState(
                                  () => _katalog.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: AppSpacing.lg),

              // ── 7. Allowed Searchers (Pribadi only) ──
              if (_visibility == 'pribadi') ...[
                _sectionTitle('Daftar Pencari yang Diizinkan'),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Hanya nomor HP / username berikut yang bisa menemukan Anda.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searcherController,
                        decoration: const InputDecoration(
                          hintText: 'No HP atau username',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add, color: AppColors.primary),
                      onPressed: _addSearcher,
                    ),
                  ],
                ),
                if (_allowedSearchers.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allowedSearchers.asMap().entries.map((e) => Chip(
                          label: Text(e.value, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(
                              () => _allowedSearchers.removeAt(e.key)),
                        )).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Save Button ──
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Simpan Profil Pembagi'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTextStyles.heading3.copyWith(fontSize: 16));
  }

  Widget _buildVisibilityToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _visibility = 'publik'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _visibility == 'publik'
                    ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _visibility == 'publik'
                      ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.public,
                      color: _visibility == 'publik' ? Colors.white : AppColors.textHint),
                  const SizedBox(height: 4),
                  Text('Publik', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _visibility == 'publik' ? Colors.white : AppColors.textSecondary,
                  )),
                  Text('Semua bisa cari', style: TextStyle(
                    fontSize: 10,
                    color: _visibility == 'publik' ? Colors.white70 : AppColors.textHint,
                  )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _visibility = 'pribadi'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _visibility == 'pribadi'
                    ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _visibility == 'pribadi'
                      ? AppColors.accent : AppColors.divider,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.lock_outline,
                      color: _visibility == 'pribadi' ? Colors.white : AppColors.textHint),
                  const SizedBox(height: 4),
                  Text('Pribadi', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _visibility == 'pribadi' ? Colors.white : AppColors.textSecondary,
                  )),
                  Text('Hanya terdaftar', style: TextStyle(
                    fontSize: 10,
                    color: _visibility == 'pribadi' ? Colors.white70 : AppColors.textHint,
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _choiceChip(String label, String value, IconData icon) {
    final selected = _mobilitas == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mobilitas = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20,
                  color: selected ? AppColors.primary : AppColors.textHint),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.body))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
                const SizedBox(width: 8),
                Text(_formatTime(time), style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
