import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/user_image.dart';

class UserAvatar extends StatefulWidget {
  final dynamic user;
  final String imageUrl;
  final double avatarRadius;
  final bool canUpdate;
  final Function onTap;

  UserAvatar({
    @required this.user,
    @required this.imageUrl,
    this.avatarRadius: 28.0,
    this.canUpdate: false,
    this.onTap,
  });

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(
    BuildContext context,
  ) {
    double size = (widget.avatarRadius * 2.0);
    List<Widget> widgets = List<Widget>();

    if (widget.user != null) {
      widgets
        ..add(
          GestureDetector(
            onTap: (widget.onTap == null)
                ? widget.canUpdate ? () => _tapPhoto() : null
                : widget.onTap,
            child: Container(
              width: size,
              height: size,
              child: UserImage(
                name: getGroupMemberName(widget.user),
                imageUrl: cloudinaryTransformUrl(
                  widget.imageUrl,
                  extraOptions: [
                    'w_${size.toInt()}', // Adds the width transformation
                    'h_${size.toInt()}', // Adds the height transformation
                    'q_100', // Adds the quality (100%) transformation
                  ],
                ),
                radius: widget.avatarRadius,
                isOnline: isOnline(widget.user ?? null),
              ),
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.avatarRadius),
                ),
                boxShadow: commonBoxShadow(),
              ),
            ),
          ),
        );
    }

    if (widget.canUpdate) {
      widgets..add(_buildCameraButton());
    }

    return Stack(
      overflow: Overflow.visible,
      children: widgets,
    );
  }

  Widget _buildCameraButton() {
    return Positioned(
      bottom: -6.0,
      left: 0.0,
      right: 0.0,
      child: GestureDetector(
        onTap: () => _tapPhoto(),
        child: Container(
          child: Icon(
            Icons.camera_alt,
            color: AppTheme.primary,
            size: 18.0,
          ),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: commonBoxShadow(),
          ),
        ),
      ),
    );
  }

  void _tapPhoto() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.accountPhoto));
  }
}
