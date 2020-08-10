import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class MapTypeFab extends StatefulWidget {
  final double bottomPosition;
  final double rightPosition;
  final Function onTap;

  MapTypeFab({
    this.bottomPosition = 10.0,
    this.rightPosition = -15.0,
    this.onTap,
  });

  @override
  _MapTypeFabState createState() => _MapTypeFabState();
}

class _MapTypeFabState extends State<MapTypeFab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return _buildMapTypeFab();
  }

  Widget _buildMapTypeFab() {
    return Positioned(
      bottom: widget.bottomPosition,
      right: widget.rightPosition,
      child: Tooltip(
        preferBelow: false,
        message: 'Map Types',
        child: RawMaterialButton(
          fillColor: AppTheme.primary,
          shape: CircleBorder(),
          padding: const EdgeInsets.all(6.0),
          elevation: 1.0,
          child: Icon(
            Icons.map,
            color: Colors.white,
            size: 20.0,
          ),
          onPressed: (widget.onTap == null) ? null : widget.onTap,
        ),
      ),
    );
  }
}
