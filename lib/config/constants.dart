import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';


const String appName = 'Taskify!';
const String baseUrl = 'http://192.168.1.25:8000/api/';

// /com.example.taskify

const String packageName = 'com.check.taskiiify.task.example.task';
String defaultLanguage = 'en';
String defaultCountryCode = '+91';
String defaultCountry = 'IN';

final Set<String> rtlLanguages = {
  'ar', // Arabic
  'arc', // Aramaic
  'az', // Azeri (Azerbaijani)
  'dv', // Dhivehi (Maldivian)
  'he', // Hebrew
  'ku', // Kurdish (Sorani)
  'fa', // Persian (Farsi)
  'ur', // Urdu
};

String formatDateFromApi(String dateStr, BuildContext context) {
  // Fetch the current date format from SettingsBloc, default to "YYYY-MM-DD"
  String formatVal = context.read<SettingsBloc>().dateformat ?? "YYYY-MM-DD";
  print("jsfdkbnx $formatVal");

  // A map to handle the format conversion from the "settings" format to the required format

  Map<String, String> formatMapping = {
    "DD-MM-YYYY|d-m-Y": "dd-MM-yyyy", // 24-12-2024
    "D-M-YY|j-n-y": "d-M-yy", // 24-12-24
    "MM-DD-YYYY|m-d-Y": "MM-dd-yyyy", // 12-24-2024
    "M-D-YY|n-j-y": "M-d-yy", // 12-24-24
    "YYYY-MM-DD|Y-m-d": "yyyy-MM-dd", // 2024-12-24
    "YY-M-D|Y-n-j": "yy-M-d", // 24-12-24
    "MMMM DD, YYYY|F d, Y": "MMMM dd, yyyy", // December 24, 2024
    "MMM DD, YYYY|M d, Y": "MMM dd, yyyy", // Dec 24, 2024
    "DD-MMM-YYYY|d-M-Y": "dd-MMM-yyyy", // 24-Dec-2024
    "DD MMM, YYYY|d M, Y": "dd MMM, yyyy", // 24 Dec, 2024
    "YYYY-MMM-DD|Y-M-d": "yyyy-MMM-dd", // 2024-Dec-24
    "YYYY, MMM DD|Y, M d": "yyyy, MMM dd", // 2024, Dec 24
  };



  // Check if the format contains '|' and adjust the format value
  if (formatMapping.containsKey(formatVal)) {
    formatVal = formatMapping[formatVal]!;
  } else {
    // Default format if no matching case
    formatVal = "YYYY-MM-DD";
  }


  // Parse the input date string into a DateTime object
  DateTime date;
  try {
    date = DateTime.parse(dateStr); // '2024-12-25'
  } catch (e) {
    return ''; // Return empty if parsing fails
  }

  // Define the variable to hold the formatted date
  String formattedDate = '';

  // Apply the format to the DateTime object
  try {
    formattedDate = DateFormat(formatVal).format(date);
  } catch (e) {
    return ''; // Return empty if formatting fails
  }

  return formattedDate;
}
DateTime? formatDateFromApiAsDate(String dateStr, BuildContext context) {
  String formatVal = context.read<SettingsBloc>().dateformat ?? "YYYY-MM-DD";

  Map<String, String> formatMapping = {
    "DD-MM-YYYY|d-m-Y": "dd-MM-yyyy",
    "D-M-YY|j-n-y": "d-M-yy",
    "MM-DD-YYYY|m-d-Y": "MM-dd-yyyy",
    "M-D-YY|n-j-y": "M-d-yy",
    "YYYY-MM-DD|Y-m-d": "yyyy-MM-dd",
    "YY-M-D|Y-n-j": "yy-M-d",
    "MMMM DD, YYYY|F d, Y": "MMMM dd, yyyy",
    "MMM DD, YYYY|M d, Y": "MMM dd, yyyy",
    "DD-MMM-YYYY|d-M-Y": "dd-MMM-yyyy",
    "DD MMM, YYYY|d M, Y": "dd MMM, yyyy",
    "YYYY-MMM-DD|Y-M-d": "yyyy-MMM-dd",
    "YYYY, MMM DD|Y, M d": "yyyy, MMM dd",
  };

  if (formatMapping.containsKey(formatVal)) {
    formatVal = formatMapping[formatVal]!;
  } else {
    formatVal = "yyyy-MM-dd"; // Default format
  }

  try {
    return DateFormat(formatVal).parse(dateStr);
  } catch (e) {
    print("Error parsing date: $dateStr, Error: $e");
    return null;
  }
}


String dateFormatConfirmedToApi(DateTime inputDate) {
  // Format the DateTime object into YYYY-MM-DD format
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  print("fenskdd $outputFormat");
  return outputFormat.format(inputDate);
}

String dateFormatConfirmed(DateTime inputDate, BuildContext? context) {
  String formatVal = context!.read<SettingsBloc>().dateformat ?? "YYYY-MM-DD";

  // A map to handle the format conversion from the "settings" format to the required format
  Map<String, String> formatMapping = {
    "DD-MM-YYYY|d-m-Y": "dd-MM-yyyy",
    "D-M-YY|j-n-y": "d-M-yy",
    "MM-DD-YYYY|m-d-Y": "MM-dd-yyyy",
    "M-D-YY|n-j-y": "M-d-yy",
    "YYYY-MM-DD|Y-m-d": "yyyy-MM-dd",
    "YY-M-D|Y-n-j": "yy-M-d",
    "MMMM DD, YYYY|F d, Y": "MMMM dd, yyyy",
    "MMM DD, YYYY|M d, Y": "MMM dd, yyyy",
    "DD-MMM-YYYY|d-M-Y": "dd-MMM-yyyy",
    "DD MMM, YYYY|d M, Y": "dd MMM, yyyy",
    "YYYY-MMM-DD|Y-M-d": "yyyy-MMM-dd",
    "YYYY, MMM DD|Y, M d": "yyyy, MMM dd",
  };

  // Check if the format contains '|' and adjust the format value
  if (formatMapping.containsKey(formatVal)) {
    formatVal = formatMapping[formatVal]!;
  } else {
    // Default format if no matching case
    formatVal = "yyyy-MM-dd";
  }
  // Format the DateTime object into YYYY-MM-DD format
  DateFormat outputFormat = DateFormat(formatVal);
  return outputFormat.format(inputDate);
}

DateTime parseDateStringFromApi(String dateString) {

  try {
    // Parse the date string in 'yyyy-MM-dd' format
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
    // Create a new DateTime with the same year, month, and day but no time
    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  } catch (e) {
    // Handle error if the date is invalid
    // Return the current date with time set to midnight (no time component)
    return DateTime.now().toLocal().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
        milliseconds: DateTime.now().millisecond));
  }
}

TimeOfDay convertToTimeOfDay(String timeString) {
  // Parse the time string using DateFormat
  final format = DateFormat("HH:mm");
  final parsedTime = format.parse(timeString);

  // Return a TimeOfDay object using the hours and minutes from parsedTime
  return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
}

String datechange(String givenDate) {

  DateFormat inputFormat = DateFormat('yyyy-MM-dd');
  DateFormat outputFormat = DateFormat('MMM dd, yyyy');
  DateTime date = inputFormat.parse(givenDate);
  String formattedDateString = outputFormat.format(date);

  return formattedDateString; // Output: 22 August 2024
}

String changeTimeFormat(String timeFrom) {
  String time = timeFrom;
  DateTime dateTime =
  DateTime.parse("2024-01-01 $time"); // Use a fixed date for parsing
  String formattedTime = DateFormat('hh:mm').format(dateTime);
  return formattedTime;
}

Map<String, dynamic> convertStringToMap(String inputString) {
  // Removing the outer curly braces
  inputString = inputString.substring(1, inputString.length - 1);

  // Splitting the string by the first occurrence of ', item:' to separate 'type' and 'item'
  List<String> keyValuePairs = inputString.split(', item:');

  // Parsing the type key-value pair
  String typePair = keyValuePairs[0].trim();
  List<String> typeKeyValue = typePair.split(': ');
  String typeKey = typeKeyValue[0].trim();
  String typeValue = typeKeyValue[1].trim();

  // Creating the map and handling 'type'
  Map<String, dynamic> resultMap = {};
  resultMap[typeKey] = typeValue == "null" ? null : typeValue;

  // Parsing the 'item' value which may contain a JSON object
  String itemValue = keyValuePairs[1].trim();

  // Check if 'item' contains a valid JSON object
  if (itemValue.startsWith("{") && itemValue.endsWith("}")) {
    resultMap['item'] = jsonDecode(itemValue); // Decoding JSON
  } else {
    // If not a JSON object, handle as a regular string
    resultMap['item'] = itemValue.replaceAll('"', '');
  }

  return resultMap;
}

String getOrdinalSuffix(int number) {
  if (number >= 11 && number <= 13) {
    return "ᵗʰ"; // Special case for 11th, 12th, 13th
  }
  switch (number % 10) {
    case 1:
      return "ˢᵗ"; // 1st -> ¹ˢᵗ
    case 2:
      return "ⁿᵈ"; // 2nd -> ²ⁿᵈ
    case 3:
      return "ʳᵈ"; // 3rd -> ³ʳᵈ
    default:
      return "ᵗʰ"; // All others -> ᵗʰ
  }
}

Future<void> requestForPermission() async {
  await Permission.microphone.request();
}

void listenForPermissions() async {
  final status = await Permission.microphone.status;
  switch (status) {
    case PermissionStatus.denied:
      requestForPermission();
      break;
    case PermissionStatus.granted:
      break;
    case PermissionStatus.limited:
      break;
    case PermissionStatus.permanentlyDenied:
      break;
    case PermissionStatus.restricted:
      break;
    case PermissionStatus.provisional: // Handle the provisional case
      break;
  }
}

Color hexToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "").replaceAll("0X", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor"; // Add full opacity if missing
  }
  print("hgffdrd ${Color(int.parse("0x$hexColor"))}");
  return Color(int.parse("0x$hexColor")); // Ensure proper hex format
}