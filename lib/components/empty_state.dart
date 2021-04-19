import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  EmptyState({
    this.icon,
    this.text,
    this.tSize,
    this.iSize,
  });

  final IconData icon;
  final String text;
  final iSize;
  final tSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Icon(
              this.icon,
              size: this.iSize,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 35),
            child: Text(
              this.text,
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: this.tSize),
            ),
          )
        ],
      ),
    );
  }
}

