import 'package:flutter/material.dart';

/// 手语速度页（单页面）
/// - 风格：沿用登录页的暖色渐变与圆角白卡片
/// - 功能：选择【慢速/正常/快速】，下方预览区以动画演示不同速度效果（示例）
class SignSpeedPage extends StatefulWidget {
  const SignSpeedPage({super.key});

  @override
  State<SignSpeedPage> createState() => _SignSpeedPageState();
}

class _SignSpeedPageState extends State<SignSpeedPage>
    with SingleTickerProviderStateMixin {
  String _speed = '正常';
  late final AnimationController _ctrl;
  late Animation<double> _offsetAni;

  Duration get _duration {
    switch (_speed) {
      case '慢速':
        return const Duration(milliseconds: 1200);
      case '快速':
        return const Duration(milliseconds: 350);
      case '正常':
      default:
        return const Duration(milliseconds: 700);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _offsetAni = Tween<double>(begin: -14, end: 14)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_ctrl);
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPick(String v) {
    setState(() => _speed = v);
    _ctrl.duration = _duration;
    // 让动画流畅承接
    if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true); // 保底
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
              // 顶部：返回 + 渐变标题
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    _roundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(_speed),
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
                            '手语速度',
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
                    const SizedBox(width: 42), // 占位，保持标题居中
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _subHeader('手语速度选择'),
                      const SizedBox(height: 6),
                      _speedPickerCard(),

                      const SizedBox(height: 18),

                      _subHeader('速度预览'),
                      const SizedBox(height: 6),
                      _previewCard(),

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

  // 速度选择卡片
  Widget _speedPickerCard() {
    return _gradientCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          children: [
            _radioTile('慢速'),
            const Divider(height: 1, color: Color(0xFFF0E6E2)),
            _radioTile('正常'),
            const Divider(height: 1, color: Color(0xFFF0E6E2)),
            _radioTile('快速'),
          ],
        ),
      ),
    );
  }

  Widget _radioTile(String value) {
    final selected = _speed == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onPick(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            AnimatedContainer(
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
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  // 速度预览卡片（手掌左右摆动表示速度）
  Widget _previewCard() {
    return _gradientCard(
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            // 辅助文案
            Positioned(
              left: 14,
              top: 12,
              right: 14,
              child: Text(
                '选择不同的手语速度后，可在此查看不同速度下的手势演示（示例）',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.55), height: 1.35),
              ),
            ),
            // 动画演示
            Center(
              child: AnimatedBuilder(
                animation: _offsetAni,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_offsetAni.value, 0),
                    child: Transform.rotate(
                      angle: _offsetAni.value / 40,
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.front_hand_rounded,
                  size: 96,
                  color: Color(0xFFFF7A59),
                ),
              ),
            ),
            // 速度文本
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A59).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '当前速度：$_speed',
                    style: const TextStyle(
                      color: Color(0xFFFF7A59),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 通用：渐变描边白卡
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
}

