import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:prayer_time_app/models/tasbih_item.dart';
import 'package:prayer_time_app/services/notification_service.dart';

class TasbihProvider with ChangeNotifier {
  List<TasbihItem> _tasbihs = [];

  List<TasbihItem> get tasbihs => _tasbihs;

  TasbihProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Check if there is old data to migrate
    int? oldCounter = prefs.getInt('tasbih_counter');
    int? oldGoal = prefs.getInt('tasbih_goal');
    
    List<String>? tasbihsList = prefs.getStringList('tasbih_list');
    
    if (tasbihsList != null) {
      _tasbihs = tasbihsList.map((item) => TasbihItem.fromJson(item)).toList();
      _checkAndResetCounters();
    } else if (oldCounter != null || oldGoal != null) {
      // Migrate old data
      _tasbihs.add(
        TasbihItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'General Tasbih',
          counter: oldCounter ?? 0,
          goal: oldGoal ?? 33,
        ),
      );
      // Remove old data keys so migration happens only once
      await prefs.remove('tasbih_counter');
      await prefs.remove('tasbih_goal');
      _saveToPrefs();
    }

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasbihsList = _tasbihs.map((item) => item.toJson()).toList();
    await prefs.setStringList('tasbih_list', tasbihsList);
    NotificationService().scheduleTasbihReminders(_tasbihs);
  }

  void addTasbih(String name, int goal, TargetType targetType) {
    _tasbihs.add(
      TasbihItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        goal: goal,
        targetType: targetType,
      ),
    );
    notifyListeners();
    _saveToPrefs();
  }

  void updateTasbih(String id, String name, int goal, TargetType targetType) {
    int index = _tasbihs.indexWhere((item) => item.id == id);
    if (index != -1) {
      _tasbihs[index].name = name;
      _tasbihs[index].goal = goal;
      _tasbihs[index].targetType = targetType;
      notifyListeners();
      _saveToPrefs();
    }
  }

  void deleteTasbih(String id) {
    _tasbihs.removeWhere((item) => item.id == id);
    notifyListeners();
    _saveToPrefs();
  }

  TasbihItem? getTasbih(String id) {
    try {
      return _tasbihs.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  void increment(String id) async {
    int index = _tasbihs.indexWhere((item) => item.id == id);
    if (index != -1) {
      _tasbihs[index].counter++;
      _tasbihs[index].totalCount++;
      _tasbihs[index].lastUpdated = DateTime.now();
      notifyListeners();
      _saveToPrefs();

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 50);
      }
      
      if (_tasbihs[index].counter > 0 && _tasbihs[index].counter % _tasbihs[index].goal == 0) {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [0, 200, 100, 200]);
        }
      }
    }
  }

  void reset(String id) {
    int index = _tasbihs.indexWhere((item) => item.id == id);
    if (index != -1) {
      _tasbihs[index].counter = 0;
      _tasbihs[index].lastUpdated = DateTime.now();
      notifyListeners();
      _saveToPrefs();
    }
  }

  void _checkAndResetCounters() {
    DateTime now = DateTime.now();
    bool changed = false;

    for (var tasbih in _tasbihs) {
      if (tasbih.targetType == TargetType.none) continue;

      bool shouldReset = false;
      if (tasbih.targetType == TargetType.daily) {
        // Check if lastUpdated was on a different day
        if (tasbih.lastUpdated.year != now.year ||
            tasbih.lastUpdated.month != now.month ||
            tasbih.lastUpdated.day != now.day) {
          shouldReset = true;
        }
      } else if (tasbih.targetType == TargetType.weekly) {
        // Check if lastUpdated was in a different week (simplified to 7 days)
        if (now.difference(tasbih.lastUpdated).inDays >= 7) {
          shouldReset = true;
        }
      }

      if (shouldReset) {
        tasbih.counter = 0;
        tasbih.lastUpdated = now;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      _saveToPrefs();
    }
  }
}
