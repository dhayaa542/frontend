import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';

class ApiService {
  static final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000'
          : 'http://127.0.0.1:8000');

  static Future<List<Lesson>> fetchLessons() async {
    final response = await http.get(Uri.parse('$baseUrl/lessons'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Lesson.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load lessons');
    }
  }

  static Future<List<QuizQuestion>> fetchQuiz(String lessonId) async {
    final response = await http.get(Uri.parse('$baseUrl/quiz/$lessonId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => QuizQuestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quiz');
    }
  }

  static Future<Map<String, dynamic>> registerUser(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    );
    return json.decode(response.body);
  }

  static Future<void> saveProgress(String userId, String lessonId, bool isCompleted) async {
    await http.post(
      Uri.parse('$baseUrl/progress'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'lesson_id': lessonId,
        'is_completed': isCompleted,
      }),
    );
  }

  static Future<List<dynamic>> fetchProgress(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/progress/$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['progress'];
    }
    return [];
  }

  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'streak_count': 0, 'coins': 0, 'gems': 0};
  }

  static Future<void> submitQuizResult(String userId, String lessonId, List<int?> answers) async {
    await http.post(
      Uri.parse('$baseUrl/quiz/result'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'lesson_id': lessonId,
        'answers': answers.map((a) => a ?? -1).toList(),
      }),
    );
  }

  static Future<Map<String, dynamic>?> getBudget(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/budget/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  static Future<void> saveBudget(Map<String, dynamic> budgetData) async {
    await http.post(
      Uri.parse('$baseUrl/budget'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(budgetData),
    );
  }
}
