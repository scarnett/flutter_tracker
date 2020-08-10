import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/widgets/groups_pin_code.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupsJoinContent extends StatefulWidget {
  GroupsJoinContent();

  @override
  _GroupsJoinContentState createState() => _GroupsJoinContentState();
}

class _GroupsJoinContentState extends State<GroupsJoinContent>
    with TickerProviderStateMixin {
  int inviteCodeLength = 6;
  String inviteCode;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        return _createContent(context, viewModel);
      },
    );
  }

  Widget _createContent(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    if (viewModel.pendingGroupInvite == null) {
      return _buildJoinForm(viewModel);
    }

    return _buildConfirmForm(viewModel);
  }

  Widget _buildJoinForm(
    GroupsViewModel viewModel,
  ) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
          child: const Text(
            'Enter the invite code',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: GroupsPinCodeTextField(
            maxLength: inviteCodeLength,
            onTextChanged: (text) {
              setState(() {
                inviteCode = (text.length == inviteCodeLength) ? text : null;
              });
            },
            onDone: (text) {
              setState(() {
                inviteCode = text;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
          child: const Text(
            'Get the code from the person\nwho set up the Group',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        DialogButton(
          color: (inviteCode == null) ? AppTheme.inactive() : AppTheme.primary,
          child: Text(
            'Submit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: (inviteCode == null) ? null : () => _tapSubmit(viewModel),
        ),
      ],
    );
  }

  Widget _buildConfirmForm(
    GroupsViewModel viewModel,
  ) {
    GroupOwner owner = viewModel.pendingGroupInvite.group.owner;
    GroupMember member = getGroupMemberByUid(viewModel.activeGroup, owner.uid);

    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: const Text(
              'Would you like to join this person?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: UserAvatar(
              user: member,
              imageUrl: owner.imageUrl,
              avatarRadius: 48.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              member.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          DialogButton(
            child: Text(
              'Join',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
            onPressed: () => _tapJoin(viewModel),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: DialogButton(
              color: AppTheme.inactive(),
              child: Text(
                'Decline Invitation',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () => _tapDecline(),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Button spinner
  void _tapSubmit(
    GroupsViewModel viewModel,
  ) {
    StoreProvider.of<AppState>(context).dispatch(
      RequestGroupByInviteCodeAction(
        inviteCode,
        viewModel.user,
      ),
    );
  }

  // TODO: Button spinner
  void _tapJoin(
    GroupsViewModel viewModel,
  ) {
    StoreProvider.of<AppState>(context).dispatch(
      JoinGroupConfirmedAction(
        viewModel.user,
        viewModel.pendingGroupInvite.group,
      ),
    );
  }

  void _tapDecline() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(JoinGroupDeclineAction());
    Navigator.pop(context);
  }
}
