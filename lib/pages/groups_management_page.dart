import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/list_select_item.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupsManagementPage extends StatefulWidget {
  GroupsManagementPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsManagementPageState();
}

class _GroupsManagementPageState extends State<GroupsManagementPage> {
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
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: const Text(
              'Group Management',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _buildBody(
            viewModel,
            isAdministrator(viewModel.activeGroup, viewModel.user),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    GroupsViewModel viewModel,
    bool isAdministrator,
  ) {
    List<Widget> items = []
      ..addAll(_groupDetailsSection(viewModel, isAdministrator))
      ..addAll(_groupsManagementSection(viewModel, isAdministrator));

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: items,
          ),
        ),
      ],
    );
  }

  List<Widget> _groupDetailsSection(
    GroupsViewModel viewModel,
    bool isAdministrator,
  ) {
    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Group Details'));
    tiles
      ..add(ListSelectItem(
        title: 'Edit Group',
        icon: Icons.edit,
        onTap: () => _onTapEdit(context),
        disabled: !isAdministrator,
      ));

    return tiles;
  }

  List<Widget> _groupsManagementSection(
    GroupsViewModel viewModel,
    bool isAdministrator,
  ) {
    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Group Management'));

    if (isAdministrator) {
      tiles
        ..add(ListSelectItem(
          title: 'Administrators',
          icon: Icons.supervised_user_circle,
          onTap: () => _onTapAdministrators(context),
        ));

      tiles..add(ListDivider());
    }

    tiles
      ..add(ListSelectItem(
        title: 'Members',
        icon: Icons.people,
        onTap: () => _onTapMembers(context),
      ));

    tiles..add(ListDivider());

    if (isAdministrator) {
      tiles
        ..add(ListSelectItem(
          title: 'Add Member',
          icon: Icons.add,
          onTap: () => showInviteCode(context),
        ));

      tiles..add(ListDivider());
    }

    User user = viewModel.user;
    tiles
      ..add(ListSelectItem(
        title: 'Leave Group',
        icon: Icons.input,
        onTap: () =>
            _onTapLeaveGroup(context, viewModel.user, viewModel.activeGroup),
        disabled: (user.activeGroup ==
            user.primaryGroup), // Do not allow a member to leave their primary group
      ));

    return tiles;
  }

  _onTapAdministrators(
    context,
  ) {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupAdministrators));
  }

  _onTapEdit(
    context,
  ) {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupForm));
  }

  _onTapMembers(
    context,
  ) {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupMembers));
  }

  _onTapLeaveGroup(
    context,
    User user,
    Group activeGroup,
  ) {
    Alert(
      context: context,
      title: 'LEAVE GROUP',
      desc: 'Are you sure you want to leave this group?',
      style: AlertStyle(
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        descStyle: const TextStyle(
          color: Colors.black38,
          fontStyle: FontStyle.normal,
          fontSize: 14.0,
          height: 1.5,
        ),
      ),
      closeFunction: () {},
      buttons: [
        DialogButton(
          child: const Text(
            'Yes',
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
          onPressed: () {
            StoreProvider.of<AppState>(context)
                .dispatch(LeaveGroupAction(user, activeGroup));
            Navigator.pop(context);
          },
          color: AppTheme.primary,
        ),
        DialogButton(
          child: const Text(
            'No',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.inactive(),
        ),
      ],
    ).show();
  }
}
