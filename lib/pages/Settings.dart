import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';

class Settings extends StatefulWidget {
  double? latitude;
  double? longitude;
  int? method;
  Settings({this.latitude, this.longitude, this.method});


  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  NavigationsRoute(BuildContext context, var item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var latitude = prefs.getDouble("latitude") ?? null;
    var longitude = prefs.getDouble("longitude") ?? null;

    prefs.setInt("method", item);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(latitude:latitude, longitude: longitude, method: item,)));

    //Navigator.pushNamed(context, 'home');

  }
  @override
  Widget build(BuildContext context) {
    List methods = [
      'Jafari',
      'University of Islamic Sciences, Karachi',
      'Islamic Society of North America (ISNA)',
      'Muslim World League (MWL)',
      'Umm al-Qura, Makkah',
      'Egyptian General Authority of Survey',
      'Institute of Geophysics, University of Tehran'
    ];
    List<Widget> items = [];
    int i = 0;
    for (int i = 0; i < methods.length; i++) {
      items.add(
        ListTile(
            title: Text(
              methods[i],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          onTap: () async => {
              NavigationsRoute(context, i)
          },
          tileColor: (i == widget.method)
              ? Colors.green[200]
              : Colors.transparent,

        ),
      );
    }
    return Scaffold(
      appBar: customAppBar(context, "Settings"),
      body:  Padding(
        padding: const EdgeInsets.all(8.0),
    child: Column(
    children: <Widget>
      [
        Text("Please Select PrayTimes Method"),
          ...items
      ],
    ),
      ),
    );
  }
}
