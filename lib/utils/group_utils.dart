import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/dialog_utils.dart';
import 'package:flutter_tracker/utils/plan_utils.dart';
import 'package:flutter_tracker/utils/rand_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/groups_create_content.dart';
import 'package:flutter_tracker/widgets/groups_invite_content.dart';
import 'package:flutter_tracker/widgets/groups_join_content.dart';
import 'package:timeago/timeago.dart' as timeago;

const int GROUP_INVITE_CODE_LENGTH = 6;
const int GROUP_INVITE_CODE_INDEX = 3;
const String GROUP_INVITE_CODE_SPACER_CHAR = '-';

Future<bool> showInviteCode(
  BuildContext context, {
  String groupId,
}) {
  return showAlert(
      context, 'Invite Code', GroupsInviteContent(groupId: groupId));
}

Future<bool> showCreateGroup(
  BuildContext context,
  final store,
) {
  GroupsViewModel viewModel = GroupsViewModel.fromStore(store);
  int groupCount = viewModel.groupCount(true);
  if (needsUpgrade(viewModel.activePlan, 'max_groups', groupCount)) {
    store.dispatch(NavigatePushAction(AppRoutes.upgrade));
  }

  return showAlert(context, 'Create a Group', GroupsCreateContent());
}

Future<bool> showJoinGroup(
  BuildContext context,
) {
  return showAlert(context, 'Join a Group', GroupsJoinContent());
}

String getGroupMemberName(
  dynamic member, {
  GroupsViewModel viewModel,
}) {
  if ((member == null) || (member.name == null)) {
    return 'N/A';
  }

  if (viewModel != null) {
    if ((member != null) && (viewModel.user.documentId == member.uid)) {
      return 'You';
    }

    String alias = getMemberSettingByUid(viewModel, member.uid, 'alias', null);
    if (alias != null) {
      return alias;
    }
  }

  return member.name;
}

dynamic getMemberSetting(
  GroupsViewModel viewModel,
  String settingName,
  dynamic defaultValue,
) {
  return getMemberSettingByUid(
    viewModel,
    viewModel.activeGroupMember.uid,
    settingName,
    defaultValue,
  );
}

dynamic getMemberSettingByUid(
  GroupsViewModel viewModel,
  String uid,
  String settingName,
  dynamic defaultValue,
) {
  GroupMember member = viewModel.activeGroup.members.firstWhere(
      (member) => member.uid == viewModel.user.documentId,
      orElse: () => null);

  if ((member != null) && (member.settings != null)) {
    dynamic setting = member.settings[uid];
    if (setting != null) {
      return setting[settingName];
    }
  }

  return defaultValue;
}

int inviteCodeDayDiff(
  DateTime expires,
) {
  if (expires != null) {
    return (expires.difference(getNow()).inDays + 1);
  }

  return 0;
}

// TODO: Duplicate checking
String generateInviteCode() {
  return randomAlpha(GROUP_INVITE_CODE_LENGTH).toUpperCase();
}

String formattedInviteCode(
  String inviteCode,
) {
  if (inviteCode == null) {
    return null;
  }

  final int length = inviteCode.length;
  String formattedInviteCode = '';

  for (int i = 0; i < length; i++) {
    formattedInviteCode += inviteCode[i];

    if ((GROUP_INVITE_CODE_LENGTH > (i + 1)) &&
        (((i + 1) % GROUP_INVITE_CODE_INDEX) == 0)) {
      formattedInviteCode += GROUP_INVITE_CODE_SPACER_CHAR;
    }
  }

  return formattedInviteCode;
}

Widget addNewGroupMemberItem(
  BuildContext context,
) {
  return Material(
    child: InkWell(
      onTap: () => showInviteCode(context),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Add a New Member',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    ),
  );
}

Widget addNewGroupItem(
  BuildContext context,
  final store,
) {
  return Material(
    child: InkWell(
      onTap: () => showCreateGroup(context, store),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Add a New Group',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    ),
  );
}

Widget addNewPlaceItem(
  final store,
) {
  return Material(
    child: InkWell(
      onTap: () =>
          store.dispatch(NavigatePushAction(AppRoutes.groupPlacesList)),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Add a New Place',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    ),
  );
}

List<GroupMember> GroupMembersFromJsonList(
  Map<dynamic, dynamic> list,
) {
  List<GroupMember> members = List<GroupMember>();

  if (list != null) {
    list.forEach((key, member) {
      if (!(member is String)) {
        members..add(GroupMember.fromJson(key, member));
      }
    });
  }

  return members;
}

List<Place> placesFromJsonList(
  Map<dynamic, dynamic> list,
) {
  List<Place> places = List<Place>();

  if (list != null) {
    list.forEach((key, place) {
      if (!(place is String)) {
        places..add(Place.fromJson(place));
      }
    });
  }

  return places;
}

List<GroupMember> filteredGroupMembers(
  Group group,
  User user, {
  List<ActivityType> types,
}) {
  List<GroupMember> filtered = List<GroupMember>.from(
      group.members.where((member) => member.uid != user.documentId));

  if (types != null) {
    filtered = List<GroupMember>.from(filtered.where((member) {
      ActivityType _type = member.location.activity.type;
      return (_type != null) && types.contains(_type);
    }));
  }

  return filtered;
}

GroupMember getGroupMember(
  Group group,
  User user,
) {
  if ((group != null) && (user != null)) {
    return getGroupMemberByUid(group, user.documentId);
  }

  return null;
}

GroupMember getGroupMemberByUid(
  Group group,
  String uid,
) {
  if ((group != null) && (group.members != null) && (uid != null)) {
    GroupMember member = group.members
        .firstWhere((member) => member.uid == uid, orElse: () => null);
    return member;
  }

  return null;
}

List<Widget> getGroupMemberText(
  GroupMember member,
  GroupsViewModel viewModel,
) {
  return [
    Text(
      getGroupMemberName(member, viewModel: viewModel),
      style: const TextStyle(
        fontSize: 15.0,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
    ),
    Text(
      (member != null)
          ? lastUpdatedGroupMember(
              member.lastUpdated.toDate(),
              member: member,
            )
          : '',
      style: TextStyle(
        color: AppTheme.hint,
        fontSize: 12.0,
      ),
    ),
  ];
}

String buildAvatarUrl({
  GroupMember member,
  int size,
  bool online = false,
}) {
  if ((member == null) || (member.imageUrl == null)) {
    return null;
  }

  return cloudinaryTransformUrl(
    member.imageUrl,
    transformation:
        online || isOnlineAndSharingLocation(member) ? 'avatar' : 'offline',
    extraOptions: [
      'w_$size', // Adds the width transformation
      'h_$size', // Adds the height transformation
      'q_100', // Adds the quality (100%) transformation
    ],
  );
}

// TODO: Make this a bit smarter. Maybe show the date if the day diff is greater than 1d
String lastUpdatedGroupMember(
  DateTime date, {
  GroupMember member,
  String format = 'hh:mm a',
}) {
  if (date == null) {
    return null;
  }

  if ((member != null) && !locationSharingEnabled(member)) {
    return 'Location sharing paused';
  }

  return 'Last updated ${timeago.format(date)}';
  // return 'Last updated ${formatEpoch(epoch, format)}';
}
