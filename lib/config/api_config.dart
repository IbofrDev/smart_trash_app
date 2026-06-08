class ApiConfig {
  // ============================================
  // SESUAIKAN DENGAN ENVIRONMENT KAMU:
  // Android Emulator  → 10.0.2.2
  // Physical Device   → IP PC kamu (cek: ipconfig)
  // Contoh: 192.168.1.100
  // ============================================
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Google Sign-In Server Client ID (Web type)
  // Dapatkan dari Google Cloud Console → Credentials → OAuth 2.0
  static const String googleServerClientId = 'YOUR_WEB_CLIENT_ID_HERE';

  static Map<String, String> headers({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }
}