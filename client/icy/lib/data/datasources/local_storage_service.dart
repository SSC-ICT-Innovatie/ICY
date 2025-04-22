import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/models/achievement_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  // Initialize SharedPreferences
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Auth token operations
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(ApiConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return _prefs.getString(ApiConstants.authTokenKey);
  }

  // Refresh token operations
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(ApiConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(ApiConstants.refreshTokenKey);
  }

  // User operations
  Future<void> saveAuthUser(UserModel user) async {
    await _prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getAuthUser() async {
    final userJson = _prefs.getString(ApiConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _prefs.remove(ApiConstants.authTokenKey);
    await _prefs.remove(ApiConstants.refreshTokenKey);
    await _prefs.remove(ApiConstants.userKey);
  }

  // Theme operations
  Future<void> saveTheme(String themeName) async {
    await _prefs.setString(ApiConstants.themeKey, themeName);
  }

  Future<String?> getTheme() async {
    return _prefs.getString(ApiConstants.themeKey);
  }

  // Language operations
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(ApiConstants.languageKey, languageCode);
  }

  Future<String?> getLanguage() async {
    return _prefs.getString(ApiConstants.languageKey);
  }
  
  // Achievement and XP operations
  static const String _achievementsKey = 'user_achievements';
  static const String _userXpKey = 'user_xp';
  static const String _userStreakKey = 'user_streak';
  static const String _lastStreakUpdateKey = 'last_streak_update';
  
  // Save user XP
  Future<void> saveUserXp(int xp) async {
    await _prefs.setInt(_userXpKey, xp);
  }
  
  // Get user XP
  Future<int> getUserXp() async {
    return _prefs.getInt(_userXpKey) ?? 0;
  }
  
  // Increment user XP
  Future<int> incrementUserXp(int amount) async {
    final currentXp = await getUserXp();
    final newXp = currentXp + amount;
    await saveUserXp(newXp);
    return newXp;
  }
  
  // Save user streak
  Future<void> saveUserStreak(int streak) async {
    await _prefs.setInt(_userStreakKey, streak);
    await _prefs.setString(_lastStreakUpdateKey, DateTime.now().toIso8601String());
  }
  
  // Get user streak
  Future<int> getUserStreak() async {
    return _prefs.getInt(_userStreakKey) ?? 0;
  }
  
  // Increment user streak
  Future<int> incrementUserStreak() async {
    final currentStreak = await getUserStreak();
    final newStreak = currentStreak + 1;
    await saveUserStreak(newStreak);
    return newStreak;
  }
  
  // Check if streak should be updated today
  Future<bool> shouldUpdateStreakToday() async {
    final lastUpdateStr = _prefs.getString(_lastStreakUpdateKey);
    if (lastUpdateStr == null) return true;
    
    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastUpdateDay = DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day);
    
    // Allow streak update if it's a different day
    return !lastUpdateDay.isAtSameMomentAs(today);
  }
  
  // Save earned badge
  Future<void> saveEarnedBadge(Badge badge, String dateEarned, int xpAwarded) async {
    final badges = await getEarnedBadges();
    final earnedBadge = EarnedBadge(
      badgeId: badge.toJson(),
      dateEarned: dateEarned,
      xpAwarded: xpAwarded,
    );
    
    badges.add(earnedBadge.toJson());
    await _prefs.setString('earned_badges', jsonEncode(badges));
    
    // Also update the user's total XP
    await incrementUserXp(xpAwarded);
  }
  
  // Get earned badges
  Future<List<dynamic>> getEarnedBadges() async {
    final badgesJson = _prefs.getString('earned_badges');
    if (badgesJson == null) return [];
    return jsonDecode(badgesJson) as List<dynamic>;
  }
  
  // Save achievement progress
  Future<void> saveAchievementProgress(Map<String, double> progress) async {
    await _prefs.setString('achievement_progress', jsonEncode(progress));
  }
  
  // Get achievement progress
  Future<Map<String, double>> getAchievementProgress() async {
    final progressJson = _prefs.getString('achievement_progress');
    if (progressJson == null) return {};
    
    final decoded = jsonDecode(progressJson);
    return Map<String, double>.from(decoded);
  }
  
  // Update specific achievement progress
  Future<void> updateAchievementProgress(String achievementId, double progress) async {
    final currentProgress = await getAchievementProgress();
    currentProgress[achievementId] = progress;
    await saveAchievementProgress(currentProgress);
  }
}
