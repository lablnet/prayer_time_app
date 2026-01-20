import "package:flutter/material.dart";
import 'package:prayer_time_app/config.dart';
import '../utils.dart';

AppBar customAppBar(BuildContext context, String title, {bool back = true, List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    elevation: 1,
    centerTitle: false,
    automaticallyImplyLeading: back,
    actions: <Widget>[
      if (actions != null) ...actions,
      IconButton(
        icon: const Icon(Icons.wb_sunny),
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