import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/api_service.dart';

class TransaksiProvider extends ChangeNotifier {
  List<Transaksi> _transaksis = [];
  Transaksi? _selectedTransaksi;
  bool _isLoading = false;
  String? _errorMessage;
  String _period = 'all';
  String _filterStatus = 'semua'; // 'semua' | 'valid' | 'anomali'
  int _currentPage = 1;
  bool _hasMore = true;

  // Summary
  int _totalPoin = 0;
  int _totalKoin = 0;
  int _totalTransaksi = 0;

  List<Transaksi> get transaksis => _transaksis;
  Transaksi? get selectedTransaksi => _selectedTransaksi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get period => _period;
  String get filterStatus => _filterStatus;
  bool get hasMore => _hasMore;
  int get totalPoin => _totalPoin;
  int get totalKoin => _totalKoin;
  int get totalTransaksi => _totalTransaksi;

  // Filter lokal berdasarkan status validasi
  List<Transaksi> get transaksiFiltered {
    if (_filterStatus == 'semua') return _transaksis;
    return _transaksis.where((t) => t.statusValidasi == _filterStatus).toList();
  }

  Future<void> loadTransaksi({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _transaksis = [];
      _hasMore = true;
      _totalPoin = 0;
      _totalKoin = 0;
      _totalTransaksi = 0;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getTransaksi(
        period: _period,
        page: _currentPage,
      );

      if (response.success && response.data != null) {
        final rawList =
            response.data['data'] as List? ?? response.data as List? ?? [];
        final newItems = rawList.map((e) => Transaksi.fromJson(e)).toList();

        _transaksis.addAll(newItems);

        // Hitung summary dari semua data yang sudah di-load
        _totalPoin = _transaksis.fold(0, (sum, t) => sum + t.poinDidapat);
        _totalKoin = _transaksis.fold(0, (sum, t) => sum + t.koinDidapat);

        // Pakai total dari API bukan dari jumlah yang sudah di-load
        _totalTransaksi = response.data['total'] ?? _transaksis.length;

        // Check pagination
        final lastPage = response.data['last_page'] ?? 1;
        _hasMore = _currentPage < lastPage;
        _currentPage++;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat transaksi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTransaksiDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getTransaksiDetail(id);

      if (response.success && response.data != null) {
        _selectedTransaksi = Transaksi.fromJson(response.data);
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail transaksi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setPeriod(String newPeriod) {
    if (_period != newPeriod) {
      _period = newPeriod;
      loadTransaksi(refresh: true);
    }
  }

  void setFilterStatus(String status) {
    if (_filterStatus != status) {
      _filterStatus = status;
      notifyListeners();
    }
  }

  void clear() {
    _transaksis = [];
    _selectedTransaksi = null;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _errorMessage = null;
    _totalPoin = 0;
    _totalKoin = 0;
    _totalTransaksi = 0;
    _filterStatus = 'semua';
  }
}
