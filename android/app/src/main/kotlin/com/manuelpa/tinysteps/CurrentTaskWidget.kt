package com.manuelpa.tinysteps

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class CurrentTaskWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when last widget is removed
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val views = RemoteViews(context.packageName, R.layout.current_task_widget)
    
    // Get widget data
    val taskName = widgetData.getString("task_name", "No active task")
    val currentStep = widgetData.getString("current_step", "Tap to start a task")
    val currentStepIndex = widgetData.getInt("current_step_index", 0)
    val totalSteps = widgetData.getInt("total_steps", 0)
    val hasActiveTask = widgetData.getBoolean("has_active_task", false)
    
    // Update views
    views.setTextViewText(R.id.task_name, taskName)
    views.setTextViewText(R.id.current_step, currentStep)
    
    if (hasActiveTask && totalSteps > 0) {
        views.setTextViewText(R.id.step_progress, "Step ${currentStepIndex + 1} of $totalSteps")
    } else {
        views.setTextViewText(R.id.step_progress, "")
    }
    
    // Create pending intent to open app
    val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    val pendingIntent = PendingIntent.getActivity(
        context, 
        0, 
        intent, 
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
    
    // Update widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
