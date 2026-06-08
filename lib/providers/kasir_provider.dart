import 'package:flutter/material.dart';
import '../models/voucher_validation.dart';
import '../services/api_service.dart';

class KasirProvider extends ChangeNotifier {
  VoucherValidation? _voucher;
  bool _isChecking = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  VoucherValidation? get voucher => _voucher;
  bool get isChecking => _isChecking;
  bool get isSubmitting => _isSubmitting;
  bool get isBusy => _isChecking || _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> checkVoucher(String kode) async {
    final cleanKode = kode.trim().toUpperCase();

    if (cleanKode.isEmpty) {
      _errorMessage = 'Kode voucher wajib diisi.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _isChecking = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.checkKasirVoucher(cleanKode);

      if (response.success && response.data != null) {
        _voucher = VoucherValidation.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        _successMessage = 'Voucher ditemukan.';
        return true;
      } else {
        _voucher = null;
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _voucher = null;
      _errorMessage = 'Gagal cek voucher: ${e.toString()}';
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> validateVoucher(String kode) async {
    final cleanKode = kode.trim().toUpperCase();

    if (cleanKode.isEmpty) {
      _errorMessage = 'Kode voucher wajib diisi.';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.validateKasirVoucher(cleanKode);

      if (response.success && response.data != null) {
        _voucher = VoucherValidation.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        _successMessage = response.message ?? 'Voucher berhasil divalidasi.';
        return true;
      } else {
        _errorMessage = response.message;
        await _refreshVoucherSilently(cleanKode);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal validasi voucher: ${e.toString()}';
      await _refreshVoucherSilently(cleanKode);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _refreshVoucherSilently(String kode) async {
    try {
      final response = await ApiService.checkKasirVoucher(kode);
      if (response.success && response.data != null) {
        _voucher = VoucherValidation.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (_) {}
  }

  void resetResult() {
    _voucher = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}