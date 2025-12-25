// android/app/src/main/kotlin/com/ssaprktech/scaffassistant/MainActivity.kt

package com.ssaprktech.scaffassistant

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ssaprktech.scaffassistant/ar_measurement"
    private var arViewFactory: ArMeasurementViewFactory? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Create factory with channel reference
        arViewFactory = ArMeasurementViewFactory(this, channel)

        // Register platform view
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "ar_measurement_view_android",
            arViewFactory!!
        )

        // Handle method calls
        channel.setMethodCallHandler { call, result ->
            val arView = arViewFactory?.currentView

            when (call.method) {
                "isSupported" -> {
                    result.success(ArMeasurementView.isARCoreSupported(this))
                }
                "initialize" -> {
                    val success = arView?.initialize() ?: false
                    result.success(success)
                }
                "addPoint" -> {
                    arView?.addPoint()
                    result.success(null)
                }
                "undo" -> {
                    arView?.undo()
                    result.success(null)
                }
                "clear" -> {
                    arView?.clear()
                    result.success(null)
                }
                "snapshot" -> {
                    val bytes = arView?.takeSnapshot()
                    result.success(bytes)
                }
                "dispose" -> {
                    arView?.dispose()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}