package com.manuelpa.tinysteps

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
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

                if (hasActiveTask && totalSteps > 0) {
                    // Active task state
                    setViewVisibility(R.id.empty_state, View.GONE)
                    setViewVisibility(R.id.task_name, View.VISIBLE)
                    setViewVisibility(R.id.current_step, View.VISIBLE)
                    setViewVisibility(R.id.accent_bar, View.VISIBLE)
                    setViewVisibility(R.id.progress_text, View.VISIBLE)
                    setViewVisibility(R.id.progress_percent, View.VISIBLE)
                    setViewVisibility(R.id.progress_bar, View.VISIBLE)
                    setViewVisibility(R.id.motivational_text, View.VISIBLE)

                    setTextViewText(R.id.task_name, taskName)
                    setTextViewText(R.id.current_step, currentStep)

                    // Step counter
                    val stepText = "Step ${currentStepIndex + 1}/${totalSteps}"
                    setTextViewText(R.id.progress_text, stepText)

                    // Percentage
                    val progress = ((currentStepIndex + 1).toFloat() / totalSteps * 100).toInt()
                    setTextViewText(R.id.progress_percent, "${progress}%")

                    // Motivational text
                    val remaining = totalSteps - (currentStepIndex + 1)
                    val progressFraction = (currentStepIndex + 1).toFloat() / totalSteps
                    val motivational = when {
                        progressFraction < 0.25f -> "You've got this! 💪"
                        progressFraction < 0.5f -> "Great momentum!"
                        progressFraction < 0.75f -> "Over halfway there!"
                        remaining == 1 -> "Just 1 step left! 🎯"
                        progressFraction < 1.0f -> "Almost done! 🔥"
                        else -> "Finishing up! ✨"
                    }
                    setTextViewText(R.id.motivational_text, motivational)

                    // Progress bar
                    val progressInt = (progressFraction * 100).toInt().coerceIn(0, 100)
                    setProgressBar(R.id.progress_bar, 100, progressInt, false)

                    // Deep link to execute screen
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("tinysteps://execute")
                    )
                    setOnClickPendingIntent(R.id.widget_current_task_container, pendingIntent)
                } else {
                    // Empty state
                    setViewVisibility(R.id.task_name, View.GONE)
                    setViewVisibility(R.id.current_step, View.GONE)
                    setViewVisibility(R.id.accent_bar, View.GONE)
                    setViewVisibility(R.id.progress_text, View.GONE)
                    setViewVisibility(R.id.progress_percent, View.GONE)
                    setViewVisibility(R.id.progress_bar, View.GONE)
                    setViewVisibility(R.id.motivational_text, View.GONE)
                    setViewVisibility(R.id.empty_state, View.VISIBLE)

                    // Deep link to decompose screen
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("tinysteps://decompose")
                    )
                    setOnClickPendingIntent(R.id.widget_current_task_container, pendingIntent)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        // Re-render when widget is resized
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), widgetData)
    }
}
