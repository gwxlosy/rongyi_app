import 'package:flutter/material.dart';
import 'feedback_page.dart';
import 'feedback_record_page.dart';

/// 帮助与反馈页（单页面）
/// - 风格沿用登录页的暖色渐变与圆角卡片
/// - 结构：顶部返回 + 标题/反馈记录；搜索框；常用工具；常见问题（热门/常见 Tab）；底部"意见反馈"按钮
class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

  // 热门问题和答案
  final Map<String, String> _hotQuestions = {
    '手语识别功能目前支持识别哪些词汇？':
    '目前手语识别功能支持识别13个分类的词汇，包括通用词汇、日常交流、情绪表达、数字时间、地点方向、人物称谓、动作行为、学习教育、医疗健康、餐饮饮食、出行交通、娱乐运动、生活服务等。您可以在词库页面查看所有支持的词汇。',
    '手语虚拟人目前支持哪些词汇？':
    '手语虚拟人支持与手语识别相同的词汇库，涵盖13个分类的常用词汇。虚拟人会根据您输入的文字自动生成对应的手语动作，帮助您更好地学习和理解手语。',
    '听音功能/手语回复/文字回复功能无法使用？':
    '如果这些功能无法使用，请检查以下几点：1. 确保应用已获得麦克风权限；2. 检查网络连接是否正常；3. 尝试重启应用；4. 如果问题仍然存在，请通过意见反馈联系我们。',
    '如何调整对话功能播报音量？':
    '您可以在设置页面中找到音量调节选项。如果设置页面中没有该选项，您也可以通过手机系统设置来调整应用的音量。我们会在后续版本中添加更详细的音量控制功能。',
  };

  // 常见问题和答案
  final Map<String, String> _commonQuestions = {
    '开屏太慢或黑屏如何解决？':
    '如果遇到开屏太慢或黑屏问题，建议您：1. 清理应用缓存；2. 检查手机存储空间是否充足；3. 尝试重启应用；4. 如果问题持续，可以尝试卸载后重新安装应用。',
    '登录失败怎么办？':
    '登录失败可能由以下原因导致：1. 网络连接问题，请检查网络设置；2. 账号或密码错误，请确认输入正确；3. 服务器维护，请稍后再试。如果问题仍然存在，请联系客服或通过意见反馈提交问题。',
    '无法联网或提示网络异常？':
    '网络异常时请检查：1. 手机网络连接是否正常；2. 是否开启了飞行模式；3. 应用是否有网络访问权限；4. 尝试切换WiFi或移动网络。如果问题持续，可能是服务器问题，请稍后再试。',
    '如何清理缓存？':
    '清理缓存的方法：1. 在设置页面找到"清理缓存"选项；2. 或者在手机系统设置中找到应用管理，选择"融意"应用，点击"清除缓存"。清理缓存不会影响您的个人数据和反馈记录。',
  };

  // 获取所有问题列表（用于搜索）
  List<String> get _allQuestions => [
    ..._hotQuestions.keys,
    ..._commonQuestions.keys,
  ];

  // 获取所有问题和答案的映射
  Map<String, String> get _allQAndA => {
    ..._hotQuestions,
    ..._commonQuestions,
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFE6D7), Color(0xFFFFF3EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部栏
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    _roundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            colors: [Color(0xFFFA7C3B), Color(0xFFFF6E7F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(rect),
                          child: const Text(
                            '帮助与反馈',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackRecordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '反馈记录',
                        style: TextStyle(color: Color(0xFFFF7A59)),
                      ),
                    ),
                  ],
                ),
              ),

              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFFBDBDBD)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '请输入您的问题',
                              border: InputBorder.none,
                              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                              suffixIcon: _showClearButton
                                  ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20, color: Color(0xFFBDBDBD)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _showClearButton = false);
                                },
                              )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() => _showClearButton = value.isNotEmpty);
                            },
                            onSubmitted: (value) => _handleSearch(value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _subHeader('常用工具'),
                      _toolsGrid(),

                      const SizedBox(height: 16),

                      _subHeader('常见问题'),
                      _faqTabs(),

                      const SizedBox(height: 80), // 为底部按钮预留空间
                    ],
                  ),
                ),
              ),

              // 底部"意见反馈"按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40FF6E7F),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FeedbackPage(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            '意见反馈',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 处理搜索
  void _handleSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    // 搜索匹配的问题
    final matchedQuestion = _allQuestions.firstWhere(
          (question) => question.contains(keyword.trim()),
      orElse: () => '',
    );

    if (matchedQuestion.isNotEmpty) {
      // 找到匹配的问题，显示答案
      _showAnswerDialog(matchedQuestion, _allQAndA[matchedQuestion]!);
    } else {
      // 没有找到匹配的问题
      _showNoAnswerDialog();
    }
  }

  // 显示答案弹窗
  void _showAnswerDialog(String question, String answer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A59).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示无答案弹窗
  void _showNoAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 60,
                color: Color(0xFFFF7A59),
              ),
              const SizedBox(height: 16),
              const Text(
                '暂时没有回答',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '抱歉，暂时没有找到相关问题的答案。\n您可以通过意见反馈向我们提问。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 常用工具 Grid
  Widget _toolsGrid() {
    final items = [
      _Tool(icon: Icons.store_mall_directory_rounded, color: const Color(0xFF5C6BC0), label: '服务网点'),
      _Tool(icon: Icons.forum_rounded, color: const Color(0xFF26A69A), label: '官方社区'),
      _Tool(icon: Icons.menu_book_rounded, color: const Color(0xFFFFA726), label: '使用手册'),
      _Tool(icon: Icons.support_agent_rounded, color: const Color(0xFFEC407A), label: '客服服务'),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        final e = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showToolDialog(e.label),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: e.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(e.icon, color: e.color),
              ),
              const SizedBox(height: 6),
              Text(e.label, style: const TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
        );
      },
    );
  }

  // 显示工具提示弹窗
  void _showToolDialog(String toolName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 50,
                color: Color(0xFFFF7A59),
              ),
              const SizedBox(height: 16),
              const Text(
                '该工具由融易官网提供',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FAQ Tabs
  Widget _faqTabs() {
    final hotQuestions = _hotQuestions.keys.toList();
    final commonQuestions = _commonQuestions.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            labelColor: const Color(0xFFFF7A59),
            unselectedLabelColor: const Color(0xFF9E9E9E),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFFFF7A59), width: 2),
            ),
            tabs: const [
              Tab(text: '热门问题'),
              Tab(text: '常见问题'),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF0E6E2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: SizedBox(
              height: 220,
              child: TabBarView(
                controller: _tabCtrl,
                physics: const BouncingScrollPhysics(),
                children: [
                  _faqList(hotQuestions, _hotQuestions),
                  _faqList(commonQuestions, _commonQuestions),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqList(List<String> questions, Map<String, String> qaMap) {
    return ListView.separated(
      itemCount: questions.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final question = questions[i];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: ListTile(
            leading: Text(
              '${i + 1}',
              style: const TextStyle(color: Color(0xFFFF7A59), fontWeight: FontWeight.w700),
            ),
            title: Text(question, style: const TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD)),
            onTap: () => _showAnswerDialog(question, qaMap[question]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _subHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.45),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // 顶部圆形返回按钮
  Widget _roundIconButton({required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: const Color(0xFFFF7A59)),
          ),
        ),
      ),
    );
  }
}

class _Tool {
  final IconData icon;
  final Color color;
  final String label;
  const _Tool({required this.icon, required this.color, required this.label});
}
