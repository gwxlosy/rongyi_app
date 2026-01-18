import 'package:flutter/material.dart';

/// 手语翻译页（单页面）
/// - 风格沿用登录页的暖色渐变与圆角卡片
/// - 结构：顶部返回+标题 -> 数字人窗口（占位） -> 气泡列表 -> 底部输入条（带“手语”发送按钮）
/// - 行为：点击“手语”按钮，使用输入框文字新增一条气泡并模拟触发翻译
class SignTranslatePage extends StatefulWidget {
  const SignTranslatePage({super.key});

  @override
  State<SignTranslatePage> createState() => _SignTranslatePageState();
}

class _SignTranslatePageState extends State<SignTranslatePage> {
  final List<String> _messages = <String>[];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _listCtrl.dispose();
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
              // 顶部栏：返回 + 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    _roundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '手语翻译',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42), // 占位，保证标题居中
                  ],
                ),
              ),

              // 数字人窗口（占位）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 180,
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
                  child: Center(
                    child: Text(
                      '数字人窗口',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 气泡列表
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
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
                    child: _messages.isEmpty
                        ? Center(
                            child: Text(
                              '会以气泡形式展示你在下方输入框中输入的文字',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
                            ),
                          )
                        : ListView.builder(
                            controller: _listCtrl,
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) => _bubbleRight(_messages[index]),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 底部输入条 + 手语按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
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
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _inputCtrl,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _onSend(),
                            decoration: const InputDecoration(
                              hintText: '点击这里输入文字…',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _primaryCircleButton(
                      icon: Icons.front_hand_rounded,
                      onTap: _onSend,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 发送：新增一条用户侧气泡，并模拟触发翻译
  Future<void> _onSend() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(text);
      _inputCtrl.clear();
    });

    await Future.delayed(const Duration(milliseconds: 60));
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }

    // 模拟触发“数字人翻译”
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已发送，数字人开始翻译（示例）')),
      );
    }
  }

  // 用户侧气泡（右侧）
  Widget _bubbleRight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26FF6E7F),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 渐变主色圆形按钮（底部“手语”）
  Widget _primaryCircleButton({required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 46,
      height: 46,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40FF6E7F),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // 顶部返回按钮（白底圆形）
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

