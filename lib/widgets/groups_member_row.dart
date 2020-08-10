import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/groups_member_avatar.dart';
import 'package:flutter_tracker/widgets/list_show_more.dart';

class GroupsMemberRow extends StatefulWidget {
  final User user;
  final GroupMember member;
  final Function tap;

  GroupsMemberRow({
    this.user,
    this.member,
    this.tap,
  });

  @override
  State createState() => GroupsMemberRowState();
}

class GroupsMemberRowState extends State<GroupsMemberRow>
    with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => Container(
        color: Colors.white,
        child: Material(
          child: InkWell(
            onTap: widget.tap,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
                top: 10.0,
                left: 10.0,
                right: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: Wrap(
                        direction: Axis.vertical,
                        children: [
                          Row(
                            children: <Widget>[
                              GroupMemberAvatar(member: widget.member),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: _buildUserInfo(viewModel),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListShowMore(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserInfo(
    GroupsViewModel viewModel,
  ) {
    bool isOnlineAndSharing = isOnlineAndSharingLocation(widget.member);
    List<Widget> widgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getGroupMemberName(widget.member, viewModel: viewModel),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.0,
              color: isOnlineAndSharing ? Colors.black : AppTheme.hint,
              fontWeight: FontWeight.w400,
            ),
          ),
          _buildActivityIcon(widget.member),
          _buildConnectionIcon(widget.member),
          _buildLocationSharingIcon(),
        ],
      ),
    ];

    String location = _getLocationString(widget.member);
    if (location != null) {
      widgets
        ..add(
          Text(
            location,
            style: TextStyle(
              fontSize: 12.0,
              color: isOnlineAndSharing ? Colors.black : AppTheme.hint,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
    }

    if (!isOnline(widget.member) && (widget.member.location != null)) {
      DateTime lastUpdated = widget.member.lastUpdated.toDate();

      widgets
        ..add(
          Text(
            'Last seen ${formatDateTime(lastUpdated, getDateFormat(lastUpdated))}',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      // Member location
    } else if (widget.member.lastUpdated != null) {
      String lastUpdatedStr;

      if (widget.member.place == null) {
        DateTime lastUpdated = widget.member.lastUpdated.toDate();
        lastUpdatedStr =
            'Last updated ${formatDateTime(lastUpdated, getDateFormat(lastUpdated))}';
      } else if (widget.member.place.lastUpdated != null) {
        DateTime lastUpdated = widget.member.place.lastUpdated.toDate();
        lastUpdatedStr =
            'Since ${formatDateTime(lastUpdated, getDateFormat(lastUpdated))}';
      }

      if (lastUpdatedStr != null) {
        widgets
          ..add(
            Text(
              lastUpdatedStr,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black38,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
      }
    }

    return widgets;
  }

  Widget _buildActivityIcon(
    GroupMember member,
  ) {
    if ((member != null) && (member.location != null)) {
      bool moving = ActivityType.isMoving(member.location.activity.type);
      if (moving) {
        return Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Icon(
            getActivityIcon(member.location.activity.type),
            color: AppTheme.background(),
            size: 14.0,
          ),
        );
      }
    }

    return Container();
  }

  Widget _buildConnectionIcon(
    GroupMember member,
  ) {
    if (!isOnline(member) || wifiConnected(member)) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: const Icon(
        Icons.signal_wifi_off, // Wifi indicator
        color: AppTheme.primary,
        size: 14.0,
      ),
    );
  }

  Widget _buildLocationSharingIcon() {
    if (locationSharingEnabled(widget.member)) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Icon(
        Icons.error, // Location sharing off indicator
        color: Colors.redAccent[700],
        size: 14.0,
      ),
    );
  }

  String _getLocationString(
    GroupMember member,
  ) {
    if (!locationSharingEnabled(member)) {
      return 'Location sharing paused';
    }

    if (isOnline(member)) {
      if (member.place != null) {
        return 'At ${member.place.name}';
      }

      String activityType = ActivityType.toText(member.location.activity.type);
      if (activityType != null) {
        return activityType;
      }

      return null;
    }

    return 'No network or phone off';
  }
}
