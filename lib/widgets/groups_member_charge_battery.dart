import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class GroupsMemberChargeBattery extends StatefulWidget {
  final GroupMember member;
  final Widget child;

  GroupsMemberChargeBattery({
    @required this.member,
    this.child,
  });

  @override
  _GroupsMemberChargeBatteryState createState() =>
      _GroupsMemberChargeBatteryState();
}

class _GroupsMemberChargeBatteryState extends State<GroupsMemberChargeBattery> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        return Material(
          child: InkWell(
            splashColor: Colors.red,
            onTap: () => _tapShow(viewModel),
            child: Container(
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  Future<bool> _tapShow(
    GroupsViewModel viewModel,
  ) {
    String memberName = getGroupMemberName(widget.member, viewModel: viewModel);

    return Alert(
      context: context,
      title: 'Battery low?',
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
      content: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Icon(
              Icons.battery_alert,
              color: AppTheme.primary,
              size: 40.0,
            ),
          ),
          Text(
            '$memberName\'s battery is low. For continued service, please ask ' +
                '$memberName to plug their device in to charge it up.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      closeFunction: () {},
      buttons: [
        DialogButton(
          child: Text(
            'Remind $memberName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () {
            Share.share(
              'Your battery is low. Please plug it in to charge it up.',
            );
          },
          color: AppTheme.primary,
        ),
      ],
    ).show();
  }
}
