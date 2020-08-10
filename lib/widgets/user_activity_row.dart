import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/activity_icon.dart';
import 'package:flutter_tracker/widgets/activity_map.dart';
import 'package:flutter_tracker/widgets/groups_member_avatar.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/place_icon.dart';

class UserActivityRow extends StatefulWidget {
  final UserActivity activity;
  final Function tap;

  UserActivityRow({
    this.activity,
    this.tap,
  });

  @override
  State createState() => UserActivityRowState();
}

class UserActivityRowState extends State<UserActivityRow> {
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
            child: Container(
              color: Colors.white,
              child: _buildBody(viewModel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    GroupsViewModel viewModel,
  ) {
    switch (widget.activity.type) {
      case ActivityType.IN_VEHICLE:
        return _buildDrive(viewModel);
        break;

      case ActivityType.CHECKIN_SENDER:
        return _buildCheckinSender(viewModel);
        break;

      case ActivityType.CHECKIN_RECEIVER:
        return _buildCheckinReceiver(viewModel);
        break;

      default:
        return Container();
    }
  }

  Widget _buildCheckinSender(
    GroupsViewModel viewModel,
  ) {
    dynamic activityData = widget.activity.data;
    if ((activityData == null) || (activityData['to'] == null)) {
      return Container();
    }

    dynamic toUser = activityData['to'];
    GroupMember toMember = GroupMember.fromJson(toUser['uid'], toUser);
    return _buildCheckinRow(
      viewModel,
      viewModel.activeGroupMember,
      toMember,
    );
  }

  Widget _buildCheckinReceiver(
    GroupsViewModel viewModel,
  ) {
    dynamic activityData = widget.activity.data;
    if ((activityData == null) || (activityData['from'] == null)) {
      return Container();
    }

    dynamic fromUser = activityData['from'];
    GroupMember fromMember = GroupMember.fromJson(fromUser['uid'], fromUser);
    return _buildCheckinRow(
      viewModel,
      fromMember,
      viewModel.activeGroupMember,
    );
  }

  Widget _buildDrive(
    GroupsViewModel viewModel,
  ) {
    List<Widget> children = []
      ..addAll(_buildTripActivity(viewModel))
      ..add(_buildTripInfo());

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4.0,
            color: AppTheme.primary,
          ),
        ),
      ),
      child: Column(
        children: filterNullWidgets(children),
      ),
    );
  }

  Widget _buildCheckinRow(
    GroupsViewModel viewModel,
    GroupMember member1,
    GroupMember member2,
  ) {
    String text = getGroupMemberName(member1, viewModel: viewModel);
    text += ' checked in with ';
    text += getGroupMemberName(member2, viewModel: viewModel);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4.0,
            color: AppTheme.primary,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GroupMemberAvatar(
                member: member1,
                avatarRadius: 20.0,
                showBattery: false,
                online: true,
                icon: Icon(
                  Icons.arrow_right,
                  color: AppTheme.secondary,
                  size: 12.0,
                ),
              ),
            ),
            _buildTextLines(text, widget.activity.startTime),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: GroupMemberAvatar(
                member: member2,
                avatarRadius: 20.0,
                showBattery: false,
                online: true,
                icon: Icon(
                  Icons.check,
                  color: AppTheme.primary,
                  size: 12.0,
                ),
                iconPosition: IconPosition.LEFT,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfo() {
    if (widget.activity.active) {
      return null;
    }

    return Material(
      child: InkWell(
        onTap: () => _tapActiveGroupMemberActivityDetails(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _buildTripIcon(),
                  ),
                  _buildTripLines(),
                ],
              ),
            ),
            _buildMap(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripIcon() {
    return ActivityIcon(
      icon: getActivityIcon(widget.activity.type),
    );
  }

  Widget _buildTripLines() {
    String distanceText;

    if ((widget.activity.meta != null) &&
        widget.activity.meta.containsKey('distance')) {
      distanceText =
          activityDistanceText(widget.activity.meta['distance']); // TODO: uom
    }

    String timeTime =
        activityTimeText(widget.activity.startTime, widget.activity.endTime);

    List<Widget> lines = List<Widget>();

    if (distanceText != null) {
      lines
        ..add(
          Text(
            distanceText,
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
    }

    if (timeTime != null) {
      lines
        ..add(
          Text(
            timeTime,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppTheme.hint,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
    }

    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lines,
      ),
    );
  }

  Widget _buildMap() {
    if (widget.activity.active) {
      return null;
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ActivityMap(
        maxHeight: 240.0,
        routePoints: widget.activity.data,
      ),
    );
  }

  List<Widget> _buildTripActivity(
    GroupsViewModel viewModel,
  ) {
    List<Widget> lines = List<Widget>();

    if (widget.activity.startTime != null) {
      List<Widget> children = List<Widget>();

      if (widget.activity.events != null) {
        children..addAll(_buildEvents(viewModel));
      }

      lines
        ..add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: children,
          ),
        );
    }

    return lines;
  }

  Widget _buildDrivingStarted(
    GroupsViewModel viewModel,
    UserActivityEvent event,
  ) {
    GroupMember member;
    dynamic memberData = event.data['from'];
    if (memberData != null) {
      member = GroupMember.fromJson(memberData['uid'], memberData);
    }

    String text = getGroupMemberName(member, viewModel: viewModel);
    text += ' started driving'; // TODO: driving, running, walking, etc...

    return InkWell(
      onTap: () => _tapActiveGroupMemberActivityEventDetails(event),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10.0,
          left: 10.0,
          top: 10.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ActivityIcon(icon: Icons.play_arrow),
            ),
            _buildTextLines(
              text,
              event.created,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrivingStopped(
    GroupsViewModel viewModel,
    UserActivityEvent event,
  ) {
    GroupMember member;
    dynamic memberData = event.data['from'];
    if (memberData != null) {
      member = GroupMember.fromJson(memberData['uid'], memberData);
    }

    String text = getGroupMemberName(member, viewModel: viewModel);
    text += ' stopped driving'; // TODO: driving, running, walking, etc...

    return InkWell(
      onTap: () => _tapActiveGroupMemberActivityEventDetails(event),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10.0,
          left: 10.0,
          top: 10.0,
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ActivityIcon(icon: Icons.stop),
            ),
            _buildTextLines(
              text,
              event.created,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEvents(
    GroupsViewModel viewModel,
  ) {
    List<Widget> events = List<Widget>();

    widget.activity.events.forEach((UserActivityEvent event) {
      Widget eventWidget;

      switch (event.type) {
        case ActivityEventType.DRIVING_STARTED:
          eventWidget = _buildDrivingStarted(viewModel, event);
          break;

        case ActivityEventType.DRIVING_STOPPED:
          eventWidget = _buildDrivingStopped(viewModel, event);
          break;

        case ActivityEventType.GEOFENCE_ENTERING:
          eventWidget = _buildGeofenceEntering(viewModel, event);
          break;

        case ActivityEventType.GEOFENCE_LEAVING:
          eventWidget = _buildGeofenceLeaving(viewModel, event);
          break;

        default:
          break;
      }

      if (eventWidget != null) {
        events..add(eventWidget);
        events..add(ListDivider());
      }
    });

    return events;
  }

  Widget _buildGeofenceRow(
    GroupsViewModel viewModel,
    Place place,
    GroupMember member,
    UserActivityEvent event,
  ) {
    String text = getGroupMemberName(member, viewModel: viewModel);

    if (event.type == ActivityEventType.GEOFENCE_ENTERING) {
      text += ' arrived at';
    } else if ((event.type == ActivityEventType.GEOFENCE_LEAVING)) {
      text += ' departed';
    }

    text += ' ${place.name}';

    return InkWell(
      onTap: () => _tapActiveGroupMemberActivityEventDetails(event),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: PlaceIcon(),
            ),
            _buildTextLines(
              text,
              event.created,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceEntering(
    GroupsViewModel viewModel,
    UserActivityEvent event,
  ) {
    dynamic eventData = event.data;
    if ((eventData == null) || (eventData['place'] == null)) {
      return null;
    }

    GroupMember member;
    dynamic memberData = eventData['from'];
    if (memberData != null) {
      member = GroupMember.fromJson(memberData['uid'], memberData);
    }

    dynamic placeData = eventData['place'];
    Place place = Place.fromJson(placeData);

    return _buildGeofenceRow(
      viewModel,
      place,
      member,
      event,
    );
  }

  Widget _buildGeofenceLeaving(
    GroupsViewModel viewModel,
    UserActivityEvent event,
  ) {
    dynamic eventData = event.data;
    if ((eventData == null) || (eventData['place'] == null)) {
      return null;
    }

    GroupMember member;
    dynamic memberData = eventData['from'];
    if (memberData != null) {
      member = GroupMember.fromJson(memberData['uid'], memberData);
    }

    dynamic placeData = eventData['place'];
    Place place = Place.fromJson(placeData);

    return _buildGeofenceRow(
      viewModel,
      place,
      member,
      event,
    );
  }

  Widget _buildTextLines(
    String text,
    Timestamp timestamp,
  ) {
    List<Widget> lines = List<Widget>();

    lines
      ..add(
        Text(
          text,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      )
      ..add(
        Text(
          formatTimestamp(timestamp, 'hh:mm a'),
          style: const TextStyle(
            fontSize: 12.0,
            color: AppTheme.hint,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lines,
      ),
    );
  }

  void _tapActiveGroupMemberActivityDetails() {
    StoreProvider.of<AppState>(context).dispatch(NavigatePushAction(
      AppRoutes.activityMap,
      arguments: {
        'activity': widget.activity,
      },
    ));
  }

  void _tapActiveGroupMemberActivityEventDetails(
    UserActivityEvent event,
  ) {
    StoreProvider.of<AppState>(context).dispatch(NavigatePushAction(
      AppRoutes.activityMap,
      arguments: {
        'event': event,
      },
    ));
  }
}
