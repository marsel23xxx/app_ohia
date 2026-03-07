import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/diagonal_header.dart';

/// ── Login Screen ──
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController(); // no_hp atau email
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Call AuthRepository.login()
      // final result = await authRepo.login(
      //   login: _loginController.text,
      //   password: _passwordController.text,
      // );
      // await ApiClient.saveToken(result['data']['token']);

      await Future.delayed(const Duration(seconds: 2)); // Simulate

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal. Periksa kembali data Anda.'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // ── Header (DiagonalHeader reusable) ──
                    const DiagonalHeader(
                      title: 'O H I A',
                      subtitle: 'Temukan yang kamu inginkan',
                    ),
                  ],
                ),
              ),

              // ── Form ──
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      Text('Masuk', style: AppTextStyles.heading2),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Selamat datang kembali!',
                          style: AppTextStyles.caption),
                      const SizedBox(height: AppSpacing.xl),

                      // No HP / Email
                      TextFormField(
                        controller: _loginController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'No HP atau Email',
                          hintText: '08xxx atau email@contoh.com',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Masukkan No HP atau Email'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Password wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Lupa password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate ke forgot password
                          },
                          child: Text(
                            'Lupa Password?',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Login button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Masuk'),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun? ', style: AppTextStyles.body),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register/step1'),
                            child: Text(
                              'Daftar Sekarang',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
