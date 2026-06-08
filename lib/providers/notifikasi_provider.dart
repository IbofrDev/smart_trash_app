import 'package:flutter/material.dart';
import '../models/notifikasi.dart';
import '../services/api_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  List<Notifikasi> _notifikasis = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Notifikasi> get notifikasis => _notifikasis;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadNotifikasi({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifikasis = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getNotifikasi(page: _currentPage);

      if (response.success && response.data != null) {
        List rawList = [];
        int lastPage = 1;

        // Handle paginated response (has 'data' key)
        if (response.data is Map && response.data.containsKey('data')) {
          rawList = response.data['data'] as List? ?? [];
          lastPage = response.data['last_page'] ?? 1;
        }
        // Handle direct list response (no pagination)
        else if (response.data is List) {
          rawList = response.data;
          lastPage = 1;
        }

        final newItems = rawList.map((e) => Notifikasi.fromJson(e)).toList();
        _notifikasis.addAll(newItems);

        _hasMore = _currentPage < lastPage;
        _currentPage++;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      final response = await ApiService.getUnreadCount();
      if (response.success && response.data != null) {
        _unreadCount = response.data['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await ApiService.markNotifikasiRead(id);
      if (response.success) {
        final index = _notifikasis.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifikasis[index] = Notifikasi(
            id: _notifikasis[index].id,
            judul: _notifikasis[index].judul,
            pesan: _notifikasis[index].pesan,
            tipe: _notifikasis[index].tipe,
            isRead: true,
            createdAt: _notifikasis[index].createdAt,
          );
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.markAllNotifikasiRead();
      if (response.success) {
        _notifikasis = _notifikasis
            .map((n) => Notifikasi(
                  id: n.id,
                  judul: n.judul,
                  pesan: n.pesan,
                  tipe: n.tipe,
                  isRead: true,
                  createdAt: n.createdAt,
                ))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  void clear() {
    _notifikasis = [];
    _unreadCount = 0;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _errorMessage = null;
  }
}
