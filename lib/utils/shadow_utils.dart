import 'package:flutter/material.dart';

List<BoxShadow> commonBoxShadow({
  color: Colors.black38,
  blurRadius: 1.0,
}) {
  return [
    BoxShadow(
      color: color,
      blurRadius: blurRadius,
      offset: const Offset(0.0, 1.0),
    ),
  ];
}

List<BoxShadow> cardBoxShadow({
  color: Colors.black26,
  blurRadius: 1.0,
}) {
  return [
    BoxShadow(
      color: color,
      blurRadius: blurRadius,
      offset: const Offset(0.0, 0.5),
    ),
  ];
}

List<Shadow> commonTextShadow({
  color: Colors.black38,
  blurRadius: 1.0,
}) {
  return [
    Shadow(
      color: color,
      blurRadius: blurRadius,
      offset: const Offset(0.0, 1.0),
    ),
  ];
}
