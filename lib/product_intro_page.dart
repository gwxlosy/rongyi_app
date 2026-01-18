import 'package:flutter/material.dart';

/// 产品介绍页（单页面）
/// - 风格沿用登录页：暖色渐变背景 + 圆角白卡片
/// - 结构：顶部返回 + 渐变标题；中间为横向可滑动的功能卡片轮播；底部指示点
/// - 仅页面实现，不做额外路由改动或资源依赖（使用占位图标/文字说明）
class ProductIntroPage extends StatefulWidget {
  const ProductIntroPage({super.key});

  @override
  State<ProductIntroPage> createState() => _ProductIntroPageState();
}

class _ProductIntroPageState extends State<ProductIntroPage> {
  final _controller = PageController(viewportFraction: 0.82);
  int _index = 0;

  final List<_IntroItem> _items = const [
    _IntroItem(
      icon: Icons.front_hand_rounded,
      title: '手语翻译',
      desc: '将文字/语音转为手语动作，由数字人在屏幕中演示。',
    ),
    _IntroItem(
      icon: Icons.text_fields_rounded,
      title: '手语转文字',
      desc: '通过摄像检测识别手语动作，并实时输出文字。',
    ),
    _IntroItem(
      icon: Icons.school_rounded,
      title: '手语学习',
      desc: '提供学习课程与示例动作，循序渐进掌握基础手语。',
    ),
    _IntroItem(
      icon: Icons.library_books_rounded,
      title: '词库',
      desc: '内置常用手语词汇分类，支持快速检索与预览。',
    ),
    _IntroItem(
      icon: Icons.settings_suggest_rounded,
      title: '个性化设置',
      desc: '调整手语速度、对话角色等偏好，获得更好体验。',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
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
              // 顶部：返回 + 渐变标题
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
                            '产品介绍',
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

              // 轮播区域
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double t = 0.0;
                        if (_controller.position.haveDimensions) {
                          final double page = (_controller.page ?? _controller.initialPage.toDouble());
                          t = page - i;
                        }
                        t = (1 - (t.abs() * 0.12)).clamp(0.9, 1.0).toDouble();
                        return Transform.scale(scale: t, child: child);
                      },
                      child: _introCard(_items[i]),
                    );
                  },
                ),
              ),

              // 指示点
              Padding(
                padding: const EdgeInsets.only(bottom: 18, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: _index == i ? 18 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _index == i
                            ? const Color(0xFFFF7A59)
                            : const Color(0x33FF7A59),
                        borderRadius: BorderRadius.circular(999),
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

  // 单个功能卡片（渐变描边白卡） - 优化版，图片占据更大空间
  Widget _introCard(_IntroItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A59).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: const Color(0xFFFF7A59)),
                  ),
                  const SizedBox(height: 12),

                  // 标题
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 描述文字
                  Text(
                    item.desc,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.60),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 功能展示图片（占据剩余空间）
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEDE0DB),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'images/product1.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // 如果图片加载失败，显示占位
                            return Container(
                              color: Colors.black.withValues(alpha: 0.04),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '图片加载失败',
                                      style: TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

class _IntroItem {
  final IconData icon;
  final String title;
  final String desc;
  const _IntroItem({required this.icon, required this.title, required this.desc});
}
