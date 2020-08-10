import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_tracker/utils/scalebar_utils.dart';

class MapScaleLayerPluginOption extends LayerOptions {
  TextStyle textStyle;
  Color lineColor;
  double lineWidth;
  final EdgeInsets padding;
  final bool safeArea;

  MapScaleLayerPluginOption({
    this.textStyle,
    this.lineColor = Colors.white,
    this.lineWidth = 2.0,
    this.padding,
    this.safeArea = true,
  });
}

class MapScaleLayerPlugin implements MapPlugin {
  @override
  Widget createLayer(
    LayerOptions options,
    MapState mapState,
    Stream<Null> stream,
  ) {
    if (options is MapScaleLayerPluginOption) {
      return MapScaleLayer(options, mapState, stream);
    }

    throw Exception('Unknown options type for ScaleLayerPlugin: $options');
  }

  @override
  bool supportsLayer(
    LayerOptions options,
  ) {
    return options is MapScaleLayerPluginOption;
  }
}

class MapScaleLayer extends StatelessWidget {
  final MapScaleLayerPluginOption scaleLayerOpts;
  final MapState map;
  final Stream<Null> stream;
  final scale = [
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5,
  ];

  MapScaleLayer(
    this.scaleLayerOpts,
    this.map,
    this.stream,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    if (scaleLayerOpts.safeArea) {
      return SafeArea(
        top: true,
        child: Stack(
          children: <Widget>[
            _buildBody(context),
          ],
        ),
      );
    }

    return _buildBody(context);
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    double zoom = map.zoom;
    double distance = scale[max(0, min(20, zoom.round() + 2))].toDouble();
    LatLng center = map.center;
    CustomPoint<num> start = map.project(center);
    LatLng targetPoint =
        calculateEndingGlobalCoordinates(center, 90.0, distance);

    CustomPoint<num> end = map.project(targetPoint);

    // TODO: Handle Imperial and Metric
    String displayDistance = (distance > 999.0)
        ? '${(distance / 1000).toStringAsFixed(0)} km'
        : '${distance.toStringAsFixed(0)} m';

    double width = (end.x - start.x);
    double pageWidth = MediaQuery.of(context).size.width;

    return Positioned(
      left: ((pageWidth / 2) - (width / 2)),
      child: Opacity(
        opacity: 0.3,
        child: CustomPaint(
          painter: ScalePainter(
            width,
            displayDistance,
            lineColor: scaleLayerOpts.lineColor,
            lineWidth: scaleLayerOpts.lineWidth,
            padding: scaleLayerOpts.padding,
            textStyle: scaleLayerOpts.textStyle,
          ),
        ),
      ),
    );
  }
}

class ScalePainter extends CustomPainter {
  ScalePainter(
    this.width,
    this.text, {
    this.padding,
    this.textStyle,
    this.lineWidth,
    this.lineColor,
  });

  final double width;
  final EdgeInsets padding;
  final String text;
  TextStyle textStyle;
  double lineWidth;
  Color lineColor;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.square
      ..strokeWidth = lineWidth;

    int sizeForStartEnd = 4;
    num paddingLeft =
        (padding == null) ? 0 : padding.left + sizeForStartEnd / 2;

    num paddingTop = (padding == null) ? 0 : padding.top;
    TextSpan textSpan = TextSpan(style: textStyle, text: text);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas,
        Offset(width / 2 - textPainter.width / 2 + paddingLeft, paddingTop));

    paddingTop += textPainter.height;

    Offset p1 = Offset(paddingLeft, sizeForStartEnd + paddingTop);
    Offset p2 = Offset(paddingLeft + width, sizeForStartEnd + paddingTop);

    // draw start line
    canvas.drawLine(Offset(paddingLeft, paddingTop),
        Offset(paddingLeft, sizeForStartEnd + paddingTop), paint);

    // draw middle line
    double middleX = width / 2 + paddingLeft - lineWidth / 2;

    canvas.drawLine(Offset(middleX, paddingTop + sizeForStartEnd / 2),
        Offset(middleX, sizeForStartEnd + paddingTop), paint);

    // draw end line
    canvas.drawLine(Offset(width + paddingLeft, paddingTop),
        Offset(width + paddingLeft, sizeForStartEnd + paddingTop), paint);

    // draw bottom line
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return true;
  }
}
