import 'package:dio/dio.dart';

/// ── Auth Repository ──
/// Handle semua API calls terkait authentication.
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Step 1: Register
  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String nik,
    required String noKk,
    required String kotaLahir,
    required String tanggalLahir,
    required String alamat,
    required String noHp,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'no_kk': noKk,
      'kota_lahir': kotaLahir,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
      'no_hp': noHp,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return response.data;
  }

  /// Kirim ulang OTP
  Future<Map<String, dynamic>> sendOtp({required String noHp}) async {
    final response = await _dio.post('/auth/otp/send', data: {
      'no_hp': noHp,
    });
    return response.data;
  }

  /// Step 2: Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String noHp,
    required String otpCode,
  }) async {
    final response = await _dio.post('/auth/otp/verify', data: {
      'no_hp': noHp,
      'otp_code': otpCode,
    });
    return response.data;
  }

  /// Step 3: Upload selfie + KTP
  Future<Map<String, dynamic>> verifikasiAkhir({
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'foto_selfie_ktp': await MultipartFile.fromFile(
        filePath,
        filename: 'selfie_ktp.jpg',
      ),
    });
    final response = await _dio.post(
      '/auth/verifikasi-akhir',
      data: formData,
    );
    return response.data;
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String login, // no_hp atau email
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'login': login,
      'password': password,
    });
    return response.data;
  }

  /// Logout
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  /// Get profile
  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  /// Switch role
  Future<Map<String, dynamic>> switchRole({required String role}) async {
    final response = await _dio.patch('/auth/switch-role', data: {
      'role': role,
    });
    return response.data;
  }
}
