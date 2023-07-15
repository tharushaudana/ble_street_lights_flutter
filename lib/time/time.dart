import 'package:intl/intl.dart';

class Time {
  static const String defaultDateTimeFormat = "HH:mm MMMM dd, yyyy";

  static String dateTimeToHumanDiff(DateTime dt, {String format = defaultDateTimeFormat}) {
    Duration diff = now().difference(dt);

    String humanDiff = "";

    if (diff.inDays > 0) {
      humanDiff = "${diff.inDays} day${diff.inDays > 1 ? 's' : ''}";
    }

    else if (diff.inHours > 0) {
      humanDiff = "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}";
    }

    else if (diff.inMinutes > 0) {
      humanDiff = "${diff.inMinutes} minutes${diff.inMinutes > 1 ? 's' : ''}";
    }

    else if (diff.inSeconds > 0) {
      return "recently";
    }

    return "$humanDiff ago";
  }

  static String dateTimeToString(DateTime dt, {String format = defaultDateTimeFormat}) {
    return DateFormat(format).format(dt);
  }

  static DateTime convertStrToDateTime(String str, String format) {
    return DateFormat(format).parse(str);
  }

  static DateTime now() {
    return DateTime.now();
  }
}