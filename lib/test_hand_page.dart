import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class TestHandPage extends StatefulWidget {
  const TestHandPage({Key? key}) : super(key: key);

  @override
  State<TestHandPage> createState() => _TestHandPageState();
}

class _TestHandPageState extends State<TestHandPage> {
  static const eventChannel = EventChannel('com.rongyi/hand_data');
  List<List<double>> _handsData = [];
  String _status = "等待视图创建...";

  Future<void> _startListening() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) setState(() => _status = "❌ 请授予相机权限");
      return;
    }

    if (mounted) setState(() => _status = "相机启动中...");

    try {
      eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event is List) {
          List<List<double>> parsedData = [];
          for (var hand in event) {
            parsedData.add(List<double>.from(hand));
          }
          if (mounted) {
            setState(() {
              _handsData = parsedData;
              _status = "检测到 ${_handsData.length} 只手";
            });
          }
        }
      }, onError: (error) {
        if (mounted) setState(() => _status = "通信错误: $error");
      });
    } catch (e) {
      if (mounted) setState(() => _status = "监听失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("原生手势测试")),
      backgroundColor: Colors.black,
      // 关键点 1：必须用 Stack 才能重叠
      body: Stack(
        fit: StackFit.expand, // 关键点 2：强制所有子组件填满屏幕
        children: [
          // 第一层：原生视频
          AndroidView(
            viewType: 'hand_tracking_view',
            creationParamsCodec: const StandardMessageCodec(),
            hitTestBehavior: PlatformViewHitTestBehavior.transparent, // 防止拦截所有的触摸事件
            onPlatformViewCreated: (id) {
              print("AndroidView 已创建，ID: $id");
              _startListening();
            },
          ),

          // 第二层：骨架绘制
          // 使用 IgnorePointer 让点击事件穿透下去，不影响操作
          IgnorePointer(
            child: CustomPaint(
              painter: HandPainter(_handsData),
              size: Size.infinite, // 撑满父容器
            ),
          ),

          // 第三层：状态文字
          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black54,
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 画笔类
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
      for (int i = 0; i < handPoints.length; i += 2) {
        double rawX = handPoints[i];
        double rawY = handPoints[i + 1];

        // 方案A：竖屏修正 + 镜像翻转
        // 如果骨架位置依然不对，请告诉我，我们再调整这里的公式
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