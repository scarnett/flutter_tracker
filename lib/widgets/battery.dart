import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

class Battery extends StatefulWidget {
  final BatteryInfo battery;
  final double ratio;
  final double size;
  final Color textColor;
  final Color fullColor;
  final int fullMinLevel;
  final Color warnColor;
  final int warnMinLevel;
  final Color dangerColor;
  final bool iconOnly;
  final bool compact;

  Battery({
    this.battery,
    this.ratio = 2.0,
    this.size = 10.0,
    this.textColor = Colors.black87,
    this.fullColor = Colors.green,
    this.fullMinLevel = 40,
    this.warnColor = Colors.orange,
    this.warnMinLevel = 15,
    this.dangerColor = Colors.red,
    this.iconOnly = false,
    this.compact = false,
  });

  @override
  State createState() => BatteryState();
}

class BatteryState extends State<Battery> {
  Battery battery = Battery();

  @override
  Widget build(
    BuildContext context,
  ) {
    if ((widget.battery == null) || (widget.battery.level == 100)) {
      return Container();
    }

    if (widget.iconOnly) {
      return _buildBatteryIcon();
    }

    List<Widget> children = [
      widget.compact ? _buildCompactBatteryBody() : _buildBatteryBody(),
    ];

    return Stack(
      children: children,
    );
  }

  Widget _buildBatteryBody() {
    return Container(
      height: 16.0,
      decoration: BoxDecoration(
        color: AppTheme.light(),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: widget.textColor,
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildBatteryIcon(),
            Padding(
              padding: const EdgeInsets.only(
                top: 1.0,
              ),
              child: Text(
                (widget.battery.level == null)
                    ? ''
                    : '${widget.battery.level.round()}%',
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.size,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBatteryBody() {
    return Container(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 8.0,
        child: _buildBatteryIcon(),
      ),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: commonBoxShadow(),
      ),
    );
  }

  Widget _buildBatteryIcon() {
    return Container(
      child: SizedBox(
        height: widget.size,
        width: (widget.size * widget.ratio),
        child: CustomPaint(
          painter: BatteryIndicatorPainter(
            widget.battery.level,
            widget.textColor,
            widget.fullColor,
            widget.fullMinLevel,
            widget.warnColor,
            widget.warnMinLevel,
            widget.dangerColor,
            isInDanger,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                right: ((widget.size * widget.ratio) * 0.04),
              ),
              child: widget.battery.charging
                  ? Transform.rotate(
                      angle: (math.pi / 2.0),
                      child: Icon(
                        Icons.flash_on,
                        color:
                            isInDanger ? widget.dangerColor : widget.textColor,
                        size: (widget.size - 0.5),
                      ),
                    )
                  : Text(
                      '',
                      style: TextStyle(
                        fontSize: (widget.size - 2.0),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  get isInDanger =>
      (widget.battery != null) &&
      (widget.battery.level != null) &&
      (widget.battery.level <= widget.warnMinLevel);
}

class BatteryIndicatorPainter extends CustomPainter {
  double level;
  Color textColor;
  Color fullColor;
  int fullMinLevel;
  Color warnColor;
  int warnMinLevel;
  Color dangerColor;
  bool isInDanger;

  BatteryIndicatorPainter(
    this.level,
    this.textColor,
    this.fullColor,
    this.fullMinLevel,
    this.warnColor,
    this.warnMinLevel,
    this.dangerColor,
    this.isInDanger,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRRect(
        RRect.fromLTRBR(
          0.0,
          (size.height * 0.05),
          (size.width * 0.92),
          (size.height * 0.95),
          Radius.circular(size.height * 0.1),
        ),
        Paint()
          ..color = isInDanger ? dangerColor : textColor
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke);

    canvas.drawRRect(
        RRect.fromLTRBR(
          (size.width * 0.92),
          (size.height * 0.25),
          size.width,
          (size.height * 0.75),
          Radius.circular(size.height * 0.1),
        ),
        Paint()
          ..color = isInDanger ? dangerColor : textColor
          ..style = PaintingStyle.fill);

    canvas.clipRect(
      Rect.fromLTWH(
        0.0,
        (size.height * 0.05),
        (((size.width * 0.92) * fixedLevel) / 100.0),
        (size.height * 0.95),
      ),
    );

    double offset = (size.height * 0.1);

    canvas.drawRRect(
      RRect.fromLTRBR(
        offset,
        ((size.height * 0.05) + offset),
        ((size.width * 0.92) - offset),
        ((size.height * 0.95) - offset),
        Radius.circular(size.height * 0.1),
      ),
      Paint()
        ..color = getLevelColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return ((oldDelegate as BatteryIndicatorPainter).level != level) ||
        ((oldDelegate as BatteryIndicatorPainter).textColor != textColor);
  }

  get fixedLevel => (level < 10.0) ? (4.0 + (level / 2.0)) : level;

  get getLevelColor => isInDanger
      ? dangerColor
      : (level <= fullMinLevel) ? warnColor : fullColor;
}
