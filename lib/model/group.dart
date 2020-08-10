import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tracker/model/app.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';

class Group {
  final String documentId;
  final String name;
  final List<dynamic> memberIndex;
  final List<GroupMember> members;
  final List<dynamic> admins;
  final GroupOwner owner;
  final GroupInvite invite;
  final Timestamp created;
  final Timestamp lastUpdated;
  final bool deleted;

  Group({
    this.documentId,
    this.name,
    this.memberIndex,
    this.members,
    this.admins,
    this.owner,
    this.invite,
    this.created,
    this.lastUpdated,
    this.deleted = false,
  });

  factory Group.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return Group(
      documentId: snapshot.documentID,
      name: snapshot['name'],
      memberIndex: snapshot['member_index'],
      members: GroupMembersFromJsonList(snapshot['members']),
      admins: snapshot['admins'],
      owner: GroupOwner.fromJson(snapshot['owner']),
      invite: GroupInvite.fromJson(snapshot['invite']),
      created: snapshot['created'],
      lastUpdated: snapshot['last_updated'],
      deleted: snapshot['deleted'],
    );
  }

  Group.fromMap(
    String name,
  ) : this(
          name: name,
        );

  factory Group.create(
    String name,
    User user,
    int inviteDays,
  ) {
    Timestamp now = Timestamp.fromDate(getNow());
    List<GroupMember> members = List<GroupMember>();
    members..add(GroupMember(uid: user.documentId));

    return Group(
      name: name,
      owner: GroupOwner.create(user),
      admins: [
        user.documentId,
      ],
      memberIndex: [
        user.documentId,
      ],
      members: members,
      invite: GroupInvite.create(inviteDays),
      created: now,
      lastUpdated: now,
      deleted: false,
    );
  }

  Map<String, dynamic> toMap(
    Group group,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['name'] = group.name;
    map['member_index'] = group.memberIndex;
    // map['members'] = GroupMember().toMap(group.members);
    map['admins'] = group.admins;
    map['owner'] = {
      'uid': group.owner.uid,
      'name': group.owner.name,
    };

    map['invite'] = {
      'code': group.invite.code,
      'expires': group.invite.expires,
    };

    map['created'] = group.created;
    map['last_updated'] = group.lastUpdated;
    map['deleted'] = group.deleted;
    return map;
  }
}

class GroupOwner {
  final String uid;
  final String name;
  final String imageUrl;

  GroupOwner({
    this.uid,
    this.name,
    this.imageUrl,
  });

  factory GroupOwner.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return GroupOwner(
      uid: json['uid'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }

  factory GroupOwner.create(
    User user,
  ) {
    return GroupOwner(
      uid: user.documentId,
      name: user.name,
      imageUrl: (user.image == null) ? null : user.image.secureUrl,
    );
  }
}

class GroupInvite {
  final String code;
  final Timestamp expires;

  GroupInvite({
    this.code,
    this.expires,
  });

  factory GroupInvite.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return GroupInvite(
      code: json['code'],
      expires: json['expires'],
    );
  }

  factory GroupInvite.create(
    int inviteDays,
  ) {
    DateTime now = getNow();

    return GroupInvite(
      code: generateInviteCode(),
      expires: Timestamp.fromMillisecondsSinceEpoch(now
          .add(
            Duration(days: inviteDays),
          )
          .millisecondsSinceEpoch),
    );
  }
}

class GroupMember {
  final String uid;
  final BatteryInfo battery;
  final Location location;
  final UserConnectivity connectivity;
  final Provider provider;
  final Place place;
  final String name;
  final String imageUrl;
  final Map<dynamic, dynamic> settings;
  final GroupLocationSharing locationSharing;
  final GroupActivityDetection activityDetection;
  final Timestamp lastUpdated;
  final AppVersion version;

  GroupMember({
    this.uid,
    this.battery,
    this.location,
    this.connectivity,
    this.provider,
    this.place,
    this.name,
    this.imageUrl,
    this.settings,
    this.locationSharing,
    this.activityDetection,
    this.lastUpdated,
    this.version,
  });

  factory GroupMember.fromJson(
    String uid,
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return GroupMember(
      uid: uid,
      battery: BatteryInfo.fromJson(json['battery']),
      location: Location.fromJson(json['location']),
      connectivity: UserConnectivity.fromJson(json['connectivity']),
      provider: Provider.fromJson(json['provider']),
      place: Place.fromJson(json['place']),
      name: json['name'],
      imageUrl: json['image_url'],
      settings: json['settings'],
      locationSharing: GroupLocationSharing.fromJson(json['location_sharing']),
      activityDetection:
          GroupActivityDetection.fromJson(json['activity_detection']),
      lastUpdated: json['last_updated'],
      version: AppVersion.fromJson(json['version']),
    );
  }

  List<GroupMember> fromJsonList(
    List<Map<dynamic, dynamic>> list,
  ) {
    List<GroupMember> members = List<GroupMember>();

    /*
    for (Map<dynamic, dynamic> member in list) {
      members..add(GroupMember.fromJson(member));
    }
    */

    return members;
  }

  Map<dynamic, dynamic> toMap(
    List<GroupMember> list,
  ) {
    Map<dynamic, dynamic> members = Map<dynamic, dynamic>();

    for (GroupMember member in list) {
      members[member.uid] = member;
    }

    return members;
  }

  bool hasLocationSharingEnabled() {
    return locationSharingEnabled(this);
  }

  bool hasActivityDetectionEnabled() {
    return activityDetectionEnabled(this);
  }

  factory GroupMember.fromSnapshot(
    String uid,
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return GroupMember(
      uid: uid,
      battery: BatteryInfo.fromJson(snapshot['battery']),
      location: Location.fromJson(snapshot['location']),
      connectivity: UserConnectivity.fromJson(snapshot['connectivity']),
      provider: Provider.fromJson(snapshot['provider']),
      place: Place.fromJson(snapshot['place']),
      name: snapshot['name'],
      imageUrl: snapshot['image_url'],
      settings: snapshot['settings'],
      lastUpdated: snapshot['last_updated'],
      version: AppVersion.fromJson(snapshot['version']),
    );
  }
}

class PendingGroupInvite {
  final Group group;

  PendingGroupInvite({
    this.group,
  });
}

class GroupLocationSharing {
  final bool status;
  final Timestamp sharingDisabled;

  GroupLocationSharing({
    this.status,
    this.sharingDisabled,
  });

  factory GroupLocationSharing.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return GroupLocationSharing(
      status: json['status'],
      sharingDisabled: json['sharing_disabled'],
    );
  }
}

class GroupActivityDetection {
  final bool status;
  final Timestamp detectionDisabled;

  GroupActivityDetection({
    this.status,
    this.detectionDisabled,
  });

  factory GroupActivityDetection.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return GroupActivityDetection(
      status: json['status'],
      detectionDisabled: json['detection_disabled'],
    );
  }
}
