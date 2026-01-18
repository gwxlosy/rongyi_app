import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// 意见反馈页面
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = '功能建议';
  final List<String> _feedbackTypes = [
    '功能建议',
    '问题反馈',
    '体验优化',
    '其他',
  ];

  @override
  void dispose() {
    _contentController.dispose();
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
                            '意见反馈',
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
                    const SizedBox(width: 42),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // 意见类型选择
                      _sectionHeader('意见类型'),
                      const SizedBox(height: 8),
                      _typeSelector(),

                      const SizedBox(height: 24),

                      // 意见内容
                      _sectionHeader('意见内容'),
                      const SizedBox(height: 8),
                      _contentInput(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // 提交按钮
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
                        onTap: _submitFeedback,
                        child: const Center(
                          child: Text(
                            '提交反馈',
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

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _typeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: _feedbackTypes.map((type) {
          final isSelected = type == _selectedType;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _selectedType = type),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFF7A59),
                        )
                      else
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (type != _feedbackTypes.last)
                const Divider(height: 1, color: Color(0xFFF0E6E2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _contentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '请详细描述您的意见或建议...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入意见内容')),
      );
      return;
    }

    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7A59),
        ),
      ),
    );

    try {
      // TODO: Replace with the actual logged-in user's ID.
      // This should be retrieved from a state management solution (Provider, Bloc, etc.)
      // or passed as an argument to this page.
      const int currentUserId = 1;

      await DatabaseHelper.instance.saveFeedback(
        currentUserId,
        _selectedType,
        content,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('反馈提交失败: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; // Stop execution on error
    }

    if (!mounted) return;

    Navigator.pop(context); // 关闭加载提示

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('反馈提交成功，感谢您的建议！'),
        backgroundColor: Colors.green,
      ),
    );

    // 返回上一页
    Navigator.pop(context);
  }

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
