import 'package:url_launcher/url_launcher.dart';

double parseTimeZoneOffset(var offset)
{
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
