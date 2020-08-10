import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';

//
//end: Alignment.bottomLeft,

class PresetWaves {
  List<Widget> noWaves({
    List<Widget> waves,
  }) {
    return []..addAll((waves == null) ? PresetWaves().defaultWaves() : waves);
  }

  List<Widget> showVerticalWaves({
    List<Widget> waves,
  }) {
    return []
      ..add(Positioned.fill(child: WavyBackground()))
      ..addAll((waves == null) ? PresetWaves().defaultWaves() : waves);
  }

  List<Widget> showHorizontalWaves({
    List<Widget> waves,
  }) {
    return []
      ..add(
        Positioned.fill(
          child: WavyBackground(
            gradientBegin: Alignment.centerRight,
            gradientEnd: Alignment.centerLeft,
          ),
        ),
      )
      ..addAll((waves == null) ? PresetWaves().defaultWaves() : waves);
  }

  List<Widget> defaultWaves() {
    return [
      onBottom(
        Wave(
          height: 90.0,
          speed: 0.4,
        ),
      ),
      onBottom(
        Wave(
          height: 80.0,
          speed: 0.2,
          offset: pi,
        ),
      ),
      onBottom(
        Wave(
          height: 60.0,
          speed: 0.6,
          offset: (pi / 2.0),
        ),
      )
    ];
  }

  List<Widget> largeWaves() {
    return [
      onBottom(
        Wave(
          height: 130.0,
          speed: 0.4,
        ),
      ),
      onBottom(
        Wave(
          height: 120.0,
          speed: 0.2,
          offset: pi,
        ),
      ),
      onBottom(
        Wave(
          height: 100.0,
          speed: 0.6,
          offset: (pi / 2.0),
        ),
      )
    ];
  }
}

// @see https://github.com/felixblaschke/simple_animations_example_app/blob/master/lib/examples/fancy_background.dart
class Wave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;
  final int opacity;

  Wave({
    this.height,
    this.speed,
    this.offset = 0.0,
    this.opacity = 20,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) =>
          Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
          playback: Playback.LOOP,
          duration: Duration(milliseconds: (5000.0 / speed).round()),
          tween: Tween(
            begin: 0.0,
            end: (2.0 * pi),
          ),
          builder: (
            context,
            value,
          ) =>
              CustomPaint(
            foregroundPainter: CurvePainter((value + offset), opacity),
          ),
        ),
      ),
    );
  }
}

class WavyBackground extends StatelessWidget {
  final Color color1;
  final Color color2;
  final int duration;
  final Alignment gradientBegin;
  final Alignment gradientEnd;

  WavyBackground({
    this.color1 = AppTheme.primary,
    this.color2 = Colors.indigo,
    this.duration = 5,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final tween = MultiTrackTween([
      Track('color1')
        ..add(
          Duration(seconds: duration),
          ColorTween(
            begin: color2,
            end: color1,
          ),
        ),
      Track('color2')
        ..add(
          Duration(seconds: duration),
          ColorTween(
            begin: color1,
            end: color2,
          ),
        )
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (
        context,
        animation,
      ) =>
          Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradientBegin,
            end: gradientEnd,
            colors: [
              animation['color1'],
              animation['color2'],
            ],
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double value;
  final int opacity;

  CurvePainter(
    this.value,
    this.opacity,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final white = Paint()..color = Colors.white.withAlpha(opacity);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + (pi / 2.0));
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo((size.width * 0.0), startPointY);
    path.quadraticBezierTo(
      (size.width * 0.5),
      controlPointY,
      size.width,
      endPointY,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return true;
  }
}

onBottom(
  Widget child,
) =>
    Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );
