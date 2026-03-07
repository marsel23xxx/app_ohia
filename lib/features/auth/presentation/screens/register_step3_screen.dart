import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/diagonal_header.dart';

/// ── Register Step 3: Verifikasi Akhir ──
/// Sesuai slide 5-7 PPT: Foto selfie sambil tunjukkan KTP
class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({super.key});

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSubmitted = false;

  Future<void> _pickImage() async {
    // TODO: Use image_picker package
    // final picker = ImagePicker();
    // final picked = await picker.pickImage(
    //   source: ImageSource.camera,
    //   preferredCameraDevice: CameraDevice.front,
    //   imageQuality: 80,
    //   maxWidth: 1200,
    // );
    // if (picked != null) {
    //   setState(() => _selectedImage = File(picked.path));
    // }

    // Placeholder: simulate picking
    setState(() {
      // _selectedImage = File('path/to/image');
    });
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil foto terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Call AuthRepository.verifikasiAkhir(filePath: _selectedImage!.path)

      await Future.delayed(const Duration(seconds: 2)); // Simulate

      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessView();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (DiagonalHeader reusable) ──
            DiagonalHeader(
              title: 'Verifikasi',
              subtitle: 'Verifikasi akhir untuk keamanan Anda',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: AppSpacing.xl),

            // Congratulations message (slide 5)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration_outlined,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text('Selamat!',
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.primaryDark)),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Registrasi OHIA berhasil.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Instructions (slide 5)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 24),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Untuk dapat menggunakan aplikasi ini kami membutuhkan '
                    'VERIFIKASI AKHIR demi kenyamanan dan keamanan seluruh '
                    'pengguna OHIA.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Verifikasi akhir dilakukan dengan melakukan foto diri Anda '
                    'sambil menunjukkan KTP di samping wajah Anda. '
                    'Foto ini tidak akan dipublikasikan.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Camera / Photo area (slide 6)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Ketuk untuk mengambil foto',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textHint),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Visual guide
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, size: 16,
                                    color: AppColors.primaryDark),
                                const SizedBox(width: 4),
                                const Text('+', style: TextStyle(
                                    color: AppColors.primaryDark)),
                                const SizedBox(width: 4),
                                const Icon(Icons.credit_card, size: 16,
                                    color: AppColors.primaryDark),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kirim'),
            ),
          ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Success View (slide 7) ──
  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 64, color: AppColors.success),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Terima Kasih!',
                  style: AppTextStyles.heading1
                      .copyWith(color: AppColors.success)),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Atas kesediaan Anda melakukan verifikasi akhir',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sambil menunggu proses persetujuan VERIFIKASI AKHIR, '
                  'Anda tetap dapat menggunakan fitur-fitur OHIA tertentu.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Buka Aplikasi button
              ElevatedButton(
                onPressed: () {
                  // Navigate ke home screen
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Buka Aplikasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, 'Data Diri', isDone: true),
        _stepLine(isActive: true),
        _stepDot(2, 'Kontak & OTP', isDone: true),
        _stepLine(isActive: true),
        _stepDot(3, 'Verifikasi', isActive: true),
      ],
    );
  }

  Widget _stepDot(int step, String label,
      {bool isActive = false, bool isDone = false}) {
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.divider;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('$step',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textHint,
                    )),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: isActive || isDone ? AppColors.primary : AppColors.textHint,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _stepLine({required bool isActive}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? AppColors.success : AppColors.divider,
    );
  }
}
