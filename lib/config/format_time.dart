class FormatTime {
  String coverTimeFromIso(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);

    int days = dateTime.day;
    int months = dateTime.month;
    int years = dateTime.year;

    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    int seconds = dateTime.second;

    String daysString = days < 10 ? '0$days' : '$days';
    String monthsString = months < 10 ? '0$months' : '$months';
    String yearsString = years < 10 ? '0$years' : '$years';

    String hoursString = hours < 10 ? '0$hours' : '$hours';
    String minutesString = minutes < 10 ? '0$minutes' : '$minutes';
    String secondsString = seconds < 10 ? '0$seconds' : '$seconds';

    String dateTimeString =
        '$daysString/$monthsString/$yearsString $hoursString:$minutesString:$secondsString';
    return dateTimeString;
  }
}
