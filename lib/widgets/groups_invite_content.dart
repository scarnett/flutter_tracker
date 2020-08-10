import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class GroupsInviteContent extends StatefulWidget {
  final String groupId;

  GroupsInviteContent({
    this.groupId,
  });

  @override
  _GroupsInviteContentState createState() => _GroupsInviteContentState();
}

class _GroupsInviteContentState extends State<GroupsInviteContent> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        DateTime expires;
        Group group;
        GroupInvite invite;

        if (widget.groupId == null) {
          group = viewModel.activeGroup;
        } else {
          group = viewModel.group(widget.groupId);
        }

        invite = group.invite;
        if (invite.expires != null) {
          expires = invite.expires.toDate();
        }

        int dayDiff = inviteCodeDayDiff(expires);
        if ((invite == null) || (dayDiff <= 0)) {
          final store = StoreProvider.of<AppState>(context);
          store.dispatch(SaveInviteCodeAction(group.documentId, {
            'invite': {
              'code': generateInviteCode(),
              'expires': Timestamp.fromMillisecondsSinceEpoch(
                getNow()
                    .add(
                      Duration(
                        days: viewModel.configValue('invite_code_valid_days'),
                      ),
                    )
                    .millisecondsSinceEpoch,
              ),
            },
          }));
        }

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: const Text(
                'Share this code with the people you want in your Group:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                (invite.code == null) ? '' : formattedInviteCode(invite.code),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'This code will be active for $dayDiff more ${dayDiff == 1 ? 'day' : 'days'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
            DialogButton(
              child: Text(
                'Send Code',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () => Share.share(
                'Join my Flutter Tracker Group! Use my invite code ???. ' + // TODO FIX
                    'Flutter Tracker is available in the app store!',
              ),
              color: AppTheme.primary,
            ),
          ],
        );
      },
    );
  }
}
