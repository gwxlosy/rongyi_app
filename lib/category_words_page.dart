import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'word_detail_page.dart';

/// 分类词汇列表页
/// 显示某个分类下的所有词汇
class CategoryWordsPage extends StatefulWidget {
  final String category;

  const CategoryWordsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryWordsPage> createState() => _CategoryWordsPageState();
}

class _CategoryWordsPageState extends State<CategoryWordsPage> {
  List<SignWord> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  /// 从数据库加载该分类的词汇
  Future<void> _loadWords() async {
    setState(() => _isLoading = true);

    try {
      final words = await DatabaseHelper.instance.getWordsByCategory(widget.category);

      if (!mounted) return;

      setState(() {
        _words = words;
        _isLoading = false;
      });

      debugPrint('✅ 加载了 ${words.length} 个词汇');
    } catch (e) {
      debugPrint('❌ 加载词汇失败: $e');

      if (!mounted) return;

      setState(() => _isLoading = false);
    }
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
                          child: Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),

              // 词汇数量提示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '共 ${_words.length} 个词汇',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 词汇列表
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF7A59),
                  ),
                )
                    : _words.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Color(0xFFBDBDBD),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无词汇',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final word = _words[index];
                    return _wordCard(word, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 单个词汇卡片
  Widget _wordCard(SignWord word, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // 跳转到词汇详情页
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordDetailPage(word: word),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // 序号
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A59).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              color: Color(0xFFFF7A59),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 词汇名称和简短描述
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.description.length > 30
                                  ? '${word.description.substring(0, 30)}...'
                                  : word.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withOpacity(0.5),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 箭头图标
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFBDBDBD),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 圆形返回按钮
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