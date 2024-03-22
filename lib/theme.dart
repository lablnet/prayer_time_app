import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFFFFFFF),
    hintColor: Colors.blue,
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    hintColor: Colors.blue,
  );
}