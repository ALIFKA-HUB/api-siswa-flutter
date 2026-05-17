import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/siswa_model.dart';

class SiswaService {
  static const String baseUrl = 'http://localhost:3000';

  late final Dio _dio;

  SiswaService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  /// GET /siswa - Mengambil semua data siswa
  Future<List<Siswa>> getAllSiswa() async {
    try {
      final response = await _dio.get('/siswa');
      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];
      return data.map((json) => Siswa.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /siswa - Menambah data siswa baru
  Future<Siswa> createSiswa(Siswa siswa) async {
    try {
      final response = await _dio.post('/siswa', data: siswa.toJson());
      final data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return Siswa.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT /siswa/:id - Update data siswa
  Future<Siswa> updateSiswa(String id, Siswa siswa) async {
    try {
      final response = await _dio.put('/siswa/$id', data: siswa.toJson());
      final data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      return Siswa.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE /siswa/:id - Hapus data siswa
  Future<void> deleteSiswa(String id) async {
    try {
      await _dio.delete('/siswa/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa server Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan server berjalan di localhost:3000.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.message;
        return 'Error $statusCode: $message';
      default:
        return e.message ?? 'Terjadi kesalahan yang tidak diketahui.';
    }
  }
}
