import 'package:flutter/material.dart';
import '../models/voucher.dart';
import '../services/api_service.dart';

class VoucherProvider extends ChangeNotifier {
  List<Voucher> _vouchers = [];
  int _totalKoin = 0;
  int _koinPerVoucher = 20;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<Voucher> get vouchers => _vouchers;
  List<Voucher> get vouchersAktif => _vouchers.where((v) => v.isAktif).toList();
  List<Voucher> get vouchersTerpakai =>
      _vouchers.where((v) => v.isTerpakai).toList();
  List<Voucher> get vouchersExpired =>
      _vouchers.where((v) => v.isExpired).toList();
  int get totalKoin => _totalKoin;
  int get koinPerVoucher => _koinPerVoucher;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadVouchers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getVouchers();

      if (response.success && response.data != null) {
        _totalKoin = response.data['total_koin'] ?? 0;
        _koinPerVoucher = response.data['koin_per_voucher'] ?? 20;
        final list = response.data['vouchers'] as List? ?? [];
        _vouchers = list.map((e) => Voucher.fromJson(e)).toList();
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat voucher: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> redeemVoucher() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.redeemVoucher();

      if (response.success) {
        _successMessage = response.message;
        await loadVouchers(); // Refresh list
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal redeem voucher: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clear() {
    _vouchers = [];
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
  }
}
