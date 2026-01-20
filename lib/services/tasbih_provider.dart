import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class TasbihProvider with ChangeNotifier {
  int _counter = 0;
  int _goal = 33;
  bool _notificationsEnabled = true;

  int get counter => _counter;
  int get goal => _goal;

  TasbihProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('tasbih_counter') ?? 0;
    _goal = prefs.getInt('tasbih_goal') ?? 33;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_counter', _counter);
    await prefs.setInt('tasbih_goal', _goal);
  }

  void increment() async {
    _counter++;
    notifyListeners();
    _saveToPrefs();

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    
    if (_counter % _goal == 0) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 200, 100, 200]);
      }
    }
  }

  void reset() {
    _counter = 0;
    notifyListeners();
    _saveToPrefs();
  }

  void setGoal(int newGoal) {
    if (newGoal > 0) {
      _goal = newGoal;
      notifyListeners();
      _saveToPrefs();
    }
  }
}
