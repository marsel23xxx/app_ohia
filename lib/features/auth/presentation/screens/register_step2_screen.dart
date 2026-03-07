import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/diagonal_header.dart';

/// ── Register Step 2: Kontak & OTP ──
/// Sesuai slide 4 PPT: No HP, Email, Kirim OTP, Input OTP, Verifikasi
class RegisterStep2Screen extends StatefulWidget {
  final Map<String, String> step1Data;

  const RegisterStep2Screen({super.key, required this.step1Data});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();

  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // OTP
  bool _otpSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Countdown
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _noHpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Call AuthRepository.register() lalu auto-send OTP
      // final result = await authRepo.register(
      //   ...widget.step1Data,
      //   noHp: _noHpController.text,
      //   email: _emailController.text,
      //   password: _passwordController.text,
      //   passwordConfirmation: _confirmPasswordController.text,
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulate API

      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      _startCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP telah dikirim ke nomor HP Anda'),
            backgroundColor: AppColors.success,
          ),
        );
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

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Call AuthRepository.verifyOtp()
      // final result = await authRepo.verifyOtp(
      //   noHp: _noHpController.text,
      //   otpCode: otp,
      // );
      // await ApiClient.saveToken(result['data']['token']);

      await Future.delayed(const Duration(seconds: 2)); // Simulate API

      if (mounted) {
        // Navigate ke Step 3: Verifikasi Akhir
        Navigator.pushNamed(context, '/register/step3');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP salah atau kadaluarsa'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (DiagonalHeader reusable) ──
            DiagonalHeader(
              title: 'Registrasi',
              subtitle: 'Kontak & Verifikasi OTP',
              showBackButton: true,
              onBack: () => Navigator.pop(context),
            ),

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
              const SizedBox(height: AppSpacing.xl),

              if (!_otpSent) ...[
                // ── Form Kontak ──
                _buildLabel('Nomor HP'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '08xxxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'No HP wajib diisi';
                    if (v.length < 10) return 'No HP tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                _buildLabel('Email'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'email@contoh.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                _buildLabel('Password'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimal 8 karakter',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                _buildLabel('Konfirmasi Password'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text)
                      return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Kirim OTP button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim OTP'),
                ),
              ] else ...[
                // ── OTP Input Section ──
                const Icon(Icons.sms_outlined, size: 64, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Masukkan Kode OTP',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Kode OTP telah dikirim ke\n${_noHpController.text}',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48,
                      child: TextFormField(
                        controller: _otpControllers[i],
                        focusNode: _otpFocusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _otpFocusNodes[i + 1].requestFocus();
                          }
                          if (v.isEmpty && i > 0) {
                            _otpFocusNodes[i - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.md),

                // Info auto-verify
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primaryDark, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'OTP akan otomatis terverifikasi jika nomor HP yang dimasukkan sama dengan nomor yang Anda gunakan saat ini.',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Verify button
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verifikasi'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Resend OTP
                Center(
                  child: _countdown > 0
                      ? Text(
                          'Kirim ulang OTP dalam ${_countdown}s',
                          style: AppTextStyles.caption,
                        )
                      : GestureDetector(
                          onTap: _sendOtp,
                          child: Text(
                            'Kirim Ulang OTP',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                ),
              ],
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
        _stepDot(1, 'Data Diri', isActive: false, isDone: true),
        _stepLine(isActive: true),
        _stepDot(2, 'Kontak & OTP', isActive: true),
        _stepLine(isActive: false),
        _stepDot(3, 'Verifikasi', isActive: false),
      ],
    );
  }

  Widget _stepDot(int step, String label,
      {required bool isActive, bool isDone = false}) {
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
                : Text(
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
