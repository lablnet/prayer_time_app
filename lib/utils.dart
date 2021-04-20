double parseTimeZoneOffset(var offset)
{
  var timezone = offset.toString();
  var l = timezone.split(':');
  var prepare = l[0] + '.' + l[1];
  return (double.parse(prepare));
}
