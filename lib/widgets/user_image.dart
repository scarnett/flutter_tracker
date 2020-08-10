import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/user_utils.dart';

class UserImage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final double radius;
  final Color color;
  final bool isOnline;

  UserImage({
    this.name,
    this.imageUrl,
    this.radius: 28.0,
    this.color: AppTheme.primary,
    this.isOnline: true,
  });

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: (widget.radius * 2.0),
      height: (widget.radius * 2.0),
      child: _profileAvatar(),
    );
  }

  Widget _profileAvatar() {
    return (widget.imageUrl != null)
        ? _profileImage(widget.radius)
        : _profileInitials(widget.radius);
  }

  Widget _profileInitials(
    double radius,
  ) {
    return CircleAvatar(
      backgroundColor: widget.isOnline ? widget.color : AppTheme.hint,
      child: Text(
        getUserInitials(widget.name),
        style: TextStyle(
          fontSize: (radius / 1.1),
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: (radius / -10.0),
        ),
      ),
      radius: radius,
    );
  }

  Widget _profileImage(
    double radius,
  ) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: radius,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
