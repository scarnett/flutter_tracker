import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/widgets/groups_member_avatar.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/widgets/groups_member_cluster.dart';

class GroupsMenuPage extends StatefulWidget {
  GroupsMenuPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsMenuPageState();
}

class _GroupsMenuPageState extends State<GroupsMenuPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        final store = StoreProvider.of<AppState>(context);

        return WillPopScope(
          onWillPop: () {
            store.dispatch(NavigatePopAction());
            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.primary,
              elevation: 0.0,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              titleSpacing: 0.0,
            ),
            // extendBody: true,
            body: Column(
              children: [
                _createHeader(viewModel),
                _createMemberList(viewModel),
                _createButtons(context, store),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _createHeader(
    GroupsViewModel viewModel,
  ) {
    List<GroupMember> drivingGroupMembers = filteredGroupMembers(
      viewModel.activeGroup,
      viewModel.user,
      types: [ActivityType.IN_VEHICLE],
    );

    List<GroupMember> activeMembers = filteredGroupMembers(
      viewModel.activeGroup,
      viewModel.user,
      types: ActivityType.getActiveTypes(),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          color: AppTheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                GroupsMemberCluster(members: viewModel.activeGroup.members),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              (viewModel.activeGroup == null) ||
                                      (viewModel.activeGroup.name == null)
                                  ? ''
                                  : viewModel.activeGroup.name,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows:
                                    commonTextShadow(color: Colors.black87),
                              ),
                            ),
                            Text(
                              ((viewModel.activeGroup == null) ||
                                      (viewModel.activeGroup.lastUpdated ==
                                          null))
                                  ? ''
                                  : lastUpdatedGroupMember(viewModel
                                      .activeGroup.lastUpdated
                                      .toDate()),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  preferBelow: false,
                  message: 'Settings',
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    constraints: BoxConstraints.tight(Size(40.0, 40.0)),
                    onPressed: () => _tapSettings(),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: AppTheme.primaryAccent,
          child: Row(children: <Widget>[
            _createStat(
                'Members',
                (viewModel.activeGroup == null)
                    ? 0
                    : viewModel.activeGroup.members.length),
            _createStat('Driving', drivingGroupMembers.length),
            _createStat('Active', activeMembers.length),
            // _createStat('Events', 1), // TODO
          ]),
        ),
      ],
    );
  }

  void _tapSettings() {
    Navigator.pop(context);

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(NavigatePopAction());
    store.dispatch(SetSelectedTabIndexAction(TAB_SETTINGS));
  }

  void _tapGroupMember(
    GroupMember member,
  ) {
    Navigator.pop(context);

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(NavigatePopAction());
    store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
    store.dispatch(ActivateGroupMemberAction(member.uid));
    store.dispatch(CancelUserActivityAction());
    store.dispatch(RequestUserActivityDataAction(member.uid));
  }

  Widget _createStat(
    String name,
    dynamic value,
  ) {
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: commonTextShadow(color: Colors.black87),
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    shadows: commonTextShadow(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createMemberList(
    GroupsViewModel viewModel,
  ) {
    List<Widget> members = List<Widget>();

    if (viewModel.activeGroup != null) {
      viewModel.activeGroup.members.forEach((member) {
        members
          ..add(GroupMemberAvatar(
            member: member,
            showName: true,
            onTap: () => _tapGroupMember(member),
          ));
      });
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Wrap(
                children: members,
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.spaceEvenly,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createButtons(
    BuildContext context,
    final store,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.light(),
        border: Border(
          top: BorderSide(
            color: AppTheme.inactive().withOpacity(0.3),
          ),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                            child: FlatButton(
                              color: AppTheme.primary,
                              splashColor: AppTheme.primaryAccent,
                              textColor: Colors.white,
                              child: Text('Create a Group'),
                              shape: StadiumBorder(),
                              onPressed: () => showCreateGroup(context, store),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 0.0),
                            child: FlatButton(
                                color: AppTheme.primary,
                                splashColor: AppTheme.primaryAccent,
                                textColor: Colors.white,
                                child: Text('Join a Group'),
                                shape: StadiumBorder(),
                                onPressed: () => showJoinGroup(context)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
                            child: FlatButton(
                              color: AppTheme.primary,
                              splashColor: AppTheme.primaryAccent,
                              textColor: Colors.white,
                              child: Text('Invite'),
                              shape: StadiumBorder(),
                              onPressed: () => showInviteCode(context),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 0.0, 10.0, 10.0),
                            child: FlatButton(
                              color: AppTheme.primary,
                              splashColor: AppTheme.primaryAccent,
                              textColor: Colors.white,
                              child: Text('Add a Place'),
                              shape: StadiumBorder(),
                              onPressed: () => _tapAddPlace(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapAddPlace() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupPlacesList));
  }
}
