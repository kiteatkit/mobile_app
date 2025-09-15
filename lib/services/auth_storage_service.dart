import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class AuthStorageService {
  static const String _userTypeKey = 'user_type';
  static const String _playerDataKey = 'player_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<void> saveLoginData({
    required String userType,
    Player? player,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_userTypeKey, userType);
    await prefs.setBool(_isLoggedInKey, true);
    
    if (player != null) {
      await prefs.setString(_playerDataKey, jsonEncode(player.toJson()));
    }
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_userTypeKey);
    await prefs.remove(_playerDataKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  static Future<Player?> getPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final playerJson = prefs.getString(_playerDataKey);
    
    if (playerJson != null) {
      try {
        final playerMap = jsonDecode(playerJson) as Map<String, dynamic>;
        return Player.fromJson(playerMap);
      } catch (e) {
        print('Ошибка при загрузке данных игрока: $e');
        return null;
      }
    }
    
    return null;
  }

  static Future<bool> hasValidLoginData() async {
    final isLoggedIn = await AuthStorageService.isLoggedIn();
    if (!isLoggedIn) return false;

    final userType = await AuthStorageService.getUserType();
    if (userType == null) return false;

    if (userType == 'player') {
      final player = await AuthStorageService.getPlayerData();
      return player != null;
    }

    return userType == 'coach';
  }
}
