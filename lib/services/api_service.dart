import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  // =====================
  // HELPER METHODS
  // =====================

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return ApiConfig.headers(token: token);
  }

  static ApiResponse _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(body);
    } else if (response.statusCode == 401) {
      StorageService.clearAll();
      return ApiResponse(
        success: false,
        message:
            body['message'] ?? 'Sesi telah berakhir. Silakan login kembali.',
      );
    } else if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      String errorMsg = body['message'] ?? 'Validasi gagal';
      if (errors != null && errors.isNotEmpty) {
        errorMsg = errors.values.first is List
            ? (errors.values.first as List).first.toString()
            : errors.values.first.toString();
      }
      return ApiResponse(success: false, message: errorMsg);
    } else {
      return ApiResponse(
        success: false,
        message: body['message'] ?? 'Terjadi kesalahan server.',
      );
    }
  }

  // =====================
  // AUTH ENDPOINTS
  // =====================

  static Future<ApiResponse> loginGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/google'),
      headers: ApiConfig.headers(),
      body: jsonEncode({'id_token': idToken}),
    );
    // Debug — lihat response asli
    debugPrint('=== LOGIN GOOGLE RESPONSE ===');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    debugPrint('============================');
    return _handleResponse(response);
  }

  static Future<ApiResponse> loginKasir(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/kasir/login'),
      headers: ApiConfig.headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> mockLogin() async {
    try {
      final url = '${ApiConfig.baseUrl}/auth/mock-login';
      final response = await http
          .post(Uri.parse(url), headers: ApiConfig.headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(
          success: body['success'] ?? false,
          message: body['message'] ?? '',
          data: body['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static Future<ApiResponse> logout() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> logoutKasir() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/kasir/logout'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> getKasirMe() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/kasir/me'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> checkKasirVoucher(String kode) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/kasir/voucher/check/${Uri.encodeComponent(kode)}',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> validateKasirVoucher(String kodeVoucher) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/kasir/voucher/validate'),
      headers: headers,
      body: jsonEncode({
        'kode_voucher': kodeVoucher,
      }),
    );
    return _handleResponse(response);
  }

  // =====================
  // DASHBOARD
  // =====================

  static Future<ApiResponse> getDashboard() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // TRANSAKSI
  // =====================

  static Future<ApiResponse> getTransaksi(
      {String? period, int page = 1}) async {
    final headers = await _getHeaders();
    final params = <String, String>{'page': page.toString()};
    if (period != null) params['period'] = period;

    final uri = Uri.parse('${ApiConfig.baseUrl}/transaksi')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<ApiResponse> getTransaksiDetail(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/transaksi/$id'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // TRANSAKSI SESSION
  // =====================

  static Future<ApiResponse> createSession({
    required int jumlahBotol,
    required int jumlahKaleng,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/transaksi/session'),
      headers: headers,
      body: jsonEncode({
        'jumlah_botol': jumlahBotol,
        'jumlah_kaleng': jumlahKaleng,
      }),
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> checkSession(String token) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/transaksi/session/$token'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // VOUCHER
  // =====================

  static Future<ApiResponse> getVouchers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vouchers'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> redeemVoucher() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/vouchers/redeem'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // LEADERBOARD
  // =====================

  static Future<ApiResponse> getLeaderboard(
      {String period = 'mingguan'}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/leaderboard')
        .replace(queryParameters: {'period': period});
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<ApiResponse> getMyRank() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leaderboard/my-rank'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // ACHIEVEMENT
  // =====================

  static Future<ApiResponse> getAchievements() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> getMyAchievements() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements/my'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // NOTIFIKASI
  // =====================

  static Future<ApiResponse> getNotifikasi({int page = 1}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/notifikasi')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<ApiResponse> markNotifikasiRead(int id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifikasi/$id/read'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> markAllNotifikasiRead() async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifikasi/read-all'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> getUnreadCount() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifikasi/unread-count'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // =====================
  // PROFILE
  // =====================

  static Future<ApiResponse> getProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> updateRfid(String rfidUid) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/profile/rfid'),
      headers: headers,
      body: jsonEncode({'rfid_uid': rfidUid}),
    );
    return _handleResponse(response);
  }

  static Future<ApiResponse> updateFcmToken(String fcmToken) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/profile/fcm-token'),
      headers: headers,
      body: jsonEncode({'fcm_token': fcmToken}),
    );
    return _handleResponse(response);
  }
}
