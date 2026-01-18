import 'package:flutter/material.dart';

/// 用户协议页（单页面）
/// - 风格沿用登录页：暖色渐变背景 + 圆角白卡片
/// - 内容：示例协议段落，支持滚动浏览
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 2),
                            ShaderMask(
                              shaderCallback: (rect) => const LinearGradient(
                                colors: [Color(0xFFFA7C3B), Color(0xFFFF6E7F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(rect),
                              child: const Text(
                                '手语翻译官用户服务协议',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
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
                          _title('重要提示'),
                          _p('在您使用本产品及相关服务前，请务必仔细阅读并充分理解本协议的全部内容。您开始使用即视为已阅读、理解并接受本协议。'),
                          const SizedBox(height: 8),
                          _title('一、协议范围'),
                          _p('本协议是您（“用户”）与本应用就产品与服务的使用所订立的协议，约束双方的权利义务。'),
                          _title('二、账号与安全'),
                          _p('您应妥善保管账号与密码，并对在该账号下进行的所有活动承担责任。'),
                          _title('三、许可与限制'),
                          _ul([
                            '授予您个人、非商业目的的使用许可；',
                            '禁止反向工程、商业出租或转售本产品与服务；',
                            '不得利用本产品从事违法违规行为。',
                          ]),
                          _title('四、服务变更与终止'),
                          _p('我们可能根据运营情况对服务内容进行调整、暂停或终止，并会在合理范围内提前通知。'),
                          _title('五、免责声明'),
                          _p('在法律允许范围内，对于因网络、设备故障及不可抗力造成的服务中断或数据损失，我们将尽力修复，但不承担由此产生的间接损失。'),
                          _title('六、其他'),
                          _p('本协议未尽事项，依照相关法律法规及本应用发布的其他规则执行。'),
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

