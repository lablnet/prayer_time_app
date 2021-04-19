import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import './pages/Home.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time/prayer_time.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  String _currentAddress;
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

  double parseTimeZoneOffset(var offset)
  {
    var timezone = offset.toString();
    var l = timezone.split(':');
    var prepare = l[0] + '.' + l[1];
    return (double.parse(prepare));
  }
  Widget buildCard(BuildContext context) {
    DateTime now = DateTime.now();
    HijriCalendar nowHijri = HijriCalendar.now();
    final DateFormat formatter = DateFormat('MMMM dd yyyy');
    final String formatted = formatter.format(now);
    print(now.timeZoneOffset);
    parseTimeZoneOffset(now.timeZoneOffset);
    PrayTime prayerTime = PrayTime(method: widget.method);
    var tbl = [];
    for (int i = now.day; i <= 30; i++) {
      var times = prayerTime.getPrayerTimes({
        "year": now.year,
        "mon": now.month,
        "mday": i,
      }, widget.latitude, widget.longitude, parseTimeZoneOffset(now.timeZoneOffset));

      tbl.add(
          TableRow(
            children: [
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
          Text(_currentAddress ?? "" , style: TextStyle(
              fontSize: 17
          )),
          Text("Extend View", style: TextStyle(
              fontSize: 13
          ),
          ),
          TextButton(
            child: Text("Back"),
            onPressed: () => {
              Home(latitude: widget.latitude, longitude: widget.longitude, method: widget.method,);
            },
          ),

          Divider(),
      Table(
        border: TableBorder.all(),
        children: [
          TableRow( children: [
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
    ]),

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