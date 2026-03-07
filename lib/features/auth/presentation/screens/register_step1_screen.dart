import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/diagonal_header.dart';

/// ── Register Step 1: Data Pribadi ──
/// Sesuai slide 3 PPT: Nama Lengkap, No KTP, No KK, Kota Lahir, Tanggal Lahir, Alamat
class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _noKkController = TextEditingController();
  final _kotaLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  DateTime? _tanggalLahir;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noKkController.dispose();
    _kotaLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tanggalLahir = picked);
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir terlebih dahulu')),
      );
      return;
    }

    // Navigate ke Step 2 dengan membawa data step 1
    Navigator.pushNamed(context, '/register/step2', arguments: {
      'nama_lengkap': _namaController.text.trim(),
      'nik': _nikController.text.trim(),
      'no_kk': _noKkController.text.trim(),
      'kota_lahir': _kotaLahirController.text.trim(),
      'tanggal_lahir': _tanggalLahir!.toIso8601String().split('T').first,
      'alamat': _alamatController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (DiagonalHeader reusable) ──
            const DiagonalHeader(
              title: 'Registrasi',
              subtitle: 'Lengkapi data diri Anda',
            ),

            // ── Form ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator
                      _buildStepIndicator(),
                      const SizedBox(height: AppSpacing.lg),

                      // Nama Lengkap
                      _buildLabel('Nama Lengkap'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _namaController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama sesuai KTP',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // NIK
                      _buildLabel('No. KTP (NIK)'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _nikController,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '16 digit NIK',
                          prefixIcon: Icon(Icons.credit_card_outlined),
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'NIK wajib diisi';
                          if (v.length != 16) return 'NIK harus 16 digit';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // No KK
                      _buildLabel('No. KK'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _noKkController,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '16 digit Nomor KK',
                          prefixIcon: Icon(Icons.family_restroom_outlined),
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'No KK wajib diisi';
                          if (v.length != 16) return 'No KK harus 16 digit';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Kota Lahir
                      _buildLabel('Kota Lahir'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _kotaLahirController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Jakarta',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Kota lahir wajib diisi' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Tanggal Lahir
                      _buildLabel('Tanggal Lahir'),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            _tanggalLahir != null
                                ? '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'
                                : 'Pilih tanggal lahir',
                            style: _tanggalLahir != null
                                ? AppTextStyles.body
                                : AppTextStyles.body.copyWith(color: AppColors.textHint),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Alamat
                      _buildLabel('Alamat'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Alamat lengkap sesuai KTP',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.home_outlined),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Button Lanjut
                      ElevatedButton(
                        onPressed: _onNext,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lanjut'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Link ke Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ',
                              style: AppTextStyles.caption),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text(
                              'Masuk',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, 'Data Diri', isActive: true),
        _stepLine(isActive: false),
        _stepDot(2, 'Kontak & OTP', isActive: false),
        _stepLine(isActive: false),
        _stepDot(3, 'Verifikasi', isActive: false),
      ],
    );
  }

  Widget _stepDot(int step, String label, {required bool isActive}) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isActive ? AppColors.primary : AppColors.divider,
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: isActive ? AppColors.primary : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _stepLine({required bool isActive}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? AppColors.primary : AppColors.divider,
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.bodyMedium);
  }
}
