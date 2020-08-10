import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class GroupsMemberLocationAccuracy extends StatefulWidget {
  final GroupMember member;
  final Widget child;

  GroupsMemberLocationAccuracy({
    @required this.member,
    this.child,
  });

  @override
  _GroupsMemberLocationAccuracyState createState() =>
      _GroupsMemberLocationAccuracyState();
}

class _GroupsMemberLocationAccuracyState
    extends State<GroupsMemberLocationAccuracy> {
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
      title: 'Wi-Fi off?',
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
              Icons.signal_wifi_off,
              color: AppTheme.primary,
              size: 40.0,
            ),
          ),
          Text(
            '$memberName\'s Wi-Fi is turned off. For more accurate location information, please ask ' +
                '$memberName to turn their phone\'s Wi-Fi setting to "ON". This improves their accuracy ' +
                'even when not connected to a network.',
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
              'Wi-Fi improves location accuracy. Turn Wi-Fi on from the main settings screen.',
            );
          },
          color: AppTheme.primary,
        ),
      ],
    ).show();
  }
}
