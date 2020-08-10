import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/clipper_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/user_image.dart';

class GroupsMemberCluster extends StatefulWidget {
  final List<GroupMember> members;
  final double size;
  final double avatarBorderSize;
  final bool showCrosshairs;
  final Icon icon;

  GroupsMemberCluster({
    Key key,
    this.members,
    this.size = 50.0,
    this.avatarBorderSize = 1.0,
    this.showCrosshairs = false,
    this.icon,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => GroupsMemberClusterState();
}

class GroupsMemberClusterState extends State<GroupsMemberCluster>
    with TickerProviderStateMixin {
  int max = 4;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> children = [];

    if (widget.members != null) {
      children..add(_buildContainer(widget.members));
    }

    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: filterNullWidgets(children),
      ),
    );
  }

  Widget _buildContainer(
    List<GroupMember> members,
  ) {
    int memberCount = widget.members.length;
    double iconSize = 6.0;
    List<Widget> children = List<Widget>();

    widget.members
        .forEach((member) => children..add(_buildAvatar(memberCount, member)));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.text(),
        boxShadow: commonBoxShadow(blurRadius: 2.0),
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: []
          ..add(_buildMemberContainer(children))
          ..add(_buildBorderOverlay())
          ..add(_buildMemberCount())
          ..addAll(_buildCrosshairs())
          ..add(
            _positionedIcon(
              Container(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: iconSize,
                  child: widget.icon,
                ),
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: commonBoxShadow(),
                ),
              ),
              size: iconSize,
            ),
          ),
      ),
    );
  }

  Widget _buildGroupMembers(
    List<Widget> children,
  ) {
    double regionSize = (widget.size / 2.0);

    if (children.length == 1) {
      return children[0];
    } else if (children.length == 2) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: regionSize,
                    height: regionSize,
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Positioned(
                          left: 2.0,
                          top: -2.0,
                          child: children[0],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: regionSize,
                    height: regionSize,
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Positioned(
                          right: 2.0,
                          top: -2.0,
                          child: children[1],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (children.length > 2) {
      List<Widget> children2 = List<Widget>();
      children2
        ..add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: regionSize,
                height: regionSize,
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      left: 2.0,
                      top: 2.0,
                      child: children[0],
                    ),
                  ],
                ),
              ),
              Container(
                width: regionSize,
                height: regionSize,
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      right: 2.0,
                      top: 2.0,
                      child: children[1],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      if (children.length == 3) {
        children2
          ..add(
            Container(
              width: regionSize,
              height: regionSize,
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  Positioned(
                    bottom: 1.0,
                    left: -2.0,
                    child: children[2],
                  ),
                ],
              ),
            ),
          );
      } else if (children.length == max) {
        children2
          ..add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: regionSize,
                  height: regionSize,
                  child: Stack(
                    overflow: Overflow.visible,
                    children: [
                      Positioned(
                        left: 2.0,
                        bottom: 2.0,
                        child: children[2],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: regionSize,
                  height: regionSize,
                  child: Stack(
                    overflow: Overflow.visible,
                    children: [
                      Positioned(
                        right: 2.0,
                        bottom: 2.0,
                        child: children[3],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      }

      return Container(
        child: Column(
          children: filterNullWidgets(children2),
        ),
      );
    }

    return Container();
  }

  Widget _buildMemberContainer(
    List<Widget> children,
  ) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        clipper: CircleClipper(radius: (widget.size / 2.0)),
        child: _buildGroupMembers(children),
      ),
    );
  }

  Widget _buildAvatar(
    int size,
    GroupMember member,
  ) {
    double radius = _getRadius(size);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: widget.avatarBorderSize,
        ),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 0.0,
            offset: const Offset(0.0, 1.0),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: UserImage(
        name: getGroupMemberName(member),
        imageUrl: buildAvatarUrl(
          member: member,
          size: (radius * 4.0).toInt(), // For the cloudinary transformation
        ),
        radius: radius,
        isOnline: isOnline(member),
      ),
    );
  }

  Widget _buildBorderOverlay() {
    return Center(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildMemberCount() {
    if ((widget.members == null) || (widget.members.length <= max)) {
      return Container();
    }

    double size = _getMemberCountSize();

    return Positioned(
      right: -(size / 2.0),
      top: 0.0,
      bottom: 0.0,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent,
            boxShadow: commonBoxShadow(blurRadius: 2.0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              widget.members.length.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getMemberCountFontSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCrosshairs() {
    if (widget.showCrosshairs) {
      return [
        Center(
          child: Container(
            color: Colors.black,
            width: 1.0,
            height: widget.size,
          ),
        ),
        Center(
          child: Container(
            color: Colors.black,
            width: widget.size,
            height: 1.0,
          ),
        ),
      ];
    }

    return [
      Container(),
    ];
  }

  Widget _positionedIcon(
    Widget icon, {
    double size = 6.0,
  }) {
    if (widget.icon == null) {
      return Container();
    }

    // TODO: RIGHT, TOP and BOTTOM
    return Positioned.fill(
      right: ((size + 2.0) * -1.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: icon,
      ),
    );
  }

  double _getRadius(
    int size,
  ) {
    if (size > max) {
      size = max;
    }

    double radius = (widget.size / size) + (size / 5.0);
    return radius;
  }

  double _getMemberCountSize() {
    return (widget.size / 3);
  }

  double _getMemberCountFontSize() {
    return (widget.size / 5);
  }
}
