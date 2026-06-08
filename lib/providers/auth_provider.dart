import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../models/kasir.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  Mahasiswa? _mahasiswa;
  Kasir? _kasir;
  String? _errorMessage;
  String? _currentRole;

  AuthStatus get status => _status;
  Mahasiswa? get mahasiswa => _mahasiswa;
  Kasir? get kasir => _kasir;
  String? get errorMessage => _errorMessage;
  String? get currentRole => _currentRole;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isKasir => _currentRole == 'kasir';
  bool get isMahasiswa => _currentRole == 'mahasiswa';

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasToken = await StorageService.hasToken();
      if (!hasToken) {
        _setUnauthenticated();
        notifyListeners();
        return;
      }

      final savedRole = await StorageService.getAuthRole();
      bool isValid = false;

      if (savedRole == 'mahasiswa') {
        isValid = await _validateMahasiswaToken();
        if (!isValid) {
          isValid = await _validateKasirToken();
        }
      } else if (savedRole == 'kasir') {
        isValid = await _validateKasirToken();
        if (!isValid) {
          isValid = await _validateMahasiswaToken();
        }
      } else {
        isValid = await _validateMahasiswaToken();
        if (!isValid) {
          isValid = await _validateKasirToken();
        }
      }

      if (!isValid) {
        await StorageService.clearAll();
        _setUnauthenticated();
      }
    } catch (e) {
      await StorageService.clearAll();
      _setUnauthenticated();
    }

    notifyListeners();
  }

  Future<bool> _validateMahasiswaToken() async {
    final response = await ApiService.getProfile();

    if (response.success && response.data != null) {
      _mahasiswa = Mahasiswa.fromJson(response.data);
      _kasir = null;
      _currentRole = 'mahasiswa';
      _status = AuthStatus.authenticated;
      await StorageService.saveAuthRole('mahasiswa');
      return true;
    }

    return false;
  }

  Future<bool> _validateKasirToken() async {
    final response = await ApiService.getKasirMe();

    if (response.success && response.data != null) {
      _kasir = Kasir.fromJson(response.data);
      _mahasiswa = null;
      _currentRole = 'kasir';
      _status = AuthStatus.authenticated;
      await StorageService.saveAuthRole('kasir');
      return true;
    }

    return false;
  }

  Future<bool> loginWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final idToken = await AuthService.signInWithGoogle();
      if (idToken == null) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Login dibatalkan';
        notifyListeners();
        return false;
      }

      final response = await ApiService.loginGoogle(idToken);

      if (response.success && response.data != null) {
        final token = response.data['token'] as String;
        final userData = response.data['mahasiswa'] ?? response.data['user'];

        await StorageService.saveToken(token);
        await StorageService.saveAuthRole('mahasiswa');

        _mahasiswa = Mahasiswa.fromJson(userData);
        _kasir = null;
        _currentRole = 'mahasiswa';

        await StorageService.saveUserId(_mahasiswa!.id);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Gagal login: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginKasir({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.loginKasir(email.trim(), password);

      if (response.success && response.data != null) {
        final token = response.data['token'] as String;
        final kasirData = response.data['kasir'] ?? response.data['user'];

        await StorageService.saveToken(token);
        await StorageService.saveAuthRole('kasir');

        _kasir = Kasir.fromJson(kasirData);
        _mahasiswa = null;
        _currentRole = 'kasir';

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Login kasir gagal: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> mockLogin() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.mockLogin();

      if (response.success && response.data != null) {
        final token = response.data['token'] as String;
        final userData = response.data['mahasiswa'];

        await StorageService.saveToken(token);
        await StorageService.saveAuthRole('mahasiswa');

        _mahasiswa = Mahasiswa.fromJson(userData);
        _kasir = null;
        _currentRole = 'mahasiswa';

        await StorageService.saveUserId(_mahasiswa!.id);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Mock login gagal: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_currentRole == 'kasir') {
        await ApiService.logoutKasir();
      } else {
        await ApiService.logout();
      }
    } catch (_) {}

    try {
      await AuthService.signOut();
    } catch (_) {}

    await StorageService.clearAll();
    _setUnauthenticated();
    _errorMessage = null;
    notifyListeners();
  }

  void updateMahasiswa(Mahasiswa updated) {
    _mahasiswa = updated;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _mahasiswa = null;
    _kasir = null;
    _currentRole = null;
    _status = AuthStatus.unauthenticated;
  }
}