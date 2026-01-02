import 'package:cloud_firestore/cloud_firestore.dart';
class AppUtils {

  /// Format Firestore Timestamp → yyyy-MM-dd
  static String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "--";
    final date = timestamp.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Email validation
  static bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


}