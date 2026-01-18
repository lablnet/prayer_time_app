import "package:flutter/material.dart";
import 'package:prayer_time_app/class/PrayerTimes.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class Monthly extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? method;

  const Monthly({Key? key, this.latitude, this.longitude, this.method})
      : super(key: key);

  @override
  _MonthlyState createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCard(BuildContext context) {
    DateTime now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PrayerTimes prayerTime = PrayerTimes(
        method: widget.method!,
        latitude: widget.latitude!,
        longitude: widget.longitude!);
    List<Widget> cards = [];

    for (int i = 0; i < 30; i++) {
      var date = now.add(Duration(days: i));
      var hDate = HijriCalendar.fromDate(date);
      DateFormat formatter = DateFormat('MMMM dd, yyyy');
      String formattedDate = formatter.format(date);

      var times = prayerTime.getTimes(date);

      cards.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1e1e2e),
                      const Color(0xFF2d2d3d),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFf8f9fa),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF5f72bd),
                              const Color(0xFF9921e8),
                            ]
                          : [
                              const Color(0xFF667eea),
                              const Color(0xFF764ba2),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hDate.toFormat("MMMM dd, yyyy"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prayer Times
                ...List.generate(times.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF00adb5)
                                    : const Color(0xFF667eea),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              getPrayerName(index),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFf5f6fa)
                                    : const Color(0xFF2d3436),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          times[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF00adb5)
                                : const Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: cards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget? body;
    if (widget.latitude == null || widget.longitude == null) {
      body = Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "Please set location",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = Container(
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
        child: buildCard(context),
      );
    }
    return Scaffold(
      appBar: customAppBar(context, "Monthly View"),
      body: body,
    );
  }
}
