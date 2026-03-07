import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_step1_screen.dart';
import 'features/auth/presentation/screens/register_step2_screen.dart';
import 'features/auth/presentation/screens/register_step3_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/search/presentation/screens/pembagi_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Cek apakah sudah login
  final hasToken = await ApiClient.hasToken();

  runApp(OhiaApp(isLoggedIn: hasToken));
}

class OhiaApp extends StatelessWidget {
  final bool isLoggedIn;

  const OhiaApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OHIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Initial route berdasarkan login status
      initialRoute: isLoggedIn ? '/home' : '/login',

      // Route definitions
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ── Auth Routes ──
          case '/login':
            return _buildRoute(const LoginScreen(), settings);

          case '/register/step1':
            return _buildRoute(const RegisterStep1Screen(), settings);

          case '/register/step2':
            final args = settings.arguments as Map<String, String>? ?? {};
            return _buildRoute(
              RegisterStep2Screen(step1Data: args),
              settings,
            );

          case '/register/step3':
            return _buildRoute(const RegisterStep3Screen(), settings);

          // ── Main App Routes (Fase 2+) ──
          case '/home':
            return _buildRoute(const HomeScreen(), settings);

          case '/pembagi/detail':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return _buildRoute(
              PembagiDetailScreen(pembagi: args),
              settings,
            );

          // ── Fallback ──
          default:
            return _buildRoute(
              const _PlaceholderScreen(
                title: '404',
                message: 'Halaman tidak ditemukan',
                icon: Icons.error_outline,
              ),
              settings,
            );
        }
      },
    );
  }

  /// Helper: Build route dengan slide transition
  MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// ── Placeholder Screen ──
/// Dipakai sementara untuk route yang belum dibangun.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tombol logout (untuk testing)
              if (title == 'Home')
                OutlinedButton.icon(
                  onPressed: () async {
                    await ApiClient.clearToken();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
