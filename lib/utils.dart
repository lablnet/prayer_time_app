import 'package:url_launcher/url_launcher.dart';

double parseTimeZoneOffset(var offset) {
  var timezone = offset.toString();
  var l = timezone.split(':');
  var prepare = l[0] + '.' + l[1];
  return (double.parse(prepare));
}

openUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

String getPrayerName(int index) {
  switch (index) {
    case 0:
      return "Sehar Time/Fajr";
    case 1:
      return "Sunrise";
    case 2:
      return "Dhuhr";
    case 3:
      return "Asr";
    case 4:
      return "Iftar Time/Maghrib";
    case 5:
      return "Isha";
    default:
      return "Unknown";
  }
}
