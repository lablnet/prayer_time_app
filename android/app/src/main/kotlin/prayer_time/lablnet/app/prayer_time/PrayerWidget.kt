package prayer_time.lablnet.app.prayer_time

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import prayer_time.lablnet.app.R

class PrayerWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                val nextPrayerName = widgetData.getString("next_prayer_name", "---")
                val nextPrayerTime = widgetData.getString("next_prayer_time", "--:--")
                
                setTextViewText(R.id.next_prayer_name, nextPrayerName)
                setTextViewText(R.id.next_prayer_time, nextPrayerTime)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
