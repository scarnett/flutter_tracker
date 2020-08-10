import 'dart:ui';
import 'package:flutter/material.dart';

class CircleClipper extends CustomClipper<Rect> {
  final double radius;

  CircleClipper({
    this.radius: 25.0,
  });

  @override
  Rect getClip(
    Size size,
  ) {
    return Rect.fromCircle(
      center: Offset(
        (size.width / 2.0),
        (size.height / 2.0),
      ),
      radius: radius,
    );
  }

  @override
  bool shouldReclip(
    CustomClipper<Rect> oldClipper,
  ) {
    return false;
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(
    Size size,
  ) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(
          (size.width / 2.0),
          (size.height / 2.0),
        ),
        radius: (size.width * 0.45),
      ))
      ..addRect(Rect.fromLTWH(
        0.0,
        0.0,
        size.width,
        size.height,
      ))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
  ) =>
      false;
}
