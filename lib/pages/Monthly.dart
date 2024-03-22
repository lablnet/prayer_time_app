import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../utils.dart';


class Monthly extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? method;

  const Monthly({Key? key, this.latitude, this.longitude, this.method}) : super(key: key);

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
    PrayTime prayerTime = PrayTime(method: widget.method!);
    List<Widget> cards = [];

    for (int i = 0; i < 30; i++) {
      var date = now.add(Duration(days: i));
      var hDate = HijriCalendar.fromDate(date);
      DateFormat formatter = DateFormat('MMMM dd, yyyy');
      String formattedDate = formatter.format(date);

      var times = prayerTime.getPrayerTimes({
        "year": date.year,
        "mon": date.month,
        "mday": date.day,
      }, widget.latitude!, widget.longitude!, parseTimeZoneOffset(now.timeZoneOffset));

      cards.add(
        Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${hDate.toFormat("MMMM dd, yyyy")} / $formattedDate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...List.generate(times.length, (index) {
                  var prayer;
                  switch (index) {
                    case 0:
                      prayer = "Fajr";
                      break;
                    case 1:
                      prayer = "Sunrise";
                      break;
                    case 2:
                      prayer = "Dhuhr";
                      break;
                    case 3:
                      prayer = "Asr";
                      break;
                    case 4:
                      prayer = "Maghrib";
                      break;
                    case 5:
                      prayer = "Isha";
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('$prayer : ${times[index]}', style: TextStyle(fontSize: 14)),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(children: cards),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (widget.latitude == null || widget.longitude == null) {
      body = Center(child: Text("Please set location"));
    } else {
      body = buildCard(context);
    }
    return Scaffold(
      appBar: customAppBar(context, "Monthly View"),
      body: body,
    );
  }
}
