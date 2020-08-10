import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

class ActivityIcon extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final double radius;

  ActivityIcon({
    Key key,
    this.icon,
    this.iconSize: 22.0,
    this.radius: 20.0,
  }) : super(key: key);

  @override
  State createState() => ActivityIconState();
}

class ActivityIconState extends State<ActivityIcon>
    with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    double size = (widget.radius * 2.0);

    return Container(
      width: size,
      height: size,
      child: Icon(
        widget.icon,
        color: AppTheme.primary,
        size: widget.iconSize,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(widget.radius),
        ),
        boxShadow: commonBoxShadow(),
      ),
    );
  }
}
