import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const List<String> _candidateUrls = [
    'https://eco-pulse-eta.vercel.app',
    'http://127.0.0.1:8000',
    'http://172.20.129.223:8000',
    'http://192.168.137.1:8000',
  ];
  static String _activeBaseUrl = _candidateUrls[0];

  int? _userId;

  int? get userId => _userId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
  }

  Future<void> _saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    _userId = id;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _userId = null;
  }

  Future<http.Response> _postWithFallback(String endpoint, {Map<String, String>? headers, Object? body}) async {
    List<String> urls = ['http://127.0.0.1:8000', 'http://172.20.129.223:8000', 'http://192.168.137.1:8000'];
    for (final base in urls) {
      try {
        final response = await http.post(
          Uri.parse('$base$endpoint'),
          headers: headers,
          body: body,
        ).timeout(const Duration(milliseconds: 3500));
        _activeBaseUrl = base;
        return response;
      } catch (e) {
        print('Connection to $base failed, trying next...');
      }
    }
    throw Exception('All backend candidate URLs unreachable');
  }

  Future<http.Response> _getWithFallback(String endpoint) async {
    List<String> urls = ['http://127.0.0.1:8000', 'http://172.20.129.223:8000', 'http://192.168.137.1:8000'];
    for (final base in urls) {
      try {
        final response = await http.get(
          Uri.parse('$base$endpoint'),
        ).timeout(const Duration(milliseconds: 3500));
        _activeBaseUrl = base;
        return response;
      } catch (e) {
        print('Connection to $base failed, trying next...');
      }
    }
    throw Exception('All backend candidate URLs unreachable');
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _postWithFallback(
        '/auth/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUserId(data['id']);
        return {'success': true, 'message': 'Account created!'};
      }
      final err = jsonDecode(response.body);
      return {'success': false, 'message': err['detail'] ?? 'Registration failed.'};
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'Network connection error.'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _postWithFallback(
        '/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username_or_email': usernameOrEmail, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUserId(data['user_id']);
        return {'success': true, 'message': 'Welcome back!'};
      }
      final err = jsonDecode(response.body);
      return {'success': false, 'message': err['detail'] ?? 'Invalid credentials.'};
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Network connection error.'};
    }
  }

  Future<Map<String, dynamic>?> createExpense({
    required String vendor,
    required double amount,
    String itemsText = '',
  }) async {
    try {
      final uid = _userId ?? 1;
      final response = await _postWithFallback(
        '/expenses',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': uid,
          'vendor': vendor,
          'amount': amount,
          'items_text': itemsText,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Create expense error status: ${response.statusCode}, body: ${response.body}');
      return {'success': false, 'message': 'Server error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      print('Create expense error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<List<Map<String, dynamic>>> getExpenses({int limit = 50, int offset = 0}) async {
    if (_userId == null) return [];
    try {
      final response = await _getWithFallback('/expenses?user_id=$_userId&limit=$limit&offset=$offset');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get expenses error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSummary() async {
    if (_userId == null) return null;
    try {
      final response = await _getWithFallback('/summary?user_id=$_userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get summary error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMonthlyAnalytics({int? month, int? year}) async {
    if (_userId == null) return null;
    try {
      var url = '/analytics/monthly?user_id=$_userId';
      if (month != null) url += '&month=$month';
      if (year != null) url += '&year=$year';

      final response = await _getWithFallback(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get monthly analytics error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    final uid = _userId ?? 1;
    try {
      final response = await _getWithFallback('/goals?user_id=$uid');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get goals error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createGoal({
    required String title,
    required String goalType,
    required double targetValue,
    String timeframe = 'monthly',
  }) async {
    final uid = _userId ?? 1;
    try {
      final response = await _postWithFallback(
        '/goals?user_id=$uid',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': uid,
          'title': title,
          'goal_type': goalType,
          'target_value': targetValue,
          'timeframe': timeframe,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Create goal error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    if (_userId == null) return [];
    try {
      final response = await _getWithFallback('/achievements?user_id=$_userId');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get achievements error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await _getWithFallback('/leaderboard');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get leaderboard error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTips({String? category}) async {
    try {
      var url = '/tips';
      if (category != null) url += '?category=$category';
      final response = await _getWithFallback(url);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get tips error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (_userId == null) return null;
    try {
      final response = await _getWithFallback('/profile?user_id=$_userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    final uid = _userId ?? 1;
    List<String> urls = [_activeBaseUrl, ..._candidateUrls.where((u) => u != _activeBaseUrl)];
    for (final base in urls) {
      try {
        final response = await http.delete(
          Uri.parse('$base/expenses/$expenseId?user_id=$uid'),
        ).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          _activeBaseUrl = base;
          return true;
        }
      } catch (e) {
        print('Delete expense error on $base: $e');
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> getWeather() async {
    try {
      final response = await _getWithFallback('/weather');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get weather error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getForecast() async {
    final uid = _userId ?? 1;
    try {
      final response = await _getWithFallback('/analytics/forecast?user_id=$uid');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get forecast error: $e');
      return null;
    }
  }

  Future<String?> exportExpensesCSV() async {
    final uid = _userId ?? 1;
    try {
      final response = await _getWithFallback('/export/csv?user_id=$uid');
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Export CSV error: $e');
      return null;
    }
  }

  Future<String?> sendChatMessage(String message) async {
    final uid = _userId ?? 1;
    try {
      final response = await _postWithFallback(
        '/ai/chat',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': uid, 'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }
      return null;
    } catch (e) {
      print('Send chat message error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> scanReceiptOCR(String text) async {
    try {
      final response = await _postWithFallback(
        '/scan/ocr',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Scan OCR error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> compareTransport(double distanceKm) async {
    try {
      final response = await _getWithFallback('/transport/compare?distance_km=$distanceKm');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Compare transport error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getChallenges() async {
    final uid = _userId ?? 1;
    try {
      final response = await _getWithFallback('/challenges?user_id=$uid');
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get challenges error: $e');
      return [];
    }
  }

  Future<bool> claimChallenge(int questId, int rewardXp) async {
    final uid = _userId ?? 1;
    try {
      final response = await _postWithFallback(
        '/challenges/claim',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': uid, 'quest_id': questId, 'reward_xp': rewardXp}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Claim challenge error: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    final uid = _userId ?? 1;
    List<String> urls = [_activeBaseUrl, ..._candidateUrls.where((u) => u != _activeBaseUrl)];
    for (final base in urls) {
      try {
        final response = await http.delete(
          Uri.parse('$base/goals/$goalId?user_id=$uid'),
        ).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          _activeBaseUrl = base;
          return true;
        }
      } catch (e) {
        print('Delete goal error on $base: $e');
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> getEcoOffset() async {
    final uid = _userId ?? 1;
    final response = await _getWithFallback('/analytics/eco-offset?user_id=$uid');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> plantTree() async {
    final uid = _userId ?? 1;
    final response = await _postWithFallback('/analytics/plant-tree?user_id=$uid');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}

final apiService = ApiService();
