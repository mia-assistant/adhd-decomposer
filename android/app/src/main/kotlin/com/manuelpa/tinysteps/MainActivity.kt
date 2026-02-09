package com.manuelpa.tinysteps

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.manuelpa.tinysteps/widget_pin"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPinWidget" -> {
                    val widgetClass = call.argument<String>("widgetClass") ?: "CurrentTaskWidget"
                    result.success(requestPinWidget(widgetClass))
                }
                "isWidgetPinSupported" -> {
                    result.success(isWidgetPinSupported())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isWidgetPinSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val appWidgetManager = AppWidgetManager.getInstance(this)
        return appWidgetManager.isRequestPinAppWidgetSupported
    }

    private fun requestPinWidget(widgetClass: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false

        val appWidgetManager = AppWidgetManager.getInstance(this)
        if (!appWidgetManager.isRequestPinAppWidgetSupported) return false

        val targetClass = when (widgetClass) {
            "QuickAddWidget" -> QuickAddWidget::class.java
            else -> CurrentTaskWidget::class.java
        }

        val widgetProvider = ComponentName(this, targetClass)
        return try {
            appWidgetManager.requestPinAppWidget(widgetProvider, null, null)
        } catch (e: Exception) {
            // Some launchers (notably Pixel Launcher on emulators) can crash
            // when placing widgets. Return false so the UI falls back to
            // manual instructions.
            false
        }
    }
}
