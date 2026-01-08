import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool _darkMode = false;
  bool _watermark = true;
  String _background = "Studio White";

  bool get darkMode => _darkMode;
  bool get watermark => _watermark;
  String get background => _background;

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void toggleWatermark(bool value) {
    _watermark = value;
    notifyListeners();
  }

  void changeBackground(String value) {
    _background = value;
    notifyListeners();
  }



}
