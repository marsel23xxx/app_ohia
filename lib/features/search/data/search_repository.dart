import 'package:dio/dio.dart';

/// ── Search Repository ──
class SearchRepository {
  final Dio _dio;

  SearchRepository(this._dio);

  /// Cari Pembagi berdasarkan parameter
  Future<Map<String, dynamic>> search({
    required double latitude,
    required double longitude,
    double radius = 1.5,
    String? mobilitas, // mobile, stay, deliveri, semua
    String? tipe, // publik, pribadi
    int? kategoriId,
    int? subKategoriId,
    String? query,
  }) async {
    final response = await _dio.post('/search', data: {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      if (mobilitas != null) 'mobilitas': mobilitas,
      if (tipe != null) 'tipe': tipe,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (subKategoriId != null) 'sub_kategori_id': subKategoriId,
      if (query != null) 'query': query,
    });
    return response.data;
  }

  /// Detail profil Pembagi
  Future<Map<String, dynamic>> getPembagiDetail({
    required int id,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.get('/pembagi/$id', queryParameters: {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return response.data;
  }

  /// Update lokasi user
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? imei,
  }) async {
    await _dio.post('/location/update', data: {
      'latitude': latitude,
      'longitude': longitude,
      if (imei != null) 'imei': imei,
    });
  }

  /// Get daftar kategori
  Future<Map<String, dynamic>> getKategoris() async {
    final response = await _dio.get('/kategoris');
    return response.data;
  }
}
