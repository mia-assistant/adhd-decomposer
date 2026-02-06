package com.miadevelops.adhd_decomposer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CurrentTaskWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_current_task).apply {
                // Get widget data
                val taskName = widgetData.getString("task_name", "No active task") ?: "No active task"
                val currentStep = widgetData.getString("current_step", "Tap to start a task") ?: "Tap to start a task"
                val currentStepIndex = widgetData.getInt("current_step_index", 0)
                val totalSteps = widgetData.getInt("total_steps", 0)
                val hasActiveTask = widgetData.getBoolean("has_active_task", false)
                
                // Set text values
                setTextViewText(R.id.task_name, taskName)
                setTextViewText(R.id.current_step, currentStep)
                
                // Set progress text
                val progressText = if (hasActiveTask && totalSteps > 0) {
                    "Step ${currentStepIndex + 1} of $totalSteps"
                } else {
                    ""
                }
                setTextViewText(R.id.progress_text, progressText)
                
                // Create intent to open execute screen (or home if no task)
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("tinysteps://execute")
                )
                setOnClickPendingIntent(R.id.widget_current_task_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
