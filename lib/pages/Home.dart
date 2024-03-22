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
  Map methods = {
    0: 'Jafari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm al-Qura, Makkah',
    5: 'Egyptian General Authority of Survey',
    6: "Custom",
    7: 'Institute of Geophysics, University of Tehran'
  };
  double? latitude;
  double? longitude;
  int? method;
  Home({this.latitude, this.longitude, this.method});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
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
    final DateFormat formatter = DateFormat('MMMM dd, yyyy');
    final String formatted = formatter.format(now);
    parseTimeZoneOffset(now.timeZoneOffset);
    PrayTime prayerTime = PrayTime(method: widget.method!);
    var times = prayerTime.getPrayerTimes({
      "year": now.year,
      "mon": now.month,
      "mday": now.day,
    }, widget.latitude!, widget.longitude!,
        parseTimeZoneOffset(now.timeZoneOffset));
    // remove 6th index from the list, because it is not required.
    times.removeAt(5);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: <Widget>[
          Center(
            child: Column(
              children: [
                Text(
                  "Today",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.methods[widget.method],
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              nowHijri.toFormat("MMMM dd, yyyy"),
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            subtitle: Text(formatted,
                style: TextStyle(
                  fontSize: 20,
                )),
          ),
          Divider(),
          ...List.generate(times.length, (index) {
            return ListTile(
              title: Text(
                getPrayerName(index),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              subtitle: Text(times[index],
                  style: TextStyle(
                    fontSize: 26,
                  )),
            );
          }),
          Divider(),
          TextButton(
            child: Text("Extend View"),
            onPressed: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Monthly(
                          latitude: widget.latitude!,
                          longitude: widget.longitude!,
                          method: widget.method!)))
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? body = null;
    if (widget.latitude == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_location, size: 80),
            Text(
              "Need your Location",
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            Text(
              "Your location is required for accurate prayer time calculations.",
              style: TextStyle(
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
      appBar: customAppBar(context, "Prayers Time"),
      body: body,
    );
  }

  _getCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        widget.latitude = position.latitude;
        widget.longitude = position.longitude;
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
