import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/colors.dart';

class PlacePin extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double elevation;
  final bool showDot;
  final GestureTapCallback onTap;

  PlacePin({
    Key key,
    this.icon = Icons.location_on,
    this.size = 30.0,
    this.color = AppTheme.primaryAccent,
    this.elevation = 1.0,
    this.showDot = false,
    this.onTap,
  }) : super(key: key);

  @override
  PlacePinState createState() => PlacePinState();
}

class PlacePinState extends State<PlacePin> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.center,
          overflow: Overflow.visible,
          children: <Widget>[
            _pinShadow(),
            _pinDot(),
            _pin(),
          ],
        ),
      ),
    );
  }

  Widget _pinShadow() {
    return Positioned(
      bottom: -2.0,
      child: Icon(
        widget.icon,
        color: Colors.black26,
        size: widget.size,
      ),
    );
  }

  Widget _pinDot() {
    const double _size = 8.0;

    return widget.showDot
        ? Positioned(
            bottom: -(_size / 2.0),
            child: Container(
              height: _size,
              width: _size,
              child: SizedBox(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.3),
              ),
            ),
          )
        : Container();
  }

  Widget _pin() {
    return Icon(
      widget.icon,
      color: widget.color,
      size: widget.size,
    );
  }
}
