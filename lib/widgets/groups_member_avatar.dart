import 'package:flutter/material.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/battery.dart';
import 'package:flutter_tracker/widgets/user_image.dart';

enum IconPosition {
  LEFT,
  RIGHT,
  TOP,
  BOTTOM,
}

class GroupMemberAvatar extends StatefulWidget {
  final GroupMember member;
  final double avatarRadius;
  final bool showBattery;
  final bool showName;
  final bool online;
  final Icon icon;
  final IconPosition iconPosition;
  final GestureTapCallback onTap;

  GroupMemberAvatar({
    @required this.member,
    this.avatarRadius: 28.0,
    this.showBattery: true,
    this.showName: false,
    this.online: false,
    this.icon,
    this.iconPosition: IconPosition.RIGHT,
    this.onTap,
  });

  @override
  _GroupMemberAvatarState createState() => _GroupMemberAvatarState();
}

class _GroupMemberAvatarState extends State<GroupMemberAvatar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        widget.showName && (widget.member != null)
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 6.0,
                ),
                child: Text(
                  getGroupMemberName(widget.member),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )
            : Container(),
        Stack(
          overflow: Overflow.visible,
          children: _buildContent(),
        ),
      ],
    );
  }

  List<Widget> _buildContent() {
    List<Widget> widgets = []..add(
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            child: UserImage(
              name: getGroupMemberName(widget.member),
              imageUrl: buildAvatarUrl(
                member: widget.member,
                size: (widget.avatarRadius * 4.0)
                    .toInt(), // For the cloudinary transformation
                online: widget.online,
              ),
              radius: widget.avatarRadius,
              isOnline: isOnline(widget.member),
            ),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.avatarRadius)),
              boxShadow: commonBoxShadow(),
            ),
          ),
        ),
      );

    if (widget.icon != null) {
      double size = 6.0;
      widgets
        ..add(
          _positionedIcon(
            Container(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: size,
                child: widget.icon,
              ),
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: commonBoxShadow(),
              ),
            ),
            size: size,
          ),
        );
    } else if (widget.showBattery && isOnline(widget.member)) {
      double size = 6.0;
      widgets
        ..add(
          _positionedIcon(
            Battery(
              battery: widget.member.battery, // Member battery level
              size: size,
              compact: true,
            ),
            size: size,
          ),
        );
    }

    return widgets;
  }

  Widget _positionedIcon(
    Widget icon, {
    double size = 6.0,
  }) {
    switch (widget.iconPosition) {
      case IconPosition.LEFT:
        return Positioned.fill(
          left: ((size + 2.0) * -1.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: icon,
          ),
        );
        break;

      case IconPosition.RIGHT:
        return Positioned.fill(
          right: ((size + 2.0) * -1.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: icon,
          ),
        );
        break;

      // TODO: TOP and BOTTOM

      default:
        return Container();
        break;
    }
  }
}
