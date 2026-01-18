import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:prayer_time/prayer_time.dart';
import 'package:prayer_time_app/utils.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Request permission for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    tz.initializeTimeZones();
  }

  Future<void> schedulePrayerNotifications(double latitude, double longitude, int method) async {
    // Cancel all previous notifications
    await flutterLocalNotificationsPlugin.cancelAll();

    DateTime now = DateTime.now();
    PrayTime prayerTime = PrayTime(method: method);

    
    // We schedule for the next 7 days
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      var times = prayerTime.getPrayerTimes({
        "year": date.year,
        "mon": date.month,
        "mday": date.day,
      }, latitude, longitude, parseTimeZoneOffset(date.timeZoneOffset));

      // Prayer names: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
      List<String> prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Sunset', 'Maghrib', 'Isha'];
      
      for (int j = 0; j < times.length; j++) {
        if (j == 1 || j == 4) continue; // Skip Sunrise and Sunset for adhan notifications
        
        String timeStr = times[j];
        var parsed = _parseTime(timeStr);
        if (parsed == null) continue;

        DateTime scheduledDate = DateTime(date.year, date.month, date.day, parsed['hour']!, parsed['minute']!);
        
        if (scheduledDate.isBefore(DateTime.now())) continue;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          i * 10 + j,
          'Time for ${prayerNames[j]}',
          'It is now time for ${prayerNames[j]} prayer.',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times_channel',
              'Prayer Times',
              channelDescription: 'Notifications for prayer times',
              importance: Importance.max,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('adhan'),
            ),
            iOS: DarwinNotificationDetails(
              sound: 'adhan.aiff',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Map<String, int>? _parseTime(String timeStr) {
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
}
