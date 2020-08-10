import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class GroupsAdministratorsPage extends StatefulWidget {
  GroupsAdministratorsPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsAdministratorsPageState();
}

class _GroupsAdministratorsPageState extends State<GroupsAdministratorsPage> {
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
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              'Administrators',
              style: const TextStyle(fontSize: 18.0),
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
    int size = viewModel.activeGroup.members.length;
    int count = 0;
    List<Widget> tiles = [];

    if (viewModel.activeGroup.members != null) {
      viewModel.activeGroup.members.forEach((member) {
        tiles
          ..add(
            ListTile(
              title: Text(
                getGroupMemberName(member, viewModel: viewModel),
                style: const TextStyle(fontSize: 16.0),
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
              trailing: _buildToggle(viewModel, member),
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

  Widget _buildToggle(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    if (isAdministrator(viewModel.activeGroup, viewModel.user)) {
      bool canChange = (viewModel.activeGroup.owner.uid != member.uid);

      return Opacity(
        opacity: canChange ? 1.0 : 0.3,
        child: Switch(
          onChanged: canChange
              ? (value) => _onSwitchChanged(value, viewModel, member)
              : null,
          value: _isToggled(viewModel.activeGroup, member),
          activeColor: AppTheme.primary,
          activeTrackColor: AppTheme.inactive(),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppTheme.inactive(),
        ),
      );
    }

    return null;
  }

  void _onSwitchChanged(
    bool value,
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    final store = StoreProvider.of<AppState>(context);
    List<dynamic> admins = viewModel.activeGroup.admins.toList();
    if (admins == null) {
      admins = List<dynamic>();
      admins..add(member.uid);
    } else {
      if (admins.contains(member.uid)) {
        admins.remove(member.uid);

        // If the user is removing themselves from the admins then pop the navgation
        if (member.uid == viewModel.user.documentId) {
          Navigator.popUntil(
              context, ModalRoute.withName(AppRoutes.groupsManagement.name));
        }
      } else {
        admins..add(member.uid);
      }
    }

    store.dispatch(SaveGroupAdministratorsAction(
        viewModel.activeGroup.documentId, admins));
  }

  bool _isToggled(
    Group group,
    GroupMember member,
  ) {
    if (group.admins == null) {
      return false;
    }

    return group.admins.contains(member.uid);
  }
}
