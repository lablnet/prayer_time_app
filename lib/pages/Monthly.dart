import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';


class Monthly extends StatefulWidget {
  double latitude;
  double longitude;
  int method;
  Monthly({this.latitude, this.longitude, this.method});
  @override
  _MonthlyState createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

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
    PrayTime prayerTime = PrayTime(method: widget.method);
    List<TableRow> tbl = [];
    for (int i = 1; i <= 30; i++) {
      var date = now.add(Duration(days: i));
      DateFormat formatter = DateFormat('MMMM dd yyyy');
      String formatted = formatter.format(now);

      var times = prayerTime.getPrayerTimes({
        "year": date.year,
        "mon": date.month,
        "mday": date.day,
      }, widget.latitude, widget.longitude, parseTimeZoneOffset(now.timeZoneOffset));

      tbl.add(
          TableRow(
            children: [
              Text(formatted),
              Text(times[0]),
              Text(times[1]),
              Text(times[2]),
              Text(times[3]),
              Text(times[5]),
              Text(times[6]),
            ],
          )
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>
        [

          Divider(),
          Flexible(
            child: Table(

                border: TableBorder.all(),
                children: [
                  TableRow( children: [
                    Column(children:[
                      Text('Date')
                    ]),
                    Column(children:[
                      Text('Fajr')
                    ]),
                    Column(children:[
                      Text('Sunrise')
                    ]),
                    Column(children:[
                      Text('Dhuhr')
                    ]),
                    Column(children:[
                      Text('Asr')
                    ]),
                    Column(children:[
                      Text('Maghrib')
                    ]),
                    Column(children:[
                      Text('Isha')
                    ]),

                  ]),

                  ...tbl,
                ]),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget body = null;
    if (widget.latitude == null)  {
      body = Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_location, size: 80),

            Text("Need your Location", style: TextStyle(
                fontSize: 26
            ),
              textAlign: TextAlign.center,
            ),
            Text("Your location is required for accurate prayer time calculations.", style: TextStyle(
              fontSize: 15,
            ),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              child: Text("Get location"),
              onPressed: () async {
                await _getCurrentLocation();
              },
            ),
          ],
        ),
      );
    } else
      body = buildCard(context);
    return Scaffold(
      appBar: customAppBar(context, "Home"),
      body: body,
    );
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(()  {
      widget.latitude = position.latitude;
      widget.longitude = position.longitude;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("latitude", position.latitude);
    prefs.setDouble("longitude", position.longitude);

  }
}