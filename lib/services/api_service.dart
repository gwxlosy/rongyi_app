import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 注意：数据模型类现在从 database_helper.dart 移动或复制到这里
// 为了解耦，最好将它们移动到一个新的 models/ 文件夹下
// 但为了简单起见，我们暂时在这里重新定义它们

// --- 数据模型 ---

class SignWord {
  final int id;
  final String word;
  final String category;
  final String description;
  final String videoPath;

  SignWord({
    required this.id,
    required this.word,
    required this.category,
    required this.description,
    required this.videoPath,
  });

  factory SignWord.fromJson(Map<String, dynamic> json) {
    return SignWord(
      id: json['id'],
      word: json['word'],
      category: json['category'],
      description: json['description'],
      videoPath: json['video_path'],
    );
  }
}

class User {
  final int id;
  final String account;
  final DateTime createTime;

  User({
    required this.id,
    required this.account,
    required this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      account: json['account'],
      createTime: DateTime.parse(json['create_time']),
    );
  }
}

class Feedback {
  final int id;
  final int userId;
  final String type;
  final String content;
  final DateTime createTime;

  Feedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.createTime,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      content: json['content'],
      createTime: DateTime.parse(json['create_time']),
    );
  }
}


// --- API 服务类 ---

class ApiService {
  static final ApiService instance = ApiService._init();
  late Dio _dio;

  ApiService._init() {
    final options = BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    _dio = Dio(options);
  }

  String _getBaseUrl() {
    // 生产环境URL，从环境变量读取
    const prodUrl = String.fromEnvironment('PROD_URL');
    if (prodUrl.isNotEmpty) {
      return prodUrl;
    }

    // 开发环境URL
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://127.0.0.1:8000';
    } else {
      // 默认或iOS模拟器
      return 'http://127.0.0.1:8000';
    }
  }

  // 辅助方法处理API错误
  dynamic _handleError(DioException e) {
    print('API请求发生错误: ${e.message}');
    // 可以根据 e.response.statusCode 做更详细的处理
    throw Exception('网络请求失败: ${e.response?.data['detail'] ?? e.message}');
  }

  // ========== 词汇相关方法 ==========

  Future<List<String>> getAllCategories() async {
    try {
      final response = await _dio.get('/categories/');
      return List<String>.from(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<List<SignWord>> getWordsByCategory(String category) async {
    try {
      final response = await _dio.get('/words/', queryParameters: {'category': category});
      return (response.data as List).map((json) => SignWord.fromJson(json)).toList();
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<List<SignWord>> searchWords(String keyword) async {
    try {
      final response = await _dio.get('/words/search/', queryParameters: {'keyword': keyword});
      return (response.data as List).map((json) => SignWord.fromJson(json)).toList();
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ========== 用户相关方法 ==========

  Future<User?> registerUser(String account, String password) async {
    try {
      final response = await _dio.post('/users/', data: {
        'account': account,
        'password': password,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      // 特殊处理账号已存在的情况
      if (e.response?.statusCode == 400) {
        throw Exception('账号已存在');
      }
      return _handleError(e);
    }
  }

  Future<User?> loginUser(String account, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'account': account,
        'password': password,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('账号或密码错误');
      }
      return _handleError(e);
    }
  }

  // ========== 反馈相关方法 ==========

  Future<Feedback> saveFeedback(int userId, String type, String content) async {
    try {
      final response = await _dio.post('/feedbacks/', data: {
        'user_id': userId,
        'type': type,
        'content': content,
      });
      return Feedback.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<List<Feedback>> getUserFeedbacks(int userId) async {
    try {
      final response = await _dio.get('/users/$userId/feedbacks/');
      return (response.data as List).map((json) => Feedback.fromJson(json)).toList();
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<void> deleteFeedback(int feedbackId) async {
    try {
      await _dio.delete('/feedbacks/$feedbackId');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<void> clearUserFeedbacks(int userId) async {
    try {
      await _dio.delete('/users/$userId/feedbacks/');
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
