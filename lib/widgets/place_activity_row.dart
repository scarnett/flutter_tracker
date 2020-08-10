import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';

class PlaceActivityRow extends StatefulWidget {
  final PlaceActivity activity;
  final Function tap;

  PlaceActivityRow({
    this.activity,
    this.tap,
  });

  @override
  State createState() => PlaceActivityRowState();
}

class PlaceActivityRowState extends State<PlaceActivityRow> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => Container(
        child: Material(
          child: InkWell(
            onTap: widget.tap,
            child: Column(
              children: [
                _buildActivityInfo(viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityInfo(
    GroupsViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: UserAvatar(
            user: widget.activity.user,
            imageUrl: widget.activity.user.imageUrl,
            avatarRadius: 24.0,
          ),
        ),
        Expanded(
          child: _buildActivityLines(viewModel),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: _buildActivityIcon(),
        ),
      ],
    );
  }

  Widget _buildActivityIcon() {
    return Container(
      child: Icon(
        getEventIcon(widget.activity.type),
        color: AppTheme.primary,
        size: 16.0,
      ),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: commonBoxShadow(),
      ),
    );
  }

  Widget _buildActivityLines(
    GroupsViewModel viewModel,
  ) {
    List<Widget> lines = List<Widget>();
    lines
      ..add(
        Text(
          getGroupMemberName(widget.activity.user, viewModel: viewModel),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      )
      ..add(
        Text(
          getEventText(widget.activity.type),
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      )
      ..add(
        Text(
          formatTimestamp(widget.activity.created, 'hh:mm a'),
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black38,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: lines,
    );
  }
}
