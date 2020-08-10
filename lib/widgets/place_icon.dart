import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

class PlaceIcon extends StatefulWidget {
  final List<Place> places;
  final Place place;
  final bool showUsed;
  final double iconSize;
  final double radius;

  PlaceIcon({
    Key key,
    this.places,
    this.place,
    this.showUsed = false,
    this.iconSize: 22.0,
    this.radius: 20.0,
  }) : super(key: key);

  @override
  State createState() => PlaceIconState();
}

class PlaceIconState extends State<PlaceIcon> with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    double size = (widget.radius * 2.0);

    return Container(
      width: size,
      height: size,
      child: _buildLocationIcon(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(widget.radius),
        ),
        boxShadow: commonBoxShadow(),
      ),
    );
  }

  Widget _buildLocationIcon() {
    if (widget.showUsed &&
        (widget.places != null) &&
        hasPlace(widget.places, widget.place)) {
      return Icon(
        Icons.check,
        color: AppTheme.secondary,
        size: widget.iconSize,
      );
    }

    return Icon(
      Icons.location_on,
      color: AppTheme.primary,
      size: widget.iconSize,
    );
  }
}
