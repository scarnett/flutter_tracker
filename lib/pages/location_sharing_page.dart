import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';

class LocationSharingPage extends StatefulWidget {
  LocationSharingPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationSharingPageState();
}

class _LocationSharingPageState extends State<LocationSharingPage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Location Sharing',
              style: TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Location Sharing Status'));

    tiles
      ..add(
        ListTile(
          title: Text(
            viewModel.user.name,
            style: TextStyle(fontSize: 16.0),
          ),
          leading: (viewModel.user.image == null)
              ? Container()
              : UserAvatar(
                  user: viewModel.user,
                  imageUrl: viewModel.user.image.secureUrl,
                  avatarRadius: 24.0,
                ),
          trailing: _buildMemberToggle(viewModel, viewModel.user),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        ),
      );

    if (viewModel.activeGroup.members != null) {
      tiles..add(SectionHeader(text: 'Group Members'));

      int size = viewModel.activeGroup.members.length;
      int count = 0;

      viewModel.activeGroup.members
          // Dont show current user in the group member list
          .where((member) => member.uid != viewModel.user.documentId)
          .forEach((member) {
        tiles
          ..add(
            ListTile(
              title: Text(
                getGroupMemberName(member, viewModel: viewModel),
                style: TextStyle(fontSize: 16.0),
              ),
              subtitle: (viewModel.activeGroup.owner.uid == member.uid)
                  ? Text(
                      'Owner',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 12.0,
                      ),
                    )
                  : null,
              leading: UserAvatar(
                user: member,
                imageUrl: member.imageUrl,
                avatarRadius: 24.0,
              ),
              trailing: _buildMemberStatus(viewModel, member),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical:
                    (viewModel.activeGroup.owner.uid == member.uid) ? 0.0 : 5.0,
              ),
            ),
          );

        if (count < size) {
          tiles..add(ListDivider());
        }

        count++;
      });
    }

    return Container(
      child: Material(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: tiles,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberToggle(
    GroupsViewModel viewModel,
    User user,
  ) {
    if (viewModel.user.documentId == user.documentId) {
      return Switch(
        onChanged: (value) => _onSwitchChanged(value, viewModel),
        value: _isToggled(viewModel),
        activeColor: AppTheme.primary,
        activeTrackColor: AppTheme.inactive(),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: AppTheme.inactive(),
      );
    }

    return null;
  }

  Widget _buildMemberStatus(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    List<Widget> statusList = [];
    statusList
      ..add(
        Text(
          member.hasLocationSharingEnabled() ? 'Enabled' : 'Disabled',
          style: TextStyle(
            color: member.hasLocationSharingEnabled()
                ? Colors.greenAccent[700]
                : Colors.redAccent[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      );

    if (!locationSharingEnabled(member) &&
        (member.locationSharing.sharingDisabled != null)) {
      DateTime date = member.locationSharing.sharingDisabled.toDate();

      statusList
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              formatDateTime(
                date,
                getDateFormat(date),
              ),
              style: TextStyle(
                color: Colors.black.withOpacity(0.2),
                fontSize: 12.0,
              ),
            ),
          ),
        );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: statusList,
    );
  }

  void _onSwitchChanged(
    bool value,
    GroupsViewModel viewModel,
  ) async {
    final store = StoreProvider.of<AppState>(context);
    Map<String, dynamic> data = {
      viewModel.user.documentId: {
        'location_sharing': {
          'status': value,
          'sharing_disabled': value ? null : getNow(),
        },
      },
    };

    if (value) {
      await checkLocationPermissionStatus(store, context);
    } else {
      store.dispatch(
        UpdateGroupMemberLocationSharingAction(
            viewModel.activeGroup.documentId, data),
      );
    }
  }

  bool _isToggled(
    GroupsViewModel viewModel,
  ) {
    GroupMember member = viewModel.activeGroup.members
        .firstWhere((member) => member.uid == viewModel.user.documentId);
    if (member == null) {
      return false;
    }

    return (member.locationSharing == null)
        ? false
        : member.locationSharing.status;
  }
}
