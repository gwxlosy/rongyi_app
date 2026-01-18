import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'sign_to_text_page.dart';

/// 手语识别使用教程页
/// 播放教学视频，播放完成后自动跳转到手语识别页面
class SignTutorialPage extends StatefulWidget {
  const SignTutorialPage({super.key});

  @override
  State<SignTutorialPage> createState() => _SignTutorialPageState();
}

class _SignTutorialPageState extends State<SignTutorialPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// 初始化视频播放器
  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 从 assets 加载视频
      _videoController = VideoPlayerController.asset(
        'videos/teaches_video.mp4',
      );

      await _videoController!.initialize();

      if (!mounted) return;

      // 监听视频播放完成
      _videoController!.addListener(_videoListener);

      setState(() {
        _isVideoInitialized = true;
        _isLoading = false;
      });

      // 开始播放
      await _videoController!.play();

      debugPrint('✅ 视频初始化并播放成功');
    } catch (e) {
      debugPrint('❌ 视频初始化失败: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '视频加载失败';
      });

      // 如果视频加载失败，3秒后自动跳转
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_hasNavigated) {
          _goNext();
        }
      });
    }
  }

  /// 监听视频播放状态
  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    // 检查视频是否播放完成
    if (_videoController!.value.position >= _videoController!.value.duration) {
      if (!_hasNavigated && mounted) {
        debugPrint('📹 视频播放完成，准备跳转');
        _goNext();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  /// 跳转到手语识别页面
  void _goNext() {
    if (!mounted || _hasNavigated) return;

    setState(() {
      _hasNavigated = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignToTextPage()),
    );
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
              // 顶部返回按钮
              Positioned(
                left: 8,
                top: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),

              // 主体内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // 视频播放区域
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // 视频播放器或加载/错误状态
                              Positioned.fill(
                                child: _buildVideoContent(),
                              ),

                              // 右上角跳过按钮
                              Positioned(
                                right: 8,
                                top: 8,
                                child: _roundIconButton(
                                  context,
                                  icon: Icons.close_rounded,
                                  onTap: _goNext,
                                ),
                              ),

                              // 四角识别框装饰
                              if (_isVideoInitialized)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Stack(
                                      children: const [
                                        _Corner(top: true, left: true),
                                        _Corner(top: true, right: true),
                                        _Corner(bottom: true, left: true),
                                        _Corner(bottom: true, right: true),
                                      ],
                                    ),
                                  ),
                                ),

                              // 底部提示文字
                              if (_isVideoInitialized)
                                Positioned(
                                  bottom: 30,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '请将手臂放在检测框内进行手语识别',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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

                  const SizedBox(height: 16),

                  // 返回按钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: _secondaryChip(
                      context,
                      label: '返回',
                      onTap: () => Navigator.of(context).maybePop(),
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

  /// 构建视频内容（加载中/播放/错误）
  Widget _buildVideoContent() {
    if (_isLoading) {
      // 加载中
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFFF7A59),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              '正在加载教学视频...',
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      // 加载失败
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Color(0xFFFF7A59),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '3秒后自动进入识别页面',
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_isVideoInitialized && _videoController != null) {
      // 视频播放
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    // 默认状态
    return const SizedBox.shrink();
  }

  // 次级按钮（白底描边）
  Widget _secondaryChip(BuildContext context, {required String label, VoidCallback? onTap}) {
    return SizedBox(
      height: 44,
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

  // 圆形按钮
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
}

/// 角样式装饰
class _Corner extends StatelessWidget {
  const _Corner({this.top = false, this.right = false, this.bottom = false, this.left = false});

  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double thick = 4;
    const color = Color(0xFFFFFFFF);

    Widget box(Border border) => SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    if (top && left) {
      return Positioned(
        left: 0,
        top: 0,
        child: box(const Border(
          top: BorderSide(width: thick, color: color),
          left: BorderSide(width: thick, color: color),
        )),
      );
    }
    if (top && right) {
      return Positioned(
        right: 0,
        top: 0,
        child: box(const Border(
          top: BorderSide(width: thick, color: color),
          right: BorderSide(width: thick, color: color),
        )),
      );
    }
    if (bottom && left) {
      return Positioned(
        left: 0,
        bottom: 0,
        child: box(const Border(
          bottom: BorderSide(width: thick, color: color),
          left: BorderSide(width: thick, color: color),
        )),
      );
    }
    return Positioned(
      right: 0,
      bottom: 0,
      child: box(const Border(
        bottom: BorderSide(width: thick, color: color),
        right: BorderSide(width: thick, color: color),
      )),
    );
  }
}