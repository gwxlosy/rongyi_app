import 'package:flutter/material.dart';
import 'sign_learning_page.dart';
import 'sign_speed_page.dart';
import 'sign_translator_page.dart';
import 'product_intro_page.dart';
import 'help_feedback_page.dart';
import 'user_agreement_page.dart';
import 'privacy_policy_page.dart';

/// 设置页（单页面）
/// - 风格沿用登录页的暖色渐变与圆角卡片
/// - 参考示意图分组：手语提升 / 功能设置 / 其它
/// - 所有条目先以示例交互实现（SnackBar/底部弹窗/开关）
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 示例状态
  String _speed = '正常';
  String _role = '愉悅';
  bool _improveEnabled = true;

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
                            '设置',
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
                    const SizedBox(width: 42), // 占位，保证标题居中
                  ],
                ),
              ),

              // 内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionHeader('手语提升'),
                      _card(
                        children: [
                          _arrowTile(
                            title: '手语学习',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignLearningPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _sectionHeader('功能设置'),
                      _card(
                        children: [
                          _valueTile(
                            title: '手语速度',
                            value: _speed,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignSpeedPage(),
                                ),
                              );
                              if (result is String && result.isNotEmpty) {
                                setState(() => _speed = result);
                              }
                            },
                          ),
                          _divider(),
                          _valueTile(
                            title: '对话角色',
                            value: _role,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignTranslatorPage(),
                                ),
                              );
                              if (result is String && result.isNotEmpty) {
                                setState(() => _role = result);
                              }
                            },
                          ),
                          _divider(),
                          _arrowTile(
                            title: '产品介绍',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProductIntroPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _sectionHeader('其它'),
                      _card(
                        children: [
                          _switchTile(
                            title: '帮助改进手语翻译官功能',
                            subtitle: '允许将错误样例留存用于模型精进，帮助改进功能效果',
                            value: _improveEnabled,
                            onChanged: (v) => setState(() => _improveEnabled = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _card(
                        children: [
                          _arrowTile(
                            title: '帮助与反馈',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpFeedbackPage(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _arrowTile(
                            title: '用户协议',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserAgreementPage(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _arrowTile(
                            title: '隐私声明',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyPage(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _valueTile(
                            title: '检查更新',
                            value: '版本 v1.3.0',
                            onTap: () => _toast('已是最新版本（示例）'),
                          ),
                        ],
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

  // 选择手语速度（底部弹窗）
  Future<void> _pickSpeed() async {
    final list = ['慢速', '正常', '快速'];
    final picked = await _pickFromList('手语速度', list, _speed);
    if (picked != null) setState(() => _speed = picked);
  }

  // 选择对话角色（底部弹窗）
  Future<void> _pickRole() async {
    final list = ['沉稳', '愉悅', '活泼'];
    final picked = await _pickFromList('对话角色', list, _role);
    if (picked != null) setState(() => _role = picked);
  }

  Future<String?> _pickFromList(String title, List<String> options, String current) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF6B6B6B)),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0E6E2)),
                ...options.map((e) => InkWell(
                  onTap: () => Navigator.pop(ctx, e),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: Text(e)),
                        if (e == current) const Icon(Icons.check_rounded, color: Color(0xFFFF7A59)),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 组件：分组标题
  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.35),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 组件：白卡
  Widget _card({required List<Widget> children}) {
    return DecoratedBox(
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
      child: Column(children: children),
    );
  }

  // 组件：分隔线
  Widget _divider() => const Divider(height: 1, color: Color(0xFFF0E6E2));

  // 组件：右侧箭头项
  Widget _arrowTile({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }

  // 组件：右侧值项
  Widget _valueTile({required String title, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }

  // 组件：开关项
  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.45), fontSize: 12, height: 1.2),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF7A59),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // 圆形按钮（顶部返回）
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

