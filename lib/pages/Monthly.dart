import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../utils.dart';


class Monthly extends StatefulWidget {
  double? latitude;
  double? longitude;
  int? method;
  Monthly({this.latitude, this.longitude, this.method});
  @override
  _MonthlyState createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget buildCard(BuildContext context) {
    DateTime now = DateTime.now();
    HijriCalendar nowHijri = HijriCalendar.now();
    PrayTime prayerTime = PrayTime(method: widget.method!);
    List<DataRow> tbl = [];
    for (int i = 1; i <= 30; i++) {
      var date = now.add(Duration(days: i));
      var hDate = HijriCalendar.fromDate(date);
      DateFormat formatter = DateFormat('MMMM dd, yyyy');
      String formatted = formatter.format(date);

      var times = prayerTime.getPrayerTimes({
        "year": date.year,
        "mon": date.month,
        "mday": date.day,
      }, widget.latitude!, widget.longitude!, parseTimeZoneOffset(now.timeZoneOffset));


      Color color = Colors.transparent;
      if (DateFormat('EEEE').format(date) == 'Sunday') {
        color = Colors.black12;
      }
      if (DateFormat('EEEE').format(date) == 'Friday') {
        color = Colors.greenAccent;
      }
      tbl.add(
          DataRow(
            color: MaterialStateColor.resolveWith((states) => color),
            cells: [
              DataCell(Text(hDate.toFormat("MMMM dd, yyyy"))),
              DataCell(Text(formatted)),
              DataCell(Text(times[0])),
              DataCell(Text(times[1])),
              DataCell(Text(times[2])),
              DataCell(Text(times[3])),
              DataCell(Text(times[5])),
              DataCell(Text(times[6])),
            ],
          )
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Hijri',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Gregorian',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Fajr/Sehar Time',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sunrise',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Dhuhr',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Asr',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Maghrib/Iftar Time',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Isha',
                  ),
                ),
              ],
              rows: <DataRow>[

                ...tbl,
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget? body = null;
    if (widget.latitude == null)  {
      body = Center(child: null,
      );
    } else
      body = buildCard(context);
    return Scaffold(
      appBar: customAppBar(context, "Monthly View"),
      body: body,
    );
  }
}