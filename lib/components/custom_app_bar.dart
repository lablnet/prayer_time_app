import "package:flutter/material.dart";
import 'package:prayer_time_app/config.dart';
import 'package:prayer_time_app/pages/About.dart';
import 'package:url_launcher/url_launcher.dart';

openUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


AppBar customAppBar(BuildContext context, String title, {bool back = true}) {
  return AppBar(
    title: Text(title),
    elevation: 1,
    centerTitle: false,
    automaticallyImplyLeading: back,
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.wb_sunny),
        onPressed: () => {
          currentTheme.switchTheme(),
        },
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'Settings':
              Navigator.pushNamed(context, 'settings');
              break;
          case 'About':
            Navigator.pushNamed(context, 'about');
            break;
          default:
              openUrl("https://github.com/lablnet/prayer_time_app");

            break;
          }
        },
        itemBuilder: (BuildContext context) {
          return {'Settings', 'About', "Source Code",}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),

    ],
  );

}

class RouteNavigation extends StatelessWidget {
  var name;

  RouteNavigation(this.name);

  @override
  Widget build(BuildContext context) {
    print("menhu");
    print(name);
    switch (name) {
      case 'Settings':
        break;
      case 'About':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => About()));
        break;
      default:
        break;
    }
  }
}