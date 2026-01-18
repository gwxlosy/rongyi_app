// 在 Flutter 端实现 CSV 录制逻辑
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CsvLogger {
  File? _csvFile;
  int _frameCount = 0;
  bool isRecording = false;

  /// 开始录制：创建文件并写入表头
  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String filePath = '${directory.path}/hand_landmarks_$timestamp.csv';
    _csvFile = File(filePath);
    _frameCount = 0;
    isRecording = true;

    // 1. 构建表头 (仿照 python 逻辑: frame, x1, y1, z1 ... x42, y42, z42)
    // 21个点 * 2只手 = 42个点
    List<String> header = ['frame'];
    for (int i = 1; i <= 42; i++) {
      header.add('x$i');
      header.add('y$i');
      header.add('z$i');
    }

    await _csvFile!.writeAsString('${header.join(',')}\n');
    print("开始录制 CSV: $filePath");
  }

  /// 停止录制
  void stopRecording() {
    isRecording = false;
    print("停止录制，文件已保存: ${_csvFile?.path}");
  }

  /// 写入一帧数据
  Future<void> logFrame(List<List<double>> handsData) async {
    if (!isRecording || _csvFile == null) return;
    if (handsData.isEmpty) return; // 如果这一帧没手，通常不记录 (参考python逻辑)

    _frameCount++;

    // 准备一行数据，初始化为 "###"
    // Python逻辑: frame + (42个点 * 3个坐标)
    List<String> rowData = [_frameCount.toString()];
    List<String> placeholders = List.filled(42 * 3, "###");

    // 填充实际检测到的数据
    for (int handIdx = 0; handIdx < handsData.length; handIdx++) {
      if (handIdx >= 2) break; // 最多记录两只手

      List<double> hand = handsData[handIdx];
      // 现在的 hand 列表结构是 [x, y, z, x, y, z, ...]

      for (int lmIdx = 0; lmIdx < 21; lmIdx++) {
        int baseIdx = lmIdx * 3;
        if (baseIdx + 2 < hand.length) {
          // 计算在整行数据中的位置
          // 第0只手: 0-62, 第1只手: 63-125
          int globalIdx = (handIdx * 63) + (lmIdx * 3);

          if (globalIdx + 2 < placeholders.length) {
            placeholders[globalIdx] = hand[baseIdx].toStringAsFixed(6);     // x
            placeholders[globalIdx + 1] = hand[baseIdx + 1].toStringAsFixed(6); // y
            placeholders[globalIdx + 2] = hand[baseIdx + 2].toStringAsFixed(6); // z
          }
        }
      }
    }

    rowData.addAll(placeholders);

    // 写入文件
    await _csvFile!.writeAsString('${rowData.join(',')}\n', mode: FileMode.append);
  }
}