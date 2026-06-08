import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardData? _data;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getDashboard();

      if (response.success && response.data != null) {
        _data = DashboardData.fromJson(response.data);
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat dashboard: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _data = null;
    _isLoading = false;
    _errorMessage = null;
  }
}