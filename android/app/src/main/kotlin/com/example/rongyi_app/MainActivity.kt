package com.example.rongyi_app

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    // 1. 定义通信频道，Flutter 端必须用同一个名字监听
    private val CHANNEL = "com.rongyi/hand_data"

    private var handLandmarker: HandLandmarker? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var eventSink: EventChannel.EventSink? = null
    private val backgroundExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // 注册 PlatformView，用于把 CameraX 的 PreviewView 嵌入到 Flutter
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.rongyi/camera_preview",
            object : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
                override fun create(context: android.content.Context?, id: Int, args: Any?): PlatformView {
                    previewView = androidx.camera.view.PreviewView(this@MainActivity)
                    previewView.scaleType = androidx.camera.view.PreviewView.ScaleType.FILL_CENTER
                    return object : PlatformView {
                        override fun getView() = previewView
                        override fun dispose() {}
                    }
                }
            }
        )
        super.configureFlutterEngine(flutterEngine)
        // 🔥🔥🔥 必须要有这一句！告诉系统 hand_tracking_view 是谁 🔥🔥🔥
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("hand_tracking_view", HandTrackingFactory(flutterEngine.dartExecutor.binaryMessenger))

        // 2. 初始化 AI 模型
        setupMediaPipe()

        // 3. 建立通信管道
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    // 当 Flutter 页面开始监听时，启动摄像头
                    if (checkCameraPermission()) {
                        startCamera()
                    } else {
                        Log.e("HandTrack", "❌ 没有相机权限，请在 Flutter 端先请求权限")
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun setupMediaPipe() {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("hand_landmarker.task") // 确保 assets 里有这个文件
            .setDelegate(Delegate.GPU) // 使用 GPU 加速
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setMinHandDetectionConfidence(0.5f)
            .setNumHands(2) // 🔥 核心设定：支持双手识别
            .setRunningMode(RunningMode.LIVE_STREAM)
            .setResultListener { result, _ ->
                sendResultToFlutter(result)
            }
            .build()

        try {
            handLandmarker = HandLandmarker.createFromOptions(this, options)
            Log.d("HandTrack", "✅ 模型加载成功")
        } catch (e: Exception) {
            Log.e("HandTrack", "❌ 模型初始化失败: ${e.message}")
        }
    }

    private lateinit var previewView: androidx.camera.view.PreviewView

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            val cameraProvider = cameraProvider!!

            // 配置图像分析器 (我们不需要原生 Preview，只需要数据流)
            val imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()

            imageAnalysis.setAnalyzer(backgroundExecutor) { imageProxy ->
                detectHand(imageProxy)
            }

            try {
                cameraProvider.unbindAll()
                // 使用前置摄像头
                cameraProvider.bindToLifecycle(
                    this, CameraSelector.DEFAULT_FRONT_CAMERA, imageAnalysis
                )
                Log.d("HandTrack", "📷 相机启动成功")
            } catch (e: Exception) {
                Log.e("HandTrack", "❌ 相机绑定失败", e)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun detectHand(imageProxy: ImageProxy) {
        if (handLandmarker == null) {
            imageProxy.close()
            return
        }

        // 格式转换：CameraX -> Bitmap -> MPImage
        val bitmap = imageProxy.toBitmap()
        val mpImage = BitmapImageBuilder(bitmap).build()

        // 推理 (带上时间戳)
        handLandmarker?.detectAsync(mpImage, System.currentTimeMillis())

        imageProxy.close() // 必须关闭，否则内存泄漏
    }

    private fun sendResultToFlutter(result: HandLandmarkerResult) {
        // 如果没检测到手，不发数据，节省性能
        if (result.landmarks().isEmpty()) return

        // 📦 数据打包结构：List<List<Double>>
        // 外层 List = 几只手
        // 内层 List = 一只手的 42 个坐标数值 (x, y, x, y...)
        val allHandsData = ArrayList<List<Double>>()

        for (handLandmarks in result.landmarks()) {
            val singleHandPoints = ArrayList<Double>()
            for (point in handLandmarks) {
                singleHandPoints.add(point.x().toDouble())
                singleHandPoints.add(point.y().toDouble())
            }
            allHandsData.add(singleHandPoints)
        }

        // 必须切换回主线程发消息
        runOnUiThread {
            eventSink?.success(allHandsData)
        }
    }

    private fun checkCameraPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this, "android.permission.CAMERA"
        ) == PackageManager.PERMISSION_GRANTED
    }
}