import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/widgets/text_field.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupsMembersFormPage extends StatefulWidget {
  GroupsMembersFormPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsMembersFormPageState();
}

class _GroupsMembersFormPageState extends State<GroupsMembersFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _alias;
  bool _lowBatteryNotification;
  bool _drivingNotification;

  @override
  void initState() {
    this._alias = null;
    this._lowBatteryNotification = null;
    this._drivingNotification = null;
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        if (viewModel.activeGroupMember != null) {
          if (_alias == null) {
            _alias = getMemberSetting(viewModel, 'alias', '');
          }

          if (_lowBatteryNotification == null) {
            _lowBatteryNotification =
                getMemberSetting(viewModel, 'low_battery_notification', false);
          }

          if (_drivingNotification == null) {
            _drivingNotification =
                getMemberSetting(viewModel, 'driving_notification', false);
          }
        }

        return WillPopScope(
          onWillPop: () {
            final store = StoreProvider.of<AppState>(context);
            store.dispatch(NavigatePopAction());
            store.dispatch(ClearActiveGroupMemberAction());
            return Future.value(true);
          },
          child: Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(
                (viewModel.activeGroupMember == null)
                    ? 'Group Member'
                    : getGroupMemberName(viewModel.activeGroupMember,
                        viewModel: viewModel),
                style: const TextStyle(fontSize: 18.0),
              ),
              titleSpacing: 0.0,
              actions: <Widget>[
                FlatButton(
                  textColor: AppTheme.primary,
                  onPressed: () => _tapSave(viewModel),
                  child: const Text('Save'),
                  shape: CircleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                ),
              ],
            ),
            body: _createContent(viewModel),
          ),
        );
      },
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    if (viewModel.activeGroupMember == null) {
      return Container();
    }

    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Member Details'));
    tiles..add(_buildAliasField());
    tiles..add(SectionHeader(text: 'Notifications'));
    tiles..addAll(_buildBatteryNotificationTile(viewModel));
    tiles..addAll(_buildDrivingNotificationTile(viewModel));
    tiles..add(SectionHeader(text: 'App Info'));
    tiles
      ..addAll(_buildAppInfoTile(
          viewModel, 'Version', viewModel.activeGroupMember.version.version));
    tiles
      ..addAll(_buildAppInfoTile(
          viewModel, 'Build', viewModel.activeGroupMember.version.buildNumber));
    tiles..addAll(_buildDeleteButton(viewModel));

    return Container(
      child: Material(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: filterNullWidgets(tiles),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAliasField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: CustomTextField(
        hintText: 'Alias',
        initialValue: _alias,
        icon: Icons.person_outline,
        onSaved: (String val) => (_alias = (val == '') ? null : val),
      ),
    );
  }

  List<Widget> _buildBatteryNotificationTile(
    GroupsViewModel viewModel,
  ) {
    List<Widget> list = [];
    list
      ..add(
        ListTile(
          title: const Text(
            'Low Battery',
            style: const TextStyle(fontSize: 16.0),
          ),
          trailing: _buildBatteryToggle(viewModel),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        ),
      );

    list..add(ListDivider());
    return list;
  }

  Widget _buildBatteryToggle(
    GroupsViewModel viewModel,
  ) {
    return Switch(
      onChanged: (value) {
        setState(() {
          _lowBatteryNotification = value;
        });
      },
      value: _lowBatteryNotification,
      activeColor: AppTheme.primary,
      activeTrackColor: AppTheme.inactive(),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppTheme.inactive(),
    );
  }

  List<Widget> _buildDrivingNotificationTile(
    GroupsViewModel viewModel,
  ) {
    List<Widget> list = [];
    list
      ..add(
        ListTile(
          title: const Text(
            'Driving',
            style: const TextStyle(fontSize: 16.0),
          ),
          trailing: _buildDrivingToggle(viewModel),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        ),
      );

    list..add(ListDivider());
    return list;
  }

  Widget _buildDrivingToggle(
    GroupsViewModel viewModel,
  ) {
    return Switch(
      onChanged: (value) {
        setState(() {
          _drivingNotification = value;
        });
      },
      value: _drivingNotification,
      activeColor: AppTheme.primary,
      activeTrackColor: AppTheme.inactive(),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppTheme.inactive(),
    );
  }

  List<Widget> _buildAppInfoTile(
    GroupsViewModel viewModel,
    String label,
    dynamic value,
  ) {
    List<Widget> list = [];
    list
      ..add(
        ListTile(
          title: Text(
            label,
            style: const TextStyle(fontSize: 16.0),
          ),
          trailing: Text(
            value.toString(),
            style: const TextStyle(fontSize: 16.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        ),
      );

    list..add(ListDivider());
    return list;
  }

  List<Widget> _buildDeleteButton(
    GroupsViewModel viewModel,
  ) {
    bool isAdmin = isAdministrator(viewModel.activeGroup, viewModel.user);
    String memberUid = viewModel.activeGroupMember.uid;

    // Don't let the user delete the group owner or themselves
    if (!isAdmin ||
        (viewModel.activeGroup.owner.uid == memberUid) ||
        (viewModel.user.documentId == memberUid)) {
      return [];
    }

    return [
      SectionHeader(text: 'Remove Member'),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: FlatButton(
          color: Colors.red,
          splashColor: Colors.redAccent[700],
          textColor: Colors.white,
          child: Text('Remove Group Member'),
          shape: StadiumBorder(),
          onPressed: () => _tapRemove(viewModel),
        ),
      )
    ];
  }

  void _tapSave(
    GroupsViewModel viewModel,
  ) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Map<String, dynamic> data = {
        viewModel.user.documentId: {
          'settings': {
            viewModel.activeGroupMember.uid: {
              'alias': _alias,
              'low_battery_notification': _lowBatteryNotification,
              'driving_notification': _drivingNotification,
            },
          },
        },
      };

      final store = StoreProvider.of<AppState>(context);
      store.dispatch(ClearActiveGroupMemberAction());
      store.dispatch(UpdateGroupMemberSettingsAction(
          viewModel.activeGroup.documentId, data));

      Navigator.pop(context);
    }
  }

  void _tapRemove(GroupsViewModel viewModel) {
    Alert(
      context: context,
      title: 'REMOVE MEMBER',
      desc: 'Are you sure you want to remove this member?',
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () {
            final store = StoreProvider.of<AppState>(context);
            store.dispatch(RemoveGroupMemberAction(
              viewModel.activeGroup,
              viewModel.activeGroupMember,
            ));

            Navigator.popUntil(
                context, ModalRoute.withName(AppRoutes.groupMembers.name));
          },
          color: Colors.redAccent[700],
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
