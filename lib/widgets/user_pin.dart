import 'package:flutter/scheduler.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/avatar_glow.dart';
import 'package:flutter_tracker/widgets/battery.dart';
import 'package:flutter_tracker/widgets/groups_member_charge_battery.dart';
import 'package:flutter_tracker/widgets/groups_member_location_accuracy.dart';
import 'package:flutter_tracker/widgets/groups_member_location_sharing.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/widgets/user_image.dart';

class UserPinGlow {
  Color color;
  Color innerColor;
  Color outerColor;
  bool active;

  UserPinGlow({
    Key key,
    this.color,
    this.innerColor,
    this.outerColor,
    this.active,
  });
}

class UserPin extends StatefulWidget {
  final GroupMember member;
  final double size;
  final double offset;
  final double actionPathSize;
  final double elevation;
  final double borderWidth;
  final Color color;
  final bool showDot;
  final bool showLocationSharingNotification;
  final bool showLocationAccuracyNotification;
  final bool forceOnline;
  final UserPinGlow glow;
  final GestureTapCallback onTap;
  final UserPinState userPinState = UserPinState();

  UserPin({
    Key key,
    this.member,
    this.size = 80.0,
    this.offset = 25.0,
    this.actionPathSize = 85.0,
    this.elevation = 2.0,
    this.borderWidth = 3.0,
    this.color = Colors.white,
    this.showDot = false,
    this.showLocationSharingNotification = true,
    this.showLocationAccuracyNotification = true,
    this.forceOnline = false,
    this.glow,
    this.onTap,
  }) : super(key: key);

  @override
  UserPinState createState() => userPinState;

  void addAction(Widget action) {
    if (userPinState._actions != null) {
      userPinState._actions..add(userPinState._buildActionButton(action));
    }
  }
}

class UserPinState extends State<UserPin> {
  List<Widget> _actions = <Widget>[];
  Map<int, List<List<double>>> _positions = Map<int, List<List<double>>>();

  @override
  void initState() {
    super.initState();

    // It's ugly but im awful at math
    _positions[1] = [
      [0.0, 0.0]
    ];

    _positions[2] = [
      [335.0, 25.0],
      [25.0, 335.0]
    ];

    _positions[3] = [
      [315.0, 45.0],
      [0.0, 0.0],
      [45.0, 315.0]
    ];

    // Add initial common actions
    SchedulerBinding.instance.addPostFrameCallback((_) => _addCommonActions());
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (widget.glow != null) {
      double glowPosition = -(widget.size / 2.0) + (widget.offset / 2.0);

      return Stack(
        overflow: Overflow.visible,
        children: [
          Positioned(
            bottom: glowPosition,
            left: glowPosition,
            child: Container(
              child: AvatarGlow(
                innerGlowColor: (widget.glow.innerColor == null)
                    ? widget.glow.color
                    : widget.glow.innerColor,
                outerGlowColor: (widget.glow.outerColor == null)
                    ? widget.glow.color
                    : widget.glow.outerColor,
                child: Container(),
              ),
            ),
          ),
          Container(
            child: _buildContainer(),
          ),
        ],
      );
    }

    return _buildContainer();
  }

  Widget _buildContainer() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        _buildMarker(),
        Container(
          width: widget.actionPathSize,
          height: widget.actionPathSize,
          child: Stack(
            children: _positionActions(_actions),
          ),
        ),
      ],
    );
  }

  Widget _buildMarker() {
    List<Widget> children = <Widget>[
      _blurShadow(),
      _pinShadow(),
      _pinDot(),
      _pin(),
      _profileAvatar(),
    ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: AlignmentDirectional.center,
        overflow: Overflow.visible,
        children: filterNullWidgets(children),
      ),
    );
  }

  Widget _blurShadow() {
    double size = (widget.size * (3.0 / 4.0));

    return Positioned(
      top: 10.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.size)),
          boxShadow: [
            const BoxShadow(
              color: Colors.black38,
              blurRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin() {
    return Container(
      height: (widget.size - 6.0),
      // color: Colors.red.withOpacity(0.7),
      child: Icon(
        Icons.person_pin,
        color: widget.color,
        size: widget.size,
      ),
    );
  }

  Widget _pinShadow() {
    return Positioned(
      top: 2.0,
      child: Icon(
        Icons.person_pin,
        color: Colors.black12,
        size: widget.size,
      ),
    );
  }

  Widget _profileAvatar() {
    double radius = (widget.size / 2.0);
    double calculatedRadius = (radius - (radius * (1.0 / 3.0)));
    bool online = widget.forceOnline || isOnline(widget.member);

    return Positioned(
      top: (radius * (1.0 / 4.0)),
      left: 0.0,
      right: 0.0,
      child: UserImage(
        name: getGroupMemberName(widget.member),
        imageUrl: buildAvatarUrl(
          member: widget.member,
          size: (calculatedRadius * 4.0)
              .toInt(), // For the cloudinary transformation
          online: online,
        ),
        radius: calculatedRadius,
        isOnline: online,
      ),
    );
  }

  void _addCommonActions() {
    if (widget.showLocationSharingNotification &&
        !locationSharingEnabled(widget.member)) {
      _actions
        ..add(
          GroupsMemberLocationSharing(
            member: widget.member,
            child: _buildActionButton(
              Icon(
                Icons.error,
                color: Colors.redAccent[700],
                size: 12.0,
              ),
            ),
          ),
        );
    }

    if (needsToChargeBattery(widget.member)) {
      _actions
        ..add(
          GroupsMemberChargeBattery(
            member: widget.member,
            child: _buildActionButton(
              Battery(
                battery: widget.member.battery, // Member battery level
                size: 6.0,
                iconOnly: true,
              ),
            ),
          ),
        );
    }

    if (widget.showLocationAccuracyNotification &&
        isOnline(widget.member) &&
        !wifiConnected(widget.member)) {
      _actions
        ..add(
          GroupsMemberLocationAccuracy(
            member: widget.member,
            child: _buildActionButton(
              Icon(
                Icons.signal_wifi_off,
                color: AppTheme.primary,
                size: 12.0,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildActionButton(
    Widget child, {
    final GestureTapCallback onTap,
  }) {
    Widget avatar = Container(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 8.0,
        child: child,
      ),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: commonBoxShadow(),
      ),
    );

    if (onTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }

  List<Widget> _positionActions(
    List<Widget> actions,
  ) {
    List<Widget> positionedActions = <Widget>[];
    int count = 0;

    actions.forEach((action) {
      positionedActions
        ..add(Transform.rotate(
          angle: radians(_positions[actions.length][count][0]),
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.rotate(
              angle: radians(_positions[actions.length][count][1]),
              child: actions[count],
            ),
          ),
        ));

      count++;
    });

    return positionedActions;
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
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
          )
        : null;
  }
}
