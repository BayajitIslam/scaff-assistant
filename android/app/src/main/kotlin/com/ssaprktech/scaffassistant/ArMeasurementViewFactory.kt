// android/app/src/main/kotlin/com/ssaprktech/scaffassistant/ArMeasurementViewFactory.kt

package com.ssaprktech.scaffassistant

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ArMeasurementViewFactory(
    private val activity: Activity,
    private val channel: MethodChannel
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var currentView: ArMeasurementView? = null
        private set

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        currentView = ArMeasurementView(context, activity, channel)
        return currentView!!
    }
}