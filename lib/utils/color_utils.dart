import 'package:flutter/painting.dart';

Color hexToColor(
  String code,
) {
  return Color(int.parse(code.substring(0, 6), radix: 16) + 0xFF000000);
}

String colorToHex(
  Color color,
) {
  return '#${color.value.toRadixString(16)}';
}

List<Color> getColors(
  List<dynamic> list,
) {
  List<Color> colors = List<Color>();

  if (list != null) {
    list.forEach((color) {
      if (color is String) {
        colors..add(hexToColor(color));
      }
    });
  }

  return colors;
}
