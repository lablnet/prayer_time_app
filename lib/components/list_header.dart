import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  ListHeader({this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
          title: Opacity(
            opacity: 0.54,
            child: Text(
              this.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ));
  }
}
