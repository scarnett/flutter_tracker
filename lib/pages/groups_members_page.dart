import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/widgets/empty_state_message.dart';
import 'package:flutter_tracker/widgets/fab_list.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class GroupsMembersPage extends StatefulWidget {
  GroupsMembersPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsMembersPageState();
}

class _GroupsMembersPageState extends State<GroupsMembersPage> {
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
              'Members',
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
    Group group = viewModel.activeGroup;
    List<Widget> tiles = [];
    List<Widget> actionTiles = [];

    if ((group != null) && (group.members != null)) {
      List<GroupMember> filtered = filteredGroupMembers(group, viewModel.user);
      if ((filtered == null) || (filtered.length == 0)) {
        tiles
          ..add(EmptyStateMessage(
              message: 'Your group doesn\'t have any members yet!'));
        tiles..add(ListDivider());
      } else {
        filtered.forEach((member) {
          String text = _getMemberText(viewModel, member);

          tiles
            ..add(
              ListTile(
                title: Text(
                  getGroupMemberName(member, viewModel: viewModel),
                  style: const TextStyle(fontSize: 16.0),
                ),
                subtitle: (text != null)
                    ? Text(
                        text,
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
                // trailing: _buildDelete(viewModel, group, member),
                onTap: () => _tapGroupMember(member),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: (text != null) ? 0.0 : 5.0,
                ),
              ),
            );

          tiles..add(ListDivider());
        });
      }

      if (isAdministrator(viewModel.activeGroup, viewModel.user)) {
        actionTiles
          ..add(
            menuActionButton(
              'Add Member',
              Icons.add,
              AppTheme.primary,
              () => showInviteCode(
                context,
                groupId: viewModel.activeGroup.documentId,
              ),
            ),
          );
      }

      tiles..add(buildMenuActions(actionTiles));
    }

    return Container(
      child: Material(
        child: Column(
          children: [
            Expanded(
              child: FabList(
                tiles: tiles,
                tooltip: 'Add Member',
                onTap: () => showInviteCode(
                  context,
                  groupId: viewModel.activeGroup.documentId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMemberText(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    if (viewModel.activeGroup.owner.uid == member.uid) {
      return 'Owner';
    } else if (viewModel.activeGroup.admins.contains(member.uid)) {
      return 'Administrator';
    }

    return null;
  }

  void _tapGroupMember(
    GroupMember member,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ActivateGroupMemberAction(member.uid));
    store.dispatch(CancelUserActivityAction());
    store.dispatch(RequestUserActivityDataAction(member.uid));
    store.dispatch(NavigatePushAction(AppRoutes.groupMembersForm));
  }
}
