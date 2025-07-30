class FormatTime {
  String coverTimeFromIso(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);

    int hours = dateTime.hour;
    int minutes = dateTime.minute;

    String minutesString = minutes < 10 ? '0$minutes' : '$minutes';
    String hoursString = hours < 10 ? '0$hours' : '$hours';

    String timeString = '$hoursString:$minutesString';
    return timeString;
  }
}
