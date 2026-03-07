import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ── API Configuration ──
class ApiConfig {
  // Ganti sesuai environment
  static const String baseUrl =
      'http://192.168.0.106:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'https://api.ohia.id/api'; // Production

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// ── Dio Client Factory ──
class ApiClient {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // ── Request Interceptor: Auto-attach Bearer Token ──
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired / invalid → hapus & redirect ke login
          await _storage.delete(key: 'auth_token');
          // TODO: Navigate to login screen via GoRouter
        }
        return handler.next(error);
      },
    ));

    // ── Logging (dev only) ──
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 $obj'),
    ));

    return dio;
  }

  /// Simpan token setelah login/OTP verify
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Hapus token saat logout
  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Cek apakah sudah login
  static Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
