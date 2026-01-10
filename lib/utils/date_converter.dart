
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DateConverter {

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String estimatedOnlyDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  // A method to parse a date string into a DateTime object
  static DateTime parseDateString(String dateString) {
    return DateTime.parse(dateString); // Adjust the parsing format if needed
  }
  static DateTime convertStringToDatetime(String dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }


  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringForDisbursement(String time) {
    var newTime = '${time.substring(0,10)} ${time.substring(11,23)}';
    return DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }


  static String convertTimeToTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static DateTime convertTimeToDateTime(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String convertDateToDate(String date) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(date));
  }

  static String dateTimeStringToMonthAndTime(String dateTime) {
    return DateFormat('dd MMM yyyy HH:mm').format(dateTimeStringToDate(dateTime));
  }

  static String dateTimeForCoupon(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }




  static int differenceInMinute(String? deliveryTime, String? orderTime, int? processingTime, String? scheduleAt) {
    int minTime = processingTime ?? 0;
    if(deliveryTime != null && deliveryTime.isNotEmpty && processingTime == null) {
      try {
        List<String> timeList = deliveryTime.split('-');
        minTime = int.parse(timeList[0]);
      }catch(_) {}
    }
    DateTime deliveryTime0 = dateTimeStringToDate(scheduleAt ?? orderTime!).add(Duration(minutes: minTime));
    return deliveryTime0.difference(DateTime.now()).inMinutes;
  }

  static bool isBeforeTime(String? dateTime) {
    if(dateTime == null) {
      return false;
    }
    DateTime scheduleTime = dateTimeStringToDate(dateTime);
    return scheduleTime.isBefore(DateTime.now());
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('MMM d, yyyy ').format(dateTime.toLocal());
  }

  static int expireDifferanceInDays(DateTime dateTime) {
    int day = dateTime.difference(DateTime.now()).inDays;
    return day;
  }

}


class SimpleDateConverter {
// Method to parse a date string in 'dd-MM-yyyy' format
static DateTime parseDateString(String dateString) {
return DateFormat('dd-MM-yyyy').parse(dateString);
}

// Method to format a DateTime object into 'yyyy-MM-dd' format
static String formatDateToCustomFormat(DateTime dateTime) {
return DateFormat('yyyy-MM-dd').format(dateTime);
}

// Example usage combining both methods
static String parseAndFormatDateString(String dateString) {
DateTime dateTime = parseDateString(dateString);
return formatDateToCustomFormat(dateTime);
}
}

class TimeConverter {
  // Method to format a TimeOfDay object into 'HH:mm' format
  static String formatTimeToCustomFormat(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dateTime);
  }
}

class AppointmentDateTimeConverter {
  // Method to format date strings into 'MMMM dd, yyyy' format
  static String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}


class SimpleTimeConverter {
  // Converts DateTime to a custom time format with AM/PM
  static String formatTimeToCustomFormat(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Format as "hh:mm AM/PM"
  }

  static String format12HourTo24Hour(String time12Hour) {
    // Parse the 12-hour format string to a DateTime object
    DateTime dateTime = DateFormat("hh:mm a").parse(time12Hour);

    // Format it to 24-hour format
    return DateFormat("HH:mm").format(dateTime); // Outputs as "08:25" or "20:25" depending on input
  }
}