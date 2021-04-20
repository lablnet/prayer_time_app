import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

class Settings extends StatefulWidget {
  double latitude = null;
  double longitude = null;
  int method = 1;


  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  NavigationsRoute(BuildContext context, var item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var latitude = prefs.getDouble("latitude") ?? null;
    var longitude = prefs.getDouble("longitude") ?? null;

    //prefs.setInt("method", item);
    print("settings");
    print(latitude);
    print(longitude);
    print(item);
    /*Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(latitude:latitude, longitude: longitude, method: item,)));

    */
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
    for (var item in methods) {
      items.add(
        ListTile(
            title: Text(
              item + i.toString(),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          onTap: () async => {
              NavigationsRoute(context, item)
          },
          tileColor: (i == widget.method)
              ? Colors.green[200]
              : Colors.transparent,

        ),
      );
      i++;
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
