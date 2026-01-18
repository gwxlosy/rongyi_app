import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

class SignInterpreter {
  OrtSession? _session;

  // 词汇表
  final Map<int, String> _id2gloss = {
    0: "<blank>",
    1: "谢谢",
    2: "你",
    3: "你好",
    4: "再见",
    5: "帮助",
    6: "请",
    7: "对不起",
    8: "没关系",
    9: "我",
    10: "他",
    11: "是",
    12: "不",
    13: "好",
    14: "吗",
  };

  Future<void> init() async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    const assetFileName = 'assets/models/sign_model.onnx';
    try {
      final rawAssetFile = await rootBundle.load(assetFileName);
      final bytes = rawAssetFile.buffer.asUint8List();
      _session = OrtSession.fromBuffer(bytes, sessionOptions);
      print("✅ ONNX 模型加载成功");
    } catch (e) {
      print("❌ 模型加载失败: $e");
    }
  }

  void release() {
    _session?.release();
    OrtEnv.instance.release();
  }

  String predict(List<List<double>> capturedData) {
    if (_session == null) return "模型未加载";
    if (capturedData.isEmpty) return "";

    int timeSteps = capturedData.length;
    const int featureDim = 127;

    final Float32List inputFloats = Float32List(1 * timeSteps * featureDim);

    for (int t = 0; t < timeSteps; t++) {
      List<double> frameData = capturedData[t];
      int offset = t * featureDim;

      // 恢复帧编号为整数 (1.0, 2.0, 3.0...)
      // 训练数据中的 frame 是计数器，不是归一化的 0-1
      inputFloats[offset] = (t + 1).toDouble();

      // 填充坐标数据
      if (frameData.isNotEmpty) {
        // 确保不越界 (21点 * 2手 * 3坐标 = 126)
        int copyLen = min(frameData.length, 126);

        // 遍历每一个点 (每次取3个值: x, y, z)
        for (int i = 0; i < copyLen; i += 3) {
          // 获取原始坐标
          double rawX = frameData[i];
          double rawY = frameData[i+1];
          double rawZ = frameData[i+2];

          // 坐标系变换
          // 手机竖屏前置摄像头的原始数据通常是旋转的，必须转回标准坐标系模型才能识别
          // 这必须与 HandPainter 中的逻辑对应：x = 1.0 - rawY
          double modelX = 1.0 - rawY;
          double modelY = 1.0 - rawX;
          double modelZ = rawZ; // Z 轴通常不需要旋转

          // 处理 NaN (数据清洗)
          if (modelX.isNaN) modelX = 0.0;
          if (modelY.isNaN) modelY = 0.0;
          if (modelZ.isNaN) modelZ = 0.0;

          // 填入 Tensor
          inputFloats[offset + 1 + i] = modelX;     // x
          inputFloats[offset + 1 + i + 1] = modelY; // y
          inputFloats[offset + 1 + i + 2] = modelZ; // z
        }
      }
    }

    // 创建 Tensor
    final shape = [1, timeSteps, featureDim];
    final inputOrt = OrtValueTensor.createTensorWithDataList(inputFloats, shape);
    final inputs = {'x': inputOrt};
    final runOptions = OrtRunOptions();
    List<OrtValue?>? outputs;

    try {
      outputs = _session!.run(runOptions, inputs);
    } catch (e) {
      print("❌ 推理错误: $e");
      inputOrt.release();
      runOptions.release();
      return "推理出错";
    }

    inputOrt.release();
    runOptions.release();

    if (outputs == null || outputs.isEmpty) return "";

    // 解析嵌套列表输出
    final outputTensor = outputs[0];
    final outputValue = outputTensor?.value;

    if (outputValue is! List || outputValue.isEmpty) {
      return "";
    }

    final List<dynamic> timeList = outputValue[0];
    if (timeList.isEmpty) return "";

    int outTimeSteps = timeList.length;
    int numClasses = (timeList[0] as List).length;

    List<int> predIds = _greedyDecode(timeList, outTimeSteps, numClasses);

    outputTensor?.release();

    List<String> words = [];
    for (int id in predIds) {
      if (_id2gloss.containsKey(id)) {
        words.add(_id2gloss[id]!);
      }
    }

    String result = words.join("");
    print("🔮 最终识别结果: '$result'");
    return result;
  }

  List<int> _greedyDecode(List<dynamic> timeList, int timeSteps, int numClasses) {
    List<int> bestPath = [];

    for (int t = 0; t < timeSteps; t++) {
      List<dynamic> probList = timeList[t];
      int maxId = 0;
      double maxVal = -double.infinity;

      for (int c = 0; c < numClasses; c++) {
        double val = (probList[c] as num).toDouble();
        if (val > maxVal) {
          maxVal = val;
          maxId = c;
        }
      }
      bestPath.add(maxId);
    }

    List<int> finalPath = [];
    int lastId = -1;
    for (int id in bestPath) {
      if (id != lastId) {
        if (id != 0) finalPath.add(id);
        lastId = id;
      }
    }
    return finalPath;
  }
}