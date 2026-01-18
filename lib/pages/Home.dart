import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils.dart';
import 'Monthly.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  static const Map methodsMap = {
    0: 'Jafari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm al-Qura, Makkah',
    5: 'Egyptian General Authority of Survey',
    6: "Custom",
    7: 'Institute of Geophysics, University of Tehran'
  };
  final double? latitude;
  final double? longitude;
  final int? method;
  Home({this.latitude, this.longitude, this.method});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _latitude = widget.latitude;
    _longitude = widget.longitude;
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// Parses time strings like "5:30 AM", "17:30", or "5:30 PM" into hour/minute
  Map<String, int>? _parseTime(String timeStr) {
    timeStr = timeStr.trim().toUpperCase();
    bool isPM = timeStr.contains('PM');
    bool isAM = timeStr.contains('AM');
    
    // Remove AM/PM suffix
    timeStr = timeStr.replaceAll('AM', '').replaceAll('PM', '').trim();
    
    List<String> parts = timeStr.split(':');
    if (parts.length < 2) return null;
    
    int? hour = int.tryParse(parts[0].trim());
    int? minute = int.tryParse(parts[1].trim());
    
    if (hour == null || minute == null) return null;
    
    // Convert 12-hour to 24-hour
    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }
    
    return {'hour': hour, 'minute': minute};
  }

  Widget buildCard(BuildContext context) {
    DateTime now = DateTime.now();
    HijriCalendar nowHijri = HijriCalendar.now();
    final DateFormat formatter = DateFormat('MMMM dd, yyyy');
    final String formatted = formatter.format(now);
    parseTimeZoneOffset(now.timeZoneOffset);
    PrayTime prayerTime = PrayTime(method: widget.method!);

    var times = prayerTime.getPrayerTimes({
      "year": now.year,
      "mon": now.month,
      "mday": now.day,
    }, _latitude!, _longitude!,
        parseTimeZoneOffset(now.timeZoneOffset));
    
    // Ramadan Mode: Sehri (Fajr) and Iftar (Maghrib)
    // In our list: 0: Fajr, 1: Sunrise, 2: Dhuhr, 3: Asr, 4: Sunset, 5: Maghrib, 6: Isha
    String sehriTime = times[0];
    String iftarTime = times[5];
    bool isRamadan = nowHijri.hMonth == 9;

    // Filter times for display (Remove Sunset)
    List<String> displayTimes = List.from(times);
    displayTimes.removeAt(4); // Remove Sunset
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find next prayer
    int nextPrayerIndex = -1;
    String nextPrayerName = "";
    String nextPrayerTime = "";
    Duration timeRemaining = Duration.zero;

    for (int i = 0; i < displayTimes.length; i++) {
      var parsed = _parseTime(displayTimes[i]);
      if (parsed == null) continue;
      
      int hour = parsed['hour']!;
      int minute = parsed['minute']!;

      DateTime pTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If this prayer is in the future, it's the next one
      if (pTime.isAfter(now)) {
        nextPrayerIndex = i;
        nextPrayerName = getPrayerName(i);
        nextPrayerTime = displayTimes[i];
        timeRemaining = pTime.difference(now);
        break;
      }
    }
    
    // If no more prayers today, next is tomorrow's Fajr
    if (nextPrayerIndex == -1) {
       nextPrayerName = "Sehar Time/Fajr";
       nextPrayerTime = displayTimes[0];
       nextPrayerIndex = 0;
       
       // Calculate time until tomorrow's Fajr
       var parsed = _parseTime(displayTimes[0]);
       if (parsed != null) {
         DateTime tomorrowFajr = DateTime(now.year, now.month, now.day + 1, parsed['hour']!, parsed['minute']!);
         timeRemaining = tomorrowFajr.difference(now);
       }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0f0f1e),
                  const Color(0xFF1a1a2e),
                ]
              : [
                  const Color(0xFFf5f7fa),
                  const Color(0xFFc3cfe2),
                ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Header Card with Gradient
          _buildHeaderCard(context, nowHijri, formatted, isDark),
          const SizedBox(height: 16),

          // Upcoming Prayer Card
          _buildUpcomingPrayerCard(context, nextPrayerName, nextPrayerTime, timeRemaining, isDark),
          const SizedBox(height: 16),

          // Ramadan Mode Card
          if (isRamadan) _buildRamadanCard(context, sehriTime, iftarTime, isDark),
          if (isRamadan) const SizedBox(height: 16),
          
          // Prayer Times Grid
          ...List.generate(displayTimes.length, (index) {
            return _buildPrayerTimeCard(
              context,
              getPrayerName(index),
              displayTimes[index],
              index,
              isDark,
              isNext: index == nextPrayerIndex,
            );
          }),
          
          const SizedBox(height: 24),
          
          // Extend View Button
          _buildExtendViewButton(context, isDark),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRamadanCard(BuildContext context, String sehri, String iftar, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf093fb).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRamadanInfo("Sehri", sehri, Icons.wb_twilight),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildRamadanInfo("Iftar", iftar, Icons.wb_sunny_outlined),
        ],
      ),
    );
  }

  Widget _buildRamadanInfo(String title, String time, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUpcomingPrayerCard(BuildContext context, String name, String time, Duration remaining, bool isDark) {
    String formattedRemaining = "${remaining.inHours}h ${remaining.inMinutes % 60}m";
    if (remaining == Duration.zero) formattedRemaining = "Soon";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFFe94560).withOpacity(0.3) : const Color(0xFF667eea).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upcoming: $name", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Time Left", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(formattedRemaining, style: TextStyle(color: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildHeaderCard(BuildContext context, HijriCalendar hijri, String gregorian, bool isDark) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF5f72bd),
                          const Color(0xFF9921e8),
                        ]
                      : [
                          const Color(0xFF5f72bd),
                          const Color(0xFF9921e8),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5f72bd).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      "Today's Prayer Times",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        Home.methodsMap[widget.method] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Hijri Date
                    Text(
                      hijri.toFormat("MMMM dd, yyyy"),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Gregorian Date
                    Text(
                      gregorian,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPrayerTimeCard(BuildContext context, String prayerName, String time, int index, bool isDark, {bool isNext = false}) {
    final colors = [
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink to Red
      [const Color(0xFFffa751), const Color(0xFFffe259)], // Orange to Yellow
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue to Cyan
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink to Yellow
      [const Color(0xFF30cfd0), const Color(0xFF330867)], // Cyan to Purple
      [const Color(0xFFa8edea), const Color(0xFF6a11cb)], // Light Blue to Purple
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink to Red (Reuse)
    ];
    
    final darkColors = [
      [const Color(0xFFeb3349), const Color(0xFFf45c43)], // Deep Red
      [const Color(0xFFf7971e), const Color(0xFFffd200)], // Deep Orange
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)], // Deep Blue
      [const Color(0xFFcc2b5e), const Color(0xFF753a88)], // Deep Pink
      [const Color(0xFF11998e), const Color(0xFF38ef7d)], // Deep Teal
      [const Color(0xFF4776e6), const Color(0xFF8e54e9)], // Deep Blue Purple
      [const Color(0xFFeb3349), const Color(0xFFf45c43)], // Deep Red (Reuse)
    ];
    
    final gradientColors = isDark ? darkColors[index % darkColors.length] : colors[index % colors.length];
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(20),
                border: isNext ? Border.all(color: Colors.white, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: isNext ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getPrayerIcon(index),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              prayerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  IconData _getPrayerIcon(int index) {
    switch (index) {
      case 0: return Icons.wb_twilight; // Fajr
      case 1: return Icons.wb_sunny; // Sunrise
      case 2: return Icons.wb_sunny_outlined; // Dhuhr
      case 3: return Icons.light_mode; // Asr
      case 4: return Icons.wb_twilight_outlined; // Maghrib
      case 5: return Icons.nightlight; // Isha
      default: return Icons.access_time;
    }
  }
  
  Widget _buildExtendViewButton(BuildContext context, bool isDark) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFFe94560),
                        const Color(0xFF00adb5),
                      ]
                    : [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? const Color(0xFFe94560) : const Color(0xFF667eea))
                      .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Monthly(
                        latitude: _latitude!,
                        longitude: _longitude!,
                        method: widget.method!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "View Monthly Calendar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget? body = null;
    if (_latitude == null) {
      body = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                  ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Location Required",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "We need your location to calculate accurate prayer times for your area",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await _getCurrentLocation();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.my_location,
                              color: isDark
                                  ? const Color(0xFF1a1a2e)
                                  : const Color(0xFF667eea),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Enable Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF1a1a2e)
                                    : const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      body = buildCard(context);
    }
    
    return Scaffold(
      appBar: customAppBar(context, "Prayer Times", back: false),
      body: body,
    );
  }

  _getCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", position.latitude);
      prefs.setDouble("longitude", position.longitude);
    } else {
      // show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Permission"),
            content: Text(
                "Location permission is required to get accurate prayer times."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
      print("Permission Denied");
    }
  }
}
