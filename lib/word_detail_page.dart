import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'database_helper.dart';

/// 词汇详情页
/// 显示词汇的完整信息和演示视频
class WordDetailPage extends StatefulWidget {
  final SignWord word;

  const WordDetailPage({
    super.key,
    required this.word,
  });

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
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
      _videoController = VideoPlayerController.asset(widget.word.videoPath);

      await _videoController!.initialize();

      if (!mounted) return;

      // 监听视频播放状态
      _videoController!.addListener(_videoListener);

      setState(() {
        _isVideoInitialized = true;
        _isLoading = false;
      });

      debugPrint('✅ 视频初始化成功: ${widget.word.videoPath}');
    } catch (e) {
      debugPrint('❌ 视频初始化失败: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '视频暂时无法播放';
      });
    }
  }

  /// 监听视频播放状态
  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }

    // 视频播放完成后自动循环
    if (_videoController!.value.position >= _videoController!.value.duration) {
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  /// 切换播放/暂停
  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;

    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
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
                          child: Text(
                            widget.word.word,
                            style: const TextStyle(
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
                      // 视频播放区域
                      _videoCard(),

                      const SizedBox(height: 20),

                      // 词汇信息卡片
                      _infoCard(),

                      const SizedBox(height: 20),

                      // 操作提示
                      _tipsCard(),

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

  /// 视频播放卡片
  Widget _videoCard() {
    return Container(
      height: 280,
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
            color: Colors.black,
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
                // 视频播放器
                if (_isVideoInitialized && _videoController != null)
                  Positioned.fill(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                else if (_isLoading)
                // 加载中
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFFF7A59),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '正在加载视频...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                else if (_errorMessage.isNotEmpty)
                  // 错误状态
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam_off,
                            size: 60,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                // 播放/暂停按钮
                if (_isVideoInitialized)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _togglePlayPause,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 重播按钮
                if (_isVideoInitialized)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _smallIconButton(
                      icon: Icons.replay_rounded,
                      onTap: () {
                        _videoController!.seekTo(Duration.zero);
                        _videoController!.play();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 信息卡片
  Widget _infoCard() {
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
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A59).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.word.category,
                    style: const TextStyle(
                      color: Color(0xFFFF7A59),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 词汇名称
                Text(
                  widget.word.word,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // 动作描述标题
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Color(0xFFFF7A59),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '手语动作描述',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 动作描述内容
                Text(
                  widget.word.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 提示卡片
  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A59).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF7A59).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFFF7A59),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '点击视频可以暂停/播放，视频会自动循环播放',
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 小图标按钮
  Widget _smallIconButton({required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  /// 圆形返回按钮
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