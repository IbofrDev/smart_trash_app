import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/api_service.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _allAchievements = [];
  List<Achievement> _myAchievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Achievement> get allAchievements => _allAchievements;
  List<Achievement> get myAchievements => _myAchievements;
  List<Achievement> get lockedAchievements =>
      _allAchievements.where((a) => !a.isUnlocked).toList();
  int get unlockedCount => _allAchievements.where((a) => a.isUnlocked).length;
  int get totalCount => _allAchievements.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAchievements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        ApiService.getAchievements(),
        ApiService.getMyAchievements(),
      ]);

      // All achievements (with is_unlocked flag)
      final allResponse = responses[0];
      if (allResponse.success && allResponse.data != null) {
        final rawList = allResponse.data as List? ?? [];
        _allAchievements = rawList.map((e) => Achievement.fromJson(e)).toList();
      }

      // My achievements
      final myResponse = responses[1];
      if (myResponse.success && myResponse.data != null) {
        final rawList = myResponse.data as List? ?? [];
        _myAchievements = rawList.map((e) => Achievement.fromJson(e)).toList();
      }

      if (!allResponse.success) {
        _errorMessage = allResponse.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat achievement: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _allAchievements = [];
    _myAchievements = [];
    _isLoading = false;
    _errorMessage = null;
  }
}