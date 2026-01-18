import 'package:flutter/material.dart';

/// 隐私政策页（单页面）
/// - 风格沿用登录页：暖色渐变背景 + 圆角白卡片
/// - 内容：示例隐私条款段落，支持滚动浏览
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                            '隐私政策',
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

              // 正文
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title('引言'),
                          _p('我们非常重视您的个人信息与隐私保护。本政策阐述我们如何收集、使用、存储与共享相关信息。'),
                          _title('一、信息的收集'),
                          _ul([
                            '为实现基础功能所必需的信息（如账号、设备信息）；',
                            '为提升体验所选择性提供的信息（如反馈内容、日志信息）。',
                          ]),
                          _title('二、信息的使用'),
                          _p('我们将在合法、正当、必要的前提下使用您的信息，用于提供服务、优化体验与保障安全。'),
                          _title('三、信息的共享与披露'),
                          _p('除法律法规规定或经您授权，我们不会向第三方共享或披露您的个人信息。'),
                          _title('四、信息的存储与安全'),
                          _p('我们将采取合理安全措施，防止信息的丢失、滥用与未经授权访问。'),
                          _title('五、您的权利'),
                          _ul([
                            '访问、更正与删除您的个人信息；',
                            '撤回授权、注销账号与获取副本。',
                          ]),
                          _title('六、政策更新'),
                          _p('我们可能适时更新本政策。重要变更将以显著方式通知您。继续使用代表您接受更新后的政策。'),
                        ],
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

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );

  Widget _p(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: TextStyle(color: Colors.black.withValues(alpha: 0.75), height: 1.5)),
      );

  Widget _ul(List<String> lines) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final t in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, height: 1.35)),
                    Expanded(child: Text(t, style: TextStyle(color: Colors.black.withValues(alpha: 0.75), height: 1.5))),
                  ],
                ),
              ),
          ],
        ),
      );

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

