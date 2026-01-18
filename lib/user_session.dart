import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

/// 用户会话管理类
class UserSession {
  static const String _keyUserId = 'current_user_id';
  static const String _keyUserAccount = 'current_user_account';
  static final UserSession instance = UserSession._init();

  UserSession._init();

  int? _currentUserId;
  String? _currentUserAccount;

  /// 获取当前登录用户ID
  int? get currentUserId => _currentUserId;

  /// 获取当前登录用户账号
  String? get currentUserAccount => _currentUserAccount;

  /// 是否已登录
  bool get isLoggedIn => _currentUserId != null;

  /// 初始化会话（从本地存储加载）
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    final userAccount = prefs.getString(_keyUserAccount);

    if (userId != null && userAccount != null) {
      _currentUserId = userId;
      _currentUserAccount = userAccount;
    }
  }

  /// 登录用户
  Future<void> login(User user) async {
    _currentUserId = user.id;
    _currentUserAccount = user.account;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id!);
    await prefs.setString(_keyUserAccount, user.account);
  }

  /// 登出用户
  Future<void> logout() async {
    _currentUserId = null;
    _currentUserAccount = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserAccount);
  }

  /// 清除会话
  void clear() {
    _currentUserId = null;
    _currentUserAccount = null;
  }
}
