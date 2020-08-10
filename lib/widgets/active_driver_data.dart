import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

class ActiveDriverData extends StatefulWidget {
  final GroupMember member;
  final Location location;

  ActiveDriverData({
    this.member,
    this.location,
  });

  @override
  State createState() => ActiveDriverDataState();
}

class ActiveDriverDataState extends State<ActiveDriverData> {
  @override
  Widget build(
    BuildContext context,
  ) {
    Location location = _getLocation();
    if (location == null) {
      return Container();
    }

    bool driving = ActivityType.isDriving(location.activity.type);
    if (!driving) {
      return Container();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
        left: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.all(
            const Radius.circular(4.0),
          ),
          boxShadow: commonBoxShadow(blurRadius: 2.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 60.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.all(
                const Radius.circular(4.0),
              ),
              border: Border.all(
                color: AppTheme.background(),
                width: 2.0,
              ),
            ),
            padding: EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  getSpeed(
                    location,
                    lastUpdated: widget.member?.lastUpdated,
                  ).toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36.0,
                    height: 1.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    getSpeedText(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.0,
                      height: 1.0,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.inactive(),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 6.0,
                    bottom: 6.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildHeading(location),
                      _getDirection(location),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
   * This generates the blue arrow on the widget.
   * 
   * The logic below takes the heading of the device running the app and rotate the arrow
   * according to its orientation. It also takes the heading of the group member and combines these
   * to rotate the arrow according to the two heading.
   */
  Widget _buildHeading(
    Location location,
  ) {
    return StreamBuilder<double>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        // The heading of the device
        // double deviceHeading = snapshot.data;

        // This material icon is at a 45deg angle by default. Lets set it to 0deg.
        double groupMemberHeading = (location.coords.heading + -45.0);

        /*
        return Transform.rotate(
          angle: ((deviceHeading ?? 0) * (math.pi / 180) * -1),
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(groupMemberHeading / 360.0),
            child: Icon(
              Icons.near_me,
              color: AppTheme.secondary,
              size: 20.0,
            ),
          ),
        );
        */

        return RotationTransition(
          turns: AlwaysStoppedAnimation(groupMemberHeading / 360.0),
          child: Icon(
            Icons.near_me,
            color: AppTheme.secondary,
            size: 20.0,
          ),
        );
      },
    );
  }

  Widget _getDirection(
    Location location,
  ) {
    List<String> directions = [
      'N',
      'NW',
      'W',
      'SW',
      'S',
      'SE',
      'E',
      'NE',
    ];

    double heading = location.coords.heading.toDouble();
    double calc =
        ((((heading %= 360.0) < 0 ? heading + 360.0 : heading) / 45.0) % 8.0);
    return Padding(
      padding: EdgeInsets.only(
        top: 4.0,
      ),
      child: Text(
        directions[calc.round()],
        style: TextStyle(
          fontSize: 10.0,
          height: 1.0,
          color: AppTheme.hint,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Location _getLocation() {
    if (widget.member != null) {
      return widget.member.location;
    }

    return widget.location;
  }
}
