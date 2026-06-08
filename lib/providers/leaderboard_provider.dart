import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/api_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  int? _myRanking;
  bool _isLoading = false;
  String? _errorMessage;
  String _period = 'mingguan';

  List<LeaderboardEntry> get entries => _entries;
  int? get myRanking => _myRanking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get period => _period;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        ApiService.getLeaderboard(period: _period),
        ApiService.getMyRank(),
      ]);

      // Leaderboard list
      final lbResponse = responses[0];
      if (lbResponse.success && lbResponse.data != null) {
        final rawList = lbResponse.data as List? ?? [];
        _entries = rawList.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } else {
        _errorMessage = lbResponse.message;
      }

      // My rank
      final rankResponse = responses[1];
      if (rankResponse.success && rankResponse.data != null) {
        _myRanking = rankResponse.data['ranking'];
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat leaderboard: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setPeriod(String newPeriod) {
    if (_period != newPeriod) {
      _period = newPeriod;
      loadLeaderboard();
    }
  }

  void clear() {
    _entries = [];
    _myRanking = null;
    _isLoading = false;
    _errorMessage = null;
  }
}