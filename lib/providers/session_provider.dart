import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transaksi_session.dart';
import '../services/api_service.dart';

class SessionProvider extends ChangeNotifier {
  TransaksiSession? _session;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _pollingTimer;

  TransaksiSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasActiveSession =>
      _session != null && !_session!.isCompleted && !_session!.isExpired;

  /// Buat session baru
  Future<bool> createSession({
    required int jumlahBotol,
    required int jumlahKaleng,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.createSession(
        jumlahBotol: jumlahBotol,
        jumlahKaleng: jumlahKaleng,
      );

      if (response.success && response.data != null) {
       _session = TransaksiSession.fromJson(response.data as Map<String, dynamic>);
        _successMessage = response.message;
        _isLoading = false;
        notifyListeners();

        // Mulai polling status
        _startPolling();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal membuat session: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cek status session sekali
  Future<void> checkStatus() async {
    if (_session == null) return;

    try {
      final response = await ApiService.checkSession(_session!.sessionToken);

      if (response.success && response.data != null) {
        _session = TransaksiSession.fromJson(response.data);

        // Stop polling jika sudah selesai atau expired
        if (_session!.isCompleted || _session!.isExpired) {
          _stopPolling();
          if (_session!.isCompleted) {
            _successMessage = 'Transaksi selesai!';
          } else if (_session!.isExpired) {
            _errorMessage = 'Session expired. Silakan buat ulang.';
          }
        }

        notifyListeners();
      }
    } catch (e) {
      // Polling error, jangan stop — coba lagi
    }
  }

  /// Polling otomatis setiap 3 detik
  void _startPolling() {
    _stopPolling();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkStatus(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Reset session (setelah selesai atau mau buat baru)
  void clearSession() {
    _stopPolling();
    _session = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
