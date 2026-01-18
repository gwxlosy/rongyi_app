import 'package:flutter/material.dart';

/// 手语翻译官（单页面）
/// - 风格沿用登录页：暖色渐变背景 + 圆角白卡片
/// - 功能：在页面中选择一个“对话角色”，支持点击右侧扬声器图标进行“声音预览（示例）”
/// - 仅页面实现，不做路由改动
class SignTranslatorPage extends StatefulWidget {
  const SignTranslatorPage({super.key});

  @override
  State<SignTranslatorPage> createState() => _SignTranslatorPageState();
}

class _SignTranslatorPageState extends State<SignTranslatorPage> {
  String _selected = '依依：女性对话角色';

  final List<String> _roles = const <String>[
    '依依：女性对话角色',
    '云野：男性对话角色',
    '小萌：儿童对话角色',
  ];

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
              // 顶部：返回 + 渐变标题
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    _roundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(_selected)
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
                            '手语翻译官',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _subHeader('对话角色选择'),
                      const SizedBox(height: 6),
                      _gradientCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            children: [
                              ..._roles.expand((r) => [
                                    _roleRow(r),
                                    if (r != _roles.last)
                                      const Divider(height: 1, color: Color(0xFFF0E6E2)),
                                  ]),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _subHeader('提示'),
                      _gradientCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '选择不同的角色后，点击右侧的扬声器可以预览不同的声音（示例）。',
                            style: TextStyle(color: Colors.black.withValues(alpha: 0.60), height: 1.35),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 单行角色项
  Widget _roleRow(String label) {
    final selected = _selected == label;
    return InkWell(
      onTap: () => setState(() => _selected = label),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            IconButton(
              tooltip: '预览声音（示例）',
              onPressed: () => _toast('预览：$label'),
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFF7A59)),
            ),
            const SizedBox(width: 2),
            _radioDot(selected),
          ],
        ),
      ),
    );
  }

  // 自定义单选圆点
  Widget _radioDot(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFFF7A59) : const Color(0xFFBDBDBD),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selected ? 10 : 0,
          height: selected ? 10 : 0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF7A59),
          ),
        ),
      ),
    );
  }

  // 渐变描边白卡
  Widget _gradientCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.2),
        child: DecoratedBox(
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
          child: child,
        ),
      ),
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

  // 顶部圆形按钮
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

