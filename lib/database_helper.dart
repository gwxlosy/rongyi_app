import 'services/api_service.dart';

// 数据模型现在从 api_service.dart 导入
export 'services/api_service.dart' show SignWord, User, Feedback;

///
/// 数据仓库层 (Repository Layer)
///
/// 这个类现在作为API服务的代理，负责调用ApiService中的方法。
/// UI层代码无需关心数据是来自本地还是网络。
///
class DatabaseHelper {
  // 仍然使用单例模式，保持接口一致性
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // 获取API服务的实例
  final ApiService _api = ApiService.instance;

  // ========== 词汇相关方法 ==========

  Future<List<SignWord>> getWordsByCategory(String category) async {
    return await _api.getWordsByCategory(category);
  }

  Future<List<String>> getAllCategories() async {
    return await _api.getAllCategories();
  }

  Future<List<SignWord>> searchWords(String keyword) async {
    return await _api.searchWords(keyword);
  }

  // 注意：getWordById 和 insertWord 在原始代码中存在，但在后端API中没有直接对应，
  // 这里暂时注释掉。如果需要，应在后端添加相应接口。
  /*
  Future<SignWord?> getWordById(int id) async {
    // return await _api.getWordById(id);
  }

  Future<int> insertWord(SignWord word) async {
    // return await _api.createWord(word);
  }
  */

  // ========== 用户相关方法 ==========

  Future<User?> registerUser(String account, String password) async {
    return await _api.registerUser(account, password);
  }

  Future<User?> loginUser(String account, String password) async {
    return await _api.loginUser(account, password);
  }

  // 注意：getUserById 在原始代码中存在，但在后端API中没有直接对应，
  // 这里暂时注释掉。如果需要，应在后端添加相应接口。
  /*
  Future<User?> getUserById(int id) async {
    // return await _api.getUserById(id);
  }
  */

  // ========== 反馈相关方法 ==========

  Future<Feedback> saveFeedback(int userId, String type, String content) async {
    return await _api.saveFeedback(userId, type, content);
  }

  Future<List<Feedback>> getUserFeedbacks(int userId) async {
    return await _api.getUserFeedbacks(userId);
  }

  Future<void> deleteFeedback(int id, int userId) async {
    // 后端API设计为只需要feedbackId，所以userId暂时不用
    await _api.deleteFeedback(id);
  }

  Future<void> clearUserFeedbacks(int userId) async {
    await _api.clearUserFeedbacks(userId);
  }

  // 不再需要数据库路径和关闭方法
  // Future<String> getDatabasePath() async => 'N/A';
  // Future close() async => {};
}
