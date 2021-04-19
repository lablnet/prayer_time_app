import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier {
  // we need to set the real time change flag, in order to change theme real time.
  bool _isDark = false, _rchange = false;
  bool get isDark => _isDark;

  void saveState(status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("theme", status);
  }

  ThemeMode currentTheme({bool theme = false}) {
    // if there is no real time change, then use value from preference.
    if (_rchange == false) _isDark = theme;
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    _isDark = _isDark ? false : true;

    // set real change to true, to effect theme.
    _rchange = true;
    saveState(isDark);
    notifyListeners();
  }
}