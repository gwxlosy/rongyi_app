import 'dart:async';
import 'package:flutter/material.dart';
import 'sign_tutorial_page.dart';
import 'settings_page.dart';
import 'sign_to_text_page.dart';

/// 软件首页（单页面）
/// - 风格沿用登录页的暖色渐变与圆角卡片
/// - 页面上下分区：
///   1) 上半区：数字人展示窗口（仅占位）
///   2) 下半区：聊天区（以气泡形式展示每次输入）可上下滑动
/// - 底部三个圆形按钮代表三种输入方式：手语/录音/键盘
/// - 每次输入都会新增一个靠右的用户气泡
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _messages = <String>[];
  final ScrollController _scrollController = ScrollController();

  // 录音模拟状态
  bool _recording = false;
  Timer? _asrTimer;
  int _asrIndex = 0;
  final List<String> _demoAsr = [
    '你好～',
    '这是语音识别示例内容。',
    '我们开始沟通吧。',
    '请继续说话，我在聆听～',
  ];

  @override
  void dispose() {
    _asrTimer?.cancel();
    _scrollController.dispose();
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
          child: Stack(
            children: [


              // 主体
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // 上半区：数字人展示窗口（占位）
                  Expanded(
                    flex: 5,
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
                        child: Stack(
                          children: [
                            Positioned(
                              right: 8,
                              top: 8,
                              child: _roundIconButtonAccent(
                                context,
                                icon: Icons.settings,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.smart_toy_outlined, size: 42, color: const Color(0xFFFF7A59)),
                                  const SizedBox(height: 8),
                                  Text(
                                    '数字人展示区域（占位）',
                                    style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 下半区：聊天区（气泡列表）
                  Expanded(
                    flex: 6,
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
                            '在这里会以气泡形式显示你的输入',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.35),
                            ),
                          ),
                        )
                            : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final text = _messages[index];
                            return _bubbleRight(text);
                          },
                        ),
                      ),
                    ),
                  ),

                  // 底部三枚圆形输入方式按钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundAction(
                          context,
                          icon: Icons.front_hand_rounded,
                          label: '手语',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignTutorialPage(),
                              ),
                            );
                          },
                        ),
                        _roundAction(
                          context,
                          icon: _recording ? Icons.pause_rounded : Icons.mic_none_rounded,
                          label: _recording ? '暂停' : '录音',
                          onTap: _toggleRecording,
                        ),
                        _roundAction(
                          context,
                          icon: Icons.keyboard_alt_outlined,
                          label: '键盘',
                          onTap: () => _onInput(type: '键盘'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 统一输入入口：根据不同类型弹出底部输入面板
  Future<void> _onInput({required String type}) async {
    final result = await _showInputSheet(
      title: '$type 输入',
      hint: '请输入要转换/发送的内容…',
      confirmText: '发送',
    );

    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _messages.add(result.trim()));
      await Future.delayed(const Duration(milliseconds: 60));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // 底部输入面板
  Future<String?> _showInputSheet({
    required String title,
    required String hint,
    String confirmText = '确定',
  }) async {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 12,
            right: 12,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  maxLines: null,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8A5C), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
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
                          color: Color(0x4DFF6E7F),
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
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            Navigator.pop(ctx);
                          } else {
                            Navigator.pop(ctx, text);
                          }
                        },
                        child: const Center(
                          child: Text(
                            '发送',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
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

  // 次级小按钮（白底描边）
  Widget _secondaryChip(BuildContext context, {required String label, VoidCallback? onTap}) {
    return SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 圆形操作按钮（白底阴影）+ 下方文字
  Widget _roundAction(BuildContext context, {required IconData icon, required String label, VoidCallback? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _roundIconButton(context, icon: icon, onTap: onTap),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 通用圆形按钮
  Widget _roundIconButton(BuildContext context, {required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 46,
      height: 46,
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

  // 醒目样式的圆形按钮（用于右上角设置）
  Widget _roundIconButtonAccent(BuildContext context, {required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 50,
      height: 50,
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
              blurRadius: 16,
              offset: Offset(0, 8),
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

  // 切换录音（模拟语音识别 -> 定时追加文字到气泡）
  void _toggleRecording() {
    if (_recording) {
      _asrTimer?.cancel();
      setState(() => _recording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已暂停录音')),
      );
    } else {
      setState(() => _recording = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开始录音，正在识别…')),
      );
      _asrTimer?.cancel();
      _asrTimer = Timer.periodic(const Duration(seconds: 1), (_) => _emitAsr());
    }
  }

  void _emitAsr() {
    if (!_recording) return;
    final text = _demoAsr[_asrIndex % _demoAsr.length];
    _asrIndex++;
    setState(() => _messages.add(text));
    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
