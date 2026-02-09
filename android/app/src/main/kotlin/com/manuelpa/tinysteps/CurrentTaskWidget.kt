package com.manuelpa.tinysteps

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.*
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.min

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
                    setViewVisibility(R.id.progress_ring, View.VISIBLE)
                    setViewVisibility(R.id.content_area, View.VISIBLE)
                    setViewVisibility(R.id.task_name, View.VISIBLE)
                    setViewVisibility(R.id.current_step, View.VISIBLE)
                    setViewVisibility(R.id.progress_bar, View.VISIBLE)
                    setViewVisibility(R.id.motivational_text, View.VISIBLE)

                    // Task name with target icon
                    setTextViewText(R.id.task_name, "◎ $taskName")
                    setTextViewText(R.id.current_step, currentStep)

                    // Progress calculations
                    val stepNum = currentStepIndex + 1
                    val progressFraction = stepNum.toFloat() / totalSteps

                    // Draw circular progress ring
                    val density = context.resources.displayMetrics.density
                    val sizePx = (64 * density).toInt()
                    val ringBitmap = drawProgressRing(sizePx, progressFraction, stepNum, totalSteps)
                    setImageViewBitmap(R.id.progress_ring, ringBitmap)

                    // Progress bar (short)
                    val progressInt = (progressFraction * 100).toInt().coerceIn(0, 100)
                    setProgressBar(R.id.progress_bar, 100, progressInt, false)

                    // Motivational text
                    val remaining = totalSteps - stepNum
                    val motivational = when {
                        progressFraction < 0.25f -> "You've got this! 💪"
                        progressFraction < 0.5f -> "Great momentum!"
                        progressFraction < 0.75f -> "Over halfway there!"
                        remaining == 1 -> "Just 1 step left! 🎯"
                        progressFraction < 1.0f -> "Almost done! 🔥"
                        else -> "Finishing up! ✨"
                    }
                    setTextViewText(R.id.motivational_text, motivational)

                    // Deep link to execute screen
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("tinysteps://execute")
                    )
                    setOnClickPendingIntent(R.id.widget_current_task_container, pendingIntent)
                } else {
                    // Empty state
                    setViewVisibility(R.id.progress_ring, View.GONE)
                    setViewVisibility(R.id.content_area, View.GONE)
                    setViewVisibility(R.id.task_name, View.GONE)
                    setViewVisibility(R.id.current_step, View.GONE)
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

    /**
     * Draws a circular progress ring with step number centered inside.
     * Matches the iOS widget style: gray track, teal-to-coral gradient arc,
     * bold step number with "of N" below it.
     */
    private fun drawProgressRing(
        sizePx: Int,
        fraction: Float,
        stepNum: Int,
        totalSteps: Int
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val strokeWidth = sizePx * 0.09f
        val radius = (min(sizePx, sizePx) / 2f) - strokeWidth
        val cx = sizePx / 2f
        val cy = sizePx / 2f
        val oval = RectF(cx - radius, cy - radius, cx + radius, cy + radius)

        // Track (light gray)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            color = Color.parseColor("#E8E8E8")
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawArc(oval, 0f, 360f, false, trackPaint)

        // Progress arc with gradient (teal → coral)
        if (fraction > 0f) {
            val sweepAngle = fraction * 360f
            val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                this.strokeWidth = strokeWidth
                strokeCap = Paint.Cap.ROUND
                shader = SweepGradient(
                    cx, cy,
                    intArrayOf(
                        Color.parseColor("#4ECDC4"),  // teal
                        Color.parseColor("#FF6B6B")   // coral
                    ),
                    floatArrayOf(0f, fraction.coerceAtMost(1f))
                )
            }
            // Rotate so arc starts at top (12 o'clock)
            canvas.save()
            canvas.rotate(-90f, cx, cy)
            canvas.drawArc(oval, 0f, sweepAngle, false, progressPaint)
            canvas.restore()
        }

        // Step number (large, bold)
        val numberPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#1A1A1A")
            textAlign = Paint.Align.CENTER
            textSize = sizePx * 0.3f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
        }
        val numberY = cy - (sizePx * 0.02f)
        canvas.drawText("$stepNum", cx, numberY + numberPaint.textSize / 3f, numberPaint)

        // "of N" text (smaller, gray)
        val subPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#999999")
            textAlign = Paint.Align.CENTER
            textSize = sizePx * 0.15f
            typeface = Typeface.create("sans-serif", Typeface.NORMAL)
        }
        canvas.drawText("of $totalSteps", cx, numberY + numberPaint.textSize / 3f + sizePx * 0.18f, subPaint)

        return bitmap
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
