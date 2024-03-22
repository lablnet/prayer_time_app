import 'package:prayer_time/prayer_time.dart';
import 'package:prayer_time_app/utils.dart';

class PrayerTimes {
  final int method;
  final double latitude;
  final double longitude;

  PrayerTimes({required this.method, required this.latitude, required this.longitude});

  List<String> getTimes(DateTime date) {
    PrayTime prayerTime = PrayTime(method: method);
    var times = prayerTime.getPrayerTimes({
      "year": date.year,
      "mon": date.month,
      "mday": date.day,
    }, latitude, longitude, parseTimeZoneOffset(date.timeZoneOffset));

    // remove 6th index from the list, because it is not required.
    times.removeAt(5);
    return times;
  }
}
