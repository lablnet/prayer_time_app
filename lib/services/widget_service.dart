import 'package:home_widget/home_widget.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:prayer_time_app/utils.dart';

class WidgetService {
  static const String _groupId = 'group.prayer_time_app';
  static const String _iosWidget = 'PrayerWidget';
  static const String _androidWidget = 'prayer_time.PrayerWidget';

  static Future<void> updateWidget(double latitude, double longitude, int method) async {
    DateTime now = DateTime.now();
    PrayTime prayerTime = PrayTime(method: method);

    var times = prayerTime.getPrayerTimes({
      "year": now.year,
      "mon": now.month,
      "mday": now.day,
    }, latitude, longitude, parseTimeZoneOffset(now.timeZoneOffset));

    // Ensure group ID is set
    await HomeWidget.setAppGroupId(_groupId);

    String nextPrayerName = _getPrayerName(0);
    String nextPrayerTime = times[0];
    
    int nextPrayerIndex = -1;
    for (int i = 0; i < times.length; i++) {
      if (i == 1 || i == 4) continue; // Skip Sunrise/Sunset
      
      var parsed = _parseTime(times[i]);
      if (parsed == null) continue;

      DateTime pTime = DateTime(now.year, now.month, now.day, parsed['hour']!, parsed['minute']!);
      if (pTime.isAfter(now)) {
        nextPrayerIndex = i;
        nextPrayerName = _getPrayerName(i);
        nextPrayerTime = times[i];
        break;
      }
    }

    if (nextPrayerIndex == -1) {
      // Calculate for tomorrow
      DateTime tomorrow = now.add(const Duration(days: 1));
      var tomorrowTimes = prayerTime.getPrayerTimes({
        "year": tomorrow.year,
        "mon": tomorrow.month,
        "mday": tomorrow.day,
      }, latitude, longitude, parseTimeZoneOffset(tomorrow.timeZoneOffset));

      nextPrayerName = _getPrayerName(0);
      nextPrayerTime = tomorrowTimes[0];
    }

    try {
      await HomeWidget.saveWidgetData('next_prayer_name', nextPrayerName);
      await HomeWidget.saveWidgetData('next_prayer_time', nextPrayerTime);
      await HomeWidget.updateWidget(
        iOSName: _iosWidget,
        androidName: _androidWidget,
      );
    } catch (e) {
      print("Error updating widget: $e");
    }
  }

  static Map<String, int>? _parseTime(String timeStr) {
    timeStr = timeStr.trim().toUpperCase();
    bool isPM = timeStr.contains('PM');
    bool isAM = timeStr.contains('AM');
    
    timeStr = timeStr.replaceAll('AM', '').replaceAll('PM', '').trim();
    
    List<String> parts = timeStr.split(':');
    if (parts.length < 2) return null;
    
    int? hour = int.tryParse(parts[0].trim());
    int? minute = int.tryParse(parts[1].trim());
    
    if (hour == null || minute == null) return null;
    
    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }
    
    return {'hour': hour, 'minute': minute};
  }

  static String _getPrayerName(int index) {
      switch (index) {
        case 0: return 'Fajr';
        case 1: return 'Sunrise';
        case 2: return 'Dhuhr';
        case 3: return 'Asr';
        case 4: return 'Sunset';
        case 5: return 'Maghrib';
        case 6: return 'Isha';
        default: return '';
      }
    }
}
