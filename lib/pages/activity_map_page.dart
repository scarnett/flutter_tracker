import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/widgets/activity_map.dart';
import 'package:flutter_tracker/widgets/map_type_fab.dart';
import 'package:redux/redux.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class ActivityMapPage extends StatefulWidget {
  final Store store;

  ActivityMapPage({
    Key key,
    this.store,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ActivityMapPageState();
}

class _ActivityMapPageState extends State<ActivityMapPage> {
  UserActivity activityData;
  UserActivityEvent eventData;

  @override
  Widget build(
    BuildContext context,
  ) {
    final dynamic args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      if (args.containsKey('activity')) {
        activityData = args['activity'];
      }

      if (args.containsKey('event')) {
        eventData = args['event'];
      }
    }

    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          final store = StoreProvider.of<AppState>(context);
          store.dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: true,
          appBar: _buildBar(context, viewModel),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    return AppBar(
      title: Text(
        'Activity Map',
        style: const TextStyle(fontSize: 18.0),
      ),
      titleSpacing: 0.0,
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    ActivityMap _map = _buildMap(viewModel);
    if (_map == null) {
      return Container();
    }

    return Container(
      child: Material(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  _map,
                  MapTypeFab(
                    onTap: () => widget.store
                        .dispatch(NavigatePushAction(AppRoutes.mapType)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ActivityMap _buildMap(
    GroupsViewModel viewModel,
  ) {
    if (activityData != null) {
      switch (activityData.type) {
        case ActivityType.CHECKIN_SENDER:
        case ActivityType.CHECKIN_RECEIVER:
          dynamic data = activityData.data;
          dynamic fromMember = data['from'];
          fromMember['name'] = getGroupMemberName(
            GroupMember.fromJson(fromMember['uid'], fromMember),
            viewModel: viewModel,
          );

          fromMember['icon'] = Icon(
            Icons.arrow_right,
            color: AppTheme.secondary,
            size: 12.0,
          );

          dynamic toMember = data['to'];
          toMember['name'] = getGroupMemberName(
            GroupMember.fromJson(toMember['uid'], toMember),
            viewModel: viewModel,
          );

          toMember['icon'] = Icon(
            Icons.check,
            color: AppTheme.primary,
            size: 12.0,
          );

          return ActivityMap(
            type: activityData.type,
            interactive: true,
            canRecenter: true,
            showHeading: true,
            members: [fromMember, toMember],
          );
          break;

        case ActivityType.IN_VEHICLE:
        default:
          return ActivityMap(
            type: activityData.type,
            interactive: true,
            canRecenter: true,
            showHeading: true,
            routePoints: activityData.data,
          );
          break;
      }
    } else if (eventData != null) {
      switch (eventData.type) {
        case ActivityEventType.DRIVING_STARTED:
        case ActivityEventType.DRIVING_STOPPED:
          dynamic fromMember = eventData.data['from'];
          fromMember['name'] = getGroupMemberName(
            GroupMember.fromJson(fromMember['uid'], fromMember),
            viewModel: viewModel,
          );

          return ActivityMap(
            type: eventData.type,
            interactive: true,
            canRecenter: true,
            showHeading: true,
            members: [fromMember],
            location: fromMember['location'],
          );
          break;

        case ActivityEventType.GEOFENCE_ENTERING:
        case ActivityEventType.GEOFENCE_LEAVING:
          dynamic data = eventData.data;
          dynamic fromMember = data['from'];
          fromMember['name'] = getGroupMemberName(
            GroupMember.fromJson(fromMember['uid'], fromMember),
            viewModel: viewModel,
          );

          return ActivityMap(
            type: eventData.type,
            interactive: true,
            canRecenter: true,
            showHeading: true,
            members: [fromMember],
            place: data['place'],
            location: fromMember['location'],
          );
          break;

        default:
          break;
      }
    }

    return null;
  }
}
