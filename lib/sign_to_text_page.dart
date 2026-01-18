import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

// 引入相关类
import 'csv_logger.dart';
import 'sign_interpreter.dart'; // 引入刚才写的推理类

class SignToTextPage extends StatefulWidget {
  const SignToTextPage({super.key});
  @override
  State<SignToTextPage> createState() => _SignToTextPageState();
}

class _SignToTextPageState extends State<SignToTextPage> {
  // 通信管道
  static const eventChannel = EventChannel('com.rongyi/hand_data');

  // --- 实时翻译新状态变量 ---
  final SignInterpreter _interpreter = SignInterpreter();
  Timer? _predictionTimer; // 高频预测定时器
  Timer? _handPresenceTimer; // 手部存在检测计时器

  // [新增] 1. 句子缓冲区：暂存连续识别到的词
  List<String> _sentenceBuffer = [];

  // [新增] 2. 上一帧是否有手：用于检测“手刚刚离开”的瞬间
  bool _wasHandPresent = false;

  // [新增] 3. 上一个识别词：用于防抖（避免重复添加同一个词）
  String _lastAddedWord = "";

  // [新增] 4. 记录手进入画面的时刻
  DateTime? _handEntryTime;

  List<List<double>> _slidingWindow = []; // 滑动窗口数据
  static const int _windowSize = 90; // 窗口大小 (帧数, e.g., 90 frames ≈ 3s)

  List<String> _predictionHistory = []; // 预测历史，用于稳定结果
  static const int _stabilityThreshold = 3; // 连续多少次相同预测才算稳定

  String _stableResult = ""; // 最终显示的稳定结果
  bool _isHandPresent = false; // 当前帧是否有手

  // --- 录制相关 ---
  final CsvLogger _csvLogger = CsvLogger();
  bool _isRecording = false;

  // --- UI控制相关 ---
  List<List<double>> _handsData = []; // 用于实时画骨架
  bool _expanded = false;
  bool _useFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _interpreter.init().then((_) {
      // 模型加载后，启动高频预测定时器
      _predictionTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        _runRealtimePrediction();
      });
    });
  }

  @override
  void dispose() {
    _predictionTimer?.cancel();
    _handPresenceTimer?.cancel();
    _interpreter.release();
    super.dispose();
  }

  Future<void> _startListening() async {
    await Permission.camera.request();

    eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is List) {
        List<List<double>> parsedData = [];
        for (var hand in event) {
          parsedData.add(List<double>.from(hand));
        }

        // 1. 判断当前帧是否有手
        bool currentHandPresent = parsedData.isNotEmpty;
        _isHandPresent = currentHandPresent;

        // [新增] 检测“手刚刚进入”的瞬间 (上升沿) -> 记录时间
        if (currentHandPresent && !_wasHandPresent) {
          _handEntryTime = DateTime.now(); // 开始计时：手进来了！
        }

        // 2. [核心修改] 检测“手刚刚离开”的瞬间 (下降沿触发)
        if (!currentHandPresent && _wasHandPresent) {
          // 手离开了 -> 结算句子
          if (_sentenceBuffer.isNotEmpty) {
            String finalSentence = _sentenceBuffer.join(""); // 拼接："你"+"好" -> "你好"
            if (mounted) {
              setState(() {
                _stableResult = finalSentence; // 显示最终句子
              });
            }
            print("✅ 句子生成: $finalSentence");
          }

          // 重置状态，准备下一句话
          _sentenceBuffer.clear();
          _lastAddedWord = "";
          _slidingWindow.clear(); // 清空旧数据的缓存

          // 手离开了，把计时器也重置一下（可选，但推荐）
          _handEntryTime = null;
        }

        // 3. 更新上一帧状态
        _wasHandPresent = currentHandPresent;

        // 4. 数据处理 (仅当有手时进行)
        if (currentHandPresent) {
          List<double> flattenedFrame = [];
          for (var hand in parsedData) {
            flattenedFrame.addAll(hand);
          }

          if (_isRecording) {
            _csvLogger.logFrame(parsedData);
          } else {
            _slidingWindow.add(flattenedFrame);
            if (_slidingWindow.length > _windowSize) {
              _slidingWindow.removeAt(0);
            }
          }
        }

        // 5. 更新 UI (画骨架)
        if (mounted) {
          setState(() {
            _handsData = parsedData;
          });
        }
      }
    }, onError: (error) {
      print("通信错误: $error");
    });
  }

  // 实时预测循环
  void _runRealtimePrediction() {
    // 基础检查
    if (_isRecording || !_isHandPresent || _slidingWindow.isEmpty) return;

    // [新增] 冷却时间检查 (例如 1200毫秒)
    // 如果手进来还没满 1.2秒，就不识别，防止误触
    if (_handEntryTime != null &&
        DateTime.now().difference(_handEntryTime!).inMilliseconds < 1200) {
      print("⏳ 准备中..."); // 调试用
      return;
    }

    // 通过检查后，才真正去预测
    String rawPrediction = _interpreter.predict(_slidingWindow);
    _updatePrediction(rawPrediction);
  }

  // 预测稳定器 + 句子累积
  void _updatePrediction(String newPrediction) {
    // 忽略空字符
    if (newPrediction.isEmpty || newPrediction == "<blank>") return;

    _predictionHistory.add(newPrediction);
    if (_predictionHistory.length > _stabilityThreshold) {
      _predictionHistory.removeAt(0);
    }

    // 检查稳定性 (连续 N 次相同)
    if (_predictionHistory.length == _stabilityThreshold) {
      final first = _predictionHistory[0];
      final allSame = _predictionHistory.every((e) => e == first);

      // 如果结果稳定，且是一个新词 (防抖)
      if (allSame && first != _lastAddedWord) {
        // [核心修改] 将词加入缓冲区，而不是直接覆盖结果
        _sentenceBuffer.add(first);
        _lastAddedWord = first; // 记录，防止 "你你你" 重复添加

        print("📥 缓冲添加: $first -> 当前缓冲: ${_sentenceBuffer.join("")}");

        // 如果您希望在打手势的过程中就能看到字一个个蹦出来（而不是等手放下才显示），
        // 可以把下面这行代码的注释解开：
        // if (mounted) setState(() { _stableResult = _sentenceBuffer.join(""); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE6D7), Color(0xFFFFF3EC)],
            begin: Alignment.topRight, end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _expanded ? _buildExpandedView(context) : _buildSplitView(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 分屏视图
  Widget _buildSplitView(BuildContext context) {
    return Column(
      key: const ValueKey('split'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        // 上半区：结果显示窗口
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.2),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.translate, size: 42, color: const Color(0xFFFF7A59).withOpacity(_isHandPresent ? 1.0 : 0.3)),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _stableResult.isEmpty ? "正在识别中..." : _stableResult,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 工具栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 84,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolItem(
                  context,
                  icon: Icons.fiber_manual_record,
                  label: _isRecording ? '停止' : '录制',
                  onTap: () {
                    setState(() => _isRecording = !_isRecording);
                    if (_isRecording) {
                      _csvLogger.startRecording();
                      _toast("开始录制训练数据");
                    } else {
                      _csvLogger.stopRecording();
                      _toast("录制已保存");
                    }
                  },
                ),
                _toolItem(context, icon: Icons.cameraswitch, label: '反转', onTap: () => setState(() => _useFrontCamera = !_useFrontCamera)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 下半区：检测预览
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _detectionView(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 全屏视图
  Widget _buildExpandedView(BuildContext context) {
    return Padding(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Positioned.fill(child: _detectionView()),
          Positioned(
            right: 20, top: 40,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.fullscreen_exit, color: Colors.black),
              onPressed: () => setState(() => _expanded = false),
            ),
          ),
        ],
      ),
    );
  }

  // 检测区 Widget
  Widget _detectionView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: AndroidView(
              viewType: 'hand_tracking_view',
              creationParamsCodec: const StandardMessageCodec(),
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              onPlatformViewCreated: (id) {
                _startListening();
              },
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: HandPainter(_handsData),
              size: Size.infinite,
            ),
          ),
          if (_handsData.isEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 120, color: Colors.white54),
                    const SizedBox(height: 20),
                    const Text(
                      '请将手臂置于检测框内',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_handsData.isEmpty)
            IgnorePointer(
              child: CustomPaint(
                painter: FramePainter(),
                size: Size.infinite,
              ),
            ),
        ],
      ),
    );
  }

  // 辅助方法：Toast
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  // 辅助方法：工具栏按钮
  Widget _toolItem(BuildContext context, {required IconData icon, required String label, VoidCallback? onTap}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8E8)),
              color: Colors.white,
            ),
            child: Icon(icon, color: const Color(0xFFFF7A59)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// 引入画笔类 (沿用你在测试页中跑通的逻辑)
class HandPainter extends CustomPainter {
  final List<List<double>> hands;
  HandPainter(this.hands);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()..color = Colors.red..strokeWidth = 5..strokeCap = StrokeCap.round;
    final linePaint = Paint()..color = Colors.green..strokeWidth = 2;

    final connections = [
      [0,1],[1,2],[2,3],[3,4],[0,5],[5,6],[6,7],[7,8],[0,9],[9,10],[10,11],[11,12],
      [0,13],[13,14],[14,15],[15,16],[0,17],[17,18],[18,19],[19,20]
    ];

    for (var handPoints in hands) {
      List<Offset> offsets = [];
      for (int i = 0; i < handPoints.length; i += 3) {
        double rawX = handPoints[i];
        double rawY = handPoints[i + 1];

        // 方案A：竖屏修正 + 镜像翻转 (与测试页保持一致)
        double x = 1.0 - rawY;
        double y = 1.0 - rawX;

        offsets.add(Offset(x * size.width, y * size.height));
      }

      for (var pair in connections) {
        if (pair[0] < offsets.length && pair[1] < offsets.length) {
          canvas.drawLine(offsets[pair[0]], offsets[pair[1]], linePaint);
        }
      }
      for (var offset in offsets) {
        canvas.drawCircle(offset, 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 绘制四个角的边框
class FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;
    const padding = 20.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(padding, padding + cornerLength)
        ..lineTo(padding, padding)
        ..lineTo(padding + cornerLength, padding),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding, padding + cornerLength)
        ..lineTo(size.width - padding, padding)
        ..lineTo(size.width - padding - cornerLength, padding),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(padding, size.height - padding - cornerLength)
        ..lineTo(padding, size.height - padding)
        ..lineTo(padding + cornerLength, size.height - padding),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding, size.height - padding - cornerLength)
        ..lineTo(size.width - padding, size.height - padding)
        ..lineTo(size.width - padding - cornerLength, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}