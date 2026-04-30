import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:prayer_time_app/utils.dart';
import 'package:prayer_time_app/models/tasbih_item.dart';

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

    // Request exact alarms permission for Android 14+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      print('Could not set local timezone: $e');
    }
  }

  Future<void> schedulePrayerNotifications(double latitude, double longitude, int method) async {
    // Cancel all previous prayer notifications (IDs 0 to 66)
    for (int i = 0; i <= 70; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

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

  Future<void> scheduleTasbihReminders(List<TasbihItem> tasbihs) async {
    // Cancel old tasbih notifications (we use IDs 1000 to 1100 for simplicity)
    for (int i = 1000; i < 1100; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    int baseId = 1000;
    for (var tasbih in tasbihs) {
      if (!tasbih.reminderEnabled || tasbih.targetType == TargetType.none || tasbih.goal <= 0) {
        continue;
      }

      // Check if goal met
      if (tasbih.counter >= tasbih.goal) {
        // Goal met, no reminder needed today. But we should schedule for tomorrow if it's daily.
        // For simplicity, we just schedule it every day at 8 PM, and when they open the app/increment, this function runs again and cancels if goal is met.
      }

      DateTime now = DateTime.now();
      DateTime scheduledDate = DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM
      
      if (now.isAfter(scheduledDate) || tasbih.counter >= tasbih.goal) {
        // Schedule for tomorrow if missed today or if goal already met today
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        baseId++,
        'Tasbih Reminder: ${tasbih.name}',
        "Don't forget your daily tasbih target of ${tasbih.goal}!",
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasbih_channel',
            'Tasbih Reminders',
            channelDescription: 'Notifications for daily tasbih goals',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      );
    }
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
