import 'dart:ui';

class BackgroundItem {
  final String id;
  final String asset;

  BackgroundItem({required this.id, required this.asset});
}


class BackgroundPreset {
  final String title;
  final String imagePath;
  final Color? color;

  BackgroundPreset({
    required this.title,
    this.imagePath = "",
    this.color,
  });
}





