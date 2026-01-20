import "package:flutter/material.dart";
import "dart:ui";
import 'package:prayer_time_app/pages/Monthly.dart';
import 'package:prayer_time_app/config.dart';
import 'package:prayer_time_app/pages/About.dart';
import 'package:prayer_time_app/pages/Home.dart';
import 'package:prayer_time_app/pages/Settings.dart';
import 'package:prayer_time_app/theme.dart';
import 'package:prayer_time_app/MainNavigation.dart';
import 'package:prayer_time_app/services/notification_service.dart';
import 'package:prayer_time_app/services/widget_service.dart';
import 'package:prayer_time_app/services/tasbih_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  bool theme = false;
  double? latitude;
  double? longitude;
  int method = 1;

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize notification service
    await NotificationService().init();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = prefs.getBool('theme') ?? false;
    latitude = prefs.getDouble("latitude") ?? null;
    longitude = prefs.getDouble("longitude") ?? null;
    method = prefs.getInt("method") ?? 1;
  
    // Listens for notification flag
    bool notificationsEnabled = prefs.getBool("notifications_enabled") ?? true;
  
    // Schedule notifications if location exists
    // Schedule notifications if location exists
    if (latitude != null && longitude != null) {
      try {
        await WidgetService.updateWidget(latitude, longitude, method);
      } catch (e) {
        print("Error in updateWidget: $e");
      }

      if (notificationsEnabled) {
        try {
          await NotificationService().schedulePrayerNotifications(latitude, longitude, method);
        } catch (e) {
          print("Error scheduling notifications: $e");
        }
      } else {
        await NotificationService().cancelAllNotifications();
      }
    }

    // get the system theme.
    var brightness = PlatformDispatcher.instance.platformBrightness;
    theme = brightness == Brightness.dark;

  } catch (_) {}

  runApp(PrayerTimeApp(theme, latitude, longitude, method));
}

class PrayerTimeApp extends StatefulWidget {
  PrayerTimeApp(this.theme, this.latitude, this.longitude, this.method);
  final bool theme;
  final double? latitude;
  final double? longitude;
  final int method;

  @override
  _PrayerTimeAppState createState() => _PrayerTimeAppState();
}

class _PrayerTimeAppState extends State<PrayerTimeApp> {

  @override
  void initState() {
    currentTheme.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
      ],
      child: MaterialApp(
        title: "Prayers Time",
        home: MainNavigation(latitude: widget.latitude, longitude: widget.longitude, method: widget.method),
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: currentTheme.currentTheme(theme: widget.theme),
        routes: {
          'home': (context) => MainNavigation(latitude: widget.latitude, longitude: widget.longitude, method: widget.method),
          'extend': (context) => Monthly(latitude: widget.latitude!, longitude: widget.longitude!, method: widget.method),
          'settings': (context) => Settings(latitude: widget.latitude, longitude: widget.longitude, method: widget.method),
          'about': (context) => About(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
