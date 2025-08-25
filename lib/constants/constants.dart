import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const cDefaultPadding = 20.0;

// const cPrimaryColor = Color.fromARGB(255, 221, 5, 5);
const Color cPrimaryColor = Color(0xFFD61119); // Sneha Red
const Color cAccentColor = Color(0xFFF6BD19); // Sneha Gold/Yellow
const Color cBackgroundColor = Color(0xFFFFFDF7); // Warm off-white
const Color cCardColor = Color(0xFF9A031E);   
const Color cTextColor = Color(0xFF333333);
const Color cWhite = Colors.white;
const Color cBlack = Colors.black;
const Color cGrey = Colors.grey;
const cSecondaryColor = Color(0xFF444545);
const cAppBarColor = Color.fromRGBO(236, 255, 252, 1);
// const cWhite = Color(0XFFffffff);
const cGray = Color(0XFFEEEEEE);
const cPrimaryGray = Color(0xFF534D50);

const cGreen = Color(0XFFD3F8DF);
const cGreenDark = Color(0XFF13B467);
const cSecondaryWhite = Color(0xFFF7F8F9);
const cSecondaryGary = Color(0XFFE5E5E5);
const cBackground = Color.fromARGB(255, 245, 240, 240);
// const cBlack = Color(0XFF000000);
const cSecondaryBlack = Color(0x26000000);
const cGrayDark = Color(0XFF534D50);
const cLight = Color(0xFFE8ECF4);
const cBlue = Color(0xFF3023AE);
const cLightWhite = Color(0xFFEEEEEE);
const cYellow = Color(0xFFFFCB14);
const clightBlue = Color(0xFFD0DBEA);
const cSecondaryBlue = Color(0xFF8390A1);
const clight = Color(0xFFE8ECF4);
const cLightBlue = Color(0xFFECFFFC);
const clightRed = Color(0xFFAAAAAA);
const cShadeBlue = Color(0xFF0E1346);
const clightShadeBlue = Color(0xFF898A95);
const cShadeRed = Color(0x1E000000);
const cRedShade = Color(0xFFD65914);
const cLightPrimary = Color(0xFFFF7A30);
const clightGrey = Color(0XFF8391A1);
const clightColor = Color(0xff030395);
const LinearGradient cAppBarGradient = LinearGradient(
  colors: [
    Color(0XFF7C0638),
    Color(0xFF9B154D),
  ],
  stops: [0.0, 1.0],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
const LinearGradient cPinkGradient = LinearGradient(
  colors: [
    Color(0xFF9B154D),
    Color(0xFF7C0638),
  ],
  stops: [0.0, 1.0],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
const cBoxShadow = BoxShadow(
  color: Color(0xFF3C021A0F),
  blurRadius: 4,
  offset: Offset(0, 2),
);

const currencySymbol = '₹';

Color getStatusColor(String status) {
  switch (status) {
    case '0':
      return Colors.blue;
    case '1':
      return Colors.orange;
    case '2':
    case '4':
    case '6':
      return Colors.green;
    case '3':
    case '5':
    case '7':
      return Colors.red;
    case '8':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String getStatusText(String status) {
  Map<String, String> statusMap = {
    '0': 'Entry Created',
    '1': 'District Approval Pending',
    '2': 'Division Approval Pending',
    '3': 'District Approval Rejected',
    '4': 'Admin Approval Pending',
    '5': 'Division Approval Rejected',
    '6': 'Approvals Completed',
    '7': 'Admin Approval Rejected',
    '8': 'Repair Completed',
  };
  return statusMap[status] ?? 'Unknown Status';
}

// Function to format the date
String formatDate(String? dateTime) {
  if (dateTime == null || dateTime.isEmpty) {
    return "N/A";
  }
  try {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yy hh:mm a').format(parsedDate);
  } catch (e) {
    return "Invalid date";
  }
}
