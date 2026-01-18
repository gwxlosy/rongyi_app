package com.example.rongyi_app

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executors

class HandTrackingView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int
) : PlatformView {

    private val CHANNEL = "com.rongyi/hand_data"
    private val eventChannel = EventChannel(messenger, CHANNEL)
    private var eventSink: EventChannel.EventSink? = null

    private val frameLayout = FrameLayout(context)
    private val previewView = PreviewView(context)

    private var handLandmarker: HandLandmarker? = null
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private var cameraProvider: ProcessCameraProvider? = null

    init {
        // 强制使用 COMPATIBLE 模式 (底层是 TextureView)
        // 这样 Flutter 的 CustomPaint 才能画在视频上面
        previewView.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        frameLayout.addView(previewView)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                Log.d("HandTrack", "Flutter监听已连接，正在启动相机...")
                setupMediaPipe()
                startCamera()
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun getView(): View {
        return frameLayout
    }

    override fun dispose() {
        backgroundExecutor.shutdown()
        cameraProvider?.unbindAll()
    }

    // 剥离 Context 包装，找到真正的 Activity
    private fun getActivity(context: Context?): Activity? {
        if (context == null) return null
        if (context is Activity) return context
        if (context is ContextWrapper) return getActivity(context.baseContext)
        return null
    }

    private fun setupMediaPipe() {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("hand_landmarker.task")
            .setDelegate(Delegate.GPU) // 如果闪退，可改为 Delegate.CPU
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setMinHandDetectionConfidence(0.5f)
            .setNumHands(2)
            .setRunningMode(RunningMode.LIVE_STREAM)
            .setResultListener { result, _ -> sendResultToFlutter(result) }
            .build()

        try {
            handLandmarker = HandLandmarker.createFromOptions(context, options)
            Log.d("HandTrack", "✅ 模型加载成功")
        } catch (e: Exception) {
            Log.e("HandTrack", "❌ 模型加载失败: ${e.message}")
        }
    }

    private fun startCamera() {
        val activity = getActivity(context)
        if (activity !is LifecycleOwner) {
            Log.e("HandTrack", "❌ 致命错误：无法获取 LifecycleOwner")
            return
        }
        val lifecycleOwner = activity as LifecycleOwner

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder().build()
            preview.setSurfaceProvider(previewView.surfaceProvider)

            val imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .setTargetRotation(android.view.Surface.ROTATION_0)
                .build()

            imageAnalysis.setAnalyzer(backgroundExecutor) { imageProxy ->
                detectHand(imageProxy)
            }

            try {
                cameraProvider?.unbindAll()
                cameraProvider?.bindToLifecycle(
                    lifecycleOwner,
                    CameraSelector.DEFAULT_FRONT_CAMERA,
                    preview,
                    imageAnalysis
                )
                Log.d("HandTrack", "📷 相机已启动")
            } catch (e: Exception) {
                Log.e("HandTrack", "相机绑定失败", e)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun detectHand(imageProxy: ImageProxy) {
        if (handLandmarker == null) {
            imageProxy.close()
            return
        }
        val bitmap = imageProxy.toBitmap()
        val mpImage = BitmapImageBuilder(bitmap).build()
        handLandmarker?.detectAsync(mpImage, System.currentTimeMillis())
        imageProxy.close()
    }

    private fun sendResultToFlutter(result: HandLandmarkerResult) {
        if (result.landmarks().isEmpty()){
            previewView.post {
                eventSink?.success(ArrayList<List<Double>>())
            }
            return
        }
        val allHandsData = ArrayList<List<Double>>()
        for (handLandmarks in result.landmarks()) {
            val singleHandPoints = ArrayList<Double>()
            for (point in handLandmarks) {
                singleHandPoints.add(point.x().toDouble())
                singleHandPoints.add(point.y().toDouble())
                singleHandPoints.add(point.z().toDouble())
            }
            allHandsData.add(singleHandPoints)
        }
        previewView.post {
            eventSink?.success(allHandsData)
        }
    }
}