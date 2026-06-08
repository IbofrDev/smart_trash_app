import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConfig.googleServerClientId,
    scopes: ['email', 'profile'],
  );

  /// Login dengan Google, return ID Token
  static Future<String?> signInWithGoogle() async {
    try {
      // Sign out dulu untuk force pilih akun
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) return null; // User cancelled

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out dari Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}