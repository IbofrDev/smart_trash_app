class ApiConfig {
  // ============================================
  // LIVE HOSTING ENVIRONMENT
  // ============================================
  // Lokal: 'http://10.0.2.2:8000/api'
// server: 'https://polibansmarttrash.my.id/api';
  static const String baseUrl = 'http://10.87.90.176:8000/api';

  // Google Sign-In Server Client ID (Web type)
  // Dapatkan dari Google Cloud Console → Credentials → OAuth 2.0
  static const String googleServerClientId =
      '672702737346-l194hjk7nkkg2hahqnn4r3q2sckf4nj5.apps.googleusercontent.com';

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