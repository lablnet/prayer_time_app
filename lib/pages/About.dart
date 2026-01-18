import "package:flutter/material.dart";
import 'package:prayer_time_app/components/custom_app_bar.dart';
import 'package:prayer_time_app/components/list_header.dart';
import 'package:prayer_time_app/utils.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "About"),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListHeader(title: "App"),
            ListTile(
              title: Text("Prayers Time"),
              subtitle: Text("Version: 1.0.2"),
            ),
            ListTile(
              title: Text("Copyright"),
              subtitle: Text("2021 - Muhammad Umer Farooq"),
            ),
            ListTile(
              title: Text("License"),
              subtitle: Text("GNU GPL 3"),
            ),
            ListTile(
              title: Text("Special Thanks"),
              subtitle: Text("http://praytimes.org/"),
              onLongPress: () async {
                await openUrl("http://praytimes.org/");
              },
            ),
            ListHeader(title: "Flutter"),
            ListTile(
              title: Text("Flutter version"),
              subtitle: Text("3.22.2"),
            ),
            ListTile(
              title: Text("SDK Channel"),
              subtitle: Text("Stable"),
            ),
            ListTile(
              title: Text("Dark SDK version"),
              subtitle: Text("3.4.1"),
            ),
          ],
        ),
      ),
    );
  }
}
