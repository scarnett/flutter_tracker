import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';

enum PlaceEventType {
  ENTERING,
  LEAVING,
}

class Place {
  String documentId;
  String group;
  final String owner;
  String name;
  PlaceDetail details;
  double distance;
  Map<dynamic, dynamic> notifications;
  bool active;
  final Timestamp created;
  final Timestamp lastUpdated;

  Place({
    this.documentId,
    this.group,
    this.owner,
    this.name,
    this.details,
    this.distance,
    this.notifications,
    this.active = false,
    this.created,
    this.lastUpdated,
  });

  factory Place.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Place(
      documentId: json['documentId'],
      group: json['group'],
      owner: json['owner'],
      name: json['name'],
      details: PlaceDetail.fromJson(json['details']),
      distance: (json['distance'] == null) ? 0.00 : json['distance'].toDouble(),
      notifications: json['notifications'],
      active: json['active'],
      created: json['created'],
      lastUpdated: json['last_updated'],
    );
  }

  List<Place> fromJsonList(
    List<Map<dynamic, dynamic>> list,
  ) {
    List<Place> places = List<Place>();

    for (Map<dynamic, dynamic> place in list) {
      places..add(Place.fromJson(place));
    }

    return places;
  }

  List<Map<dynamic, dynamic>> toJsonList(
    List<Place> list,
  ) {
    List<Map<dynamic, dynamic>> places = List<Map<dynamic, dynamic>>();

    for (Place place in list) {
      places..add(Place().toMap(place));
    }

    return places;
  }

  factory Place.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return Place(
      documentId: snapshot.documentID,
      group: snapshot['group'],
      owner: snapshot['owner'],
      name: snapshot['name'],
      details: PlaceDetail.fromJson(snapshot['details']),
      distance: snapshot['distance'],
      notifications: snapshot['notifications'],
      active: snapshot['active'],
      created: snapshot['created'],
      lastUpdated: snapshot['last_updated'],
    );
  }

  factory Place.create(
    String name,
    PlaceDetail details, {
    String groupId,
    String ownerId,
    double distance,
    Map<dynamic, dynamic> notifications,
  }) {
    Timestamp now = Timestamp.fromDate(getNow());

    return Place(
      name: name,
      details: details,
      group: groupId,
      owner: ownerId,
      distance: distance,
      notifications: notifications,
      active: false,
      created: now,
      lastUpdated: now,
    );
  }

  Map<String, dynamic> toMap(
    Place place,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['group'] = place.group;
    map['owner'] = place.owner;
    map['name'] = place.name;
    map['details'] = PlaceDetail().toMap(place.details);
    map['distance'] = place.distance;
    map['notifications'] = place.notifications;
    map['active'] = place.active;
    map['created'] = place.created;
    map['last_updated'] = place.lastUpdated;
    return map;
  }
}

class PlaceDetail {
  final String id;
  String title;
  final String highlightedTitle;
  String vicinity;
  final String highlightedVicinity;
  dynamic position;
  final String category;
  final String categoryTitle;
  final String href;
  final String type;
  final String resultType;
  final int distance;
  final dynamic chainIds;
  final Timestamp lastUpdated;

  PlaceDetail({
    this.id,
    this.title,
    this.highlightedTitle,
    this.vicinity,
    this.highlightedVicinity,
    this.position,
    this.category,
    this.categoryTitle,
    this.href,
    this.type,
    this.resultType,
    this.distance,
    this.chainIds,
    this.lastUpdated,
  });

  factory PlaceDetail.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PlaceDetail(
      id: setValue(json['id'], def: null),
      title: setValue(json['title'], def: null),
      highlightedTitle: setValue(json['highlightedTitle'], def: null),
      vicinity: setValue(json['vicinity'], def: null),
      highlightedVicinity: setValue(json['highlightedVicinity'], def: null),
      position: setValue(json['position'], def: []),
      category: setValue(json['category'], def: null),
      categoryTitle: setValue(json['categoryTitle'], def: null),
      href: setValue(json['href'], def: null),
      type: setValue(json['type'], def: null),
      resultType: setValue(json['resultType'], def: null),
      distance: setValue(json['distance'], def: 0),
      chainIds: setValue(json['chainIds'], def: null),
      lastUpdated: setValue(json['lastUpdated'], def: null),
    );
  }

  factory PlaceDetail.fromAutoSuggest(
    dynamic place,
  ) {
    if (place == null) {
      return null;
    }

    return PlaceDetail(
      id: setValue(place['id'], def: null),
      title: setValue(place['title'], def: null),
      highlightedTitle: setValue(place['highlightedTitle'], def: null),
      vicinity: setValue(place['vicinity'], def: null),
      highlightedVicinity: setValue(place['highlightedVicinity'], def: null),
      position: setValue(place['position'], def: []),
      category: setValue(place['category'], def: null),
      categoryTitle: setValue(place['categoryTitle'], def: null),
      href: setValue(place['href'], def: null),
      type: setValue(place['type'], def: null),
      resultType: setValue(place['resultType'], def: null),
      distance: setValue(place['distance'], def: 0),
      chainIds: setValue(place['chainIds'], def: null),
      lastUpdated: setValue(place['lastUpdated'], def: null),
    );
  }

  factory PlaceDetail.fromReverseGeocode(
    dynamic geocode,
  ) {
    if (geocode == null) {
      return null;
    }

    dynamic location = geocode['Response']['View'][0]['Result'][0]['Location'];
    dynamic address = location['Address'];
    dynamic position = location['DisplayPosition'];
    List<dynamic> positionList = [
      position['Latitude'],
      position['Longitude'],
    ];

    return PlaceDetail(
      id: setValue(location['LocationId'], def: null),
      vicinity: setValue(address['Label'], def: null),
      position: setValue(positionList, def: []),
    );
  }

  factory PlaceDetail.fromNearby(
    dynamic nearby,
  ) {
    if (nearby == null) {
      return null;
    }

    return PlaceDetail(
      id: setValue(nearby['id'], def: null),
      title: setValue(nearby['title'], def: null),
      vicinity: setValue(nearby['vicinity'], def: null),
      position: setValue(nearby['position'], def: []),
      category: setValue(nearby['category']['id'], def: null),
      href: setValue(nearby['href'], def: null),
      type: setValue(nearby['type'], def: null),
      distance: setValue(nearby['distance'], def: 0),
    );
  }

  Map<String, dynamic> toMap(
    PlaceDetail place,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = place.id;
    map['title'] = place.title;
    map['highlightedTitle'] = place.highlightedTitle;
    map['vicinity'] = place.vicinity;
    map['highlightedVicinity'] = place.highlightedVicinity;
    map['position'] = place.position;
    map['category'] = place.category;
    map['categoryTitle'] = place.categoryTitle;
    map['href'] = place.href;
    map['type'] = place.type;
    map['resultType'] = place.resultType;
    map['distance'] = place.distance;
    map['chainIds'] = place.chainIds;
    map['lastUpdated'] = place.lastUpdated;
    return map;
  }

  toString() => 'PlaceDetail.$id';
}

class PlaceNotifications {
  final List<PlaceUser> users;

  PlaceNotifications({
    this.users,
  });

  factory PlaceNotifications.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PlaceNotifications(
      users: json['users'],
    );
  }

  Map<String, dynamic> toMap(
    PlaceNotifications place,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['users'] = place.users;
    place.users.forEach((user) {});
    return map;
  }
}

class PlaceUser {
  final String uid;
  final bool enabled;
  final Map<dynamic, dynamic> notifications;

  PlaceUser({
    this.uid,
    this.enabled,
    this.notifications,
  });

  factory PlaceUser.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PlaceUser(
      enabled: json['enabled'],
      notifications: json['notifications'],
    );
  }

  Map<String, dynamic> toMap(
    PlaceUser user,
  ) {
    Map<String, dynamic> notificationMap = Map<String, dynamic>();
    notificationMap['enabled'] = user.enabled;
    notificationMap['notifications'] = user.notifications;

    Map<String, dynamic> userMap = Map<String, dynamic>();
    userMap[user.uid] = notificationMap;
    return userMap;
  }
}

class PlaceActivity {
  final String documentId;
  final PlaceEventType type;
  final PlaceActivityUser user;
  final String activityId;
  final Timestamp created;

  PlaceActivity({
    this.documentId,
    this.type,
    this.user,
    this.activityId,
    this.created,
  });

  factory PlaceActivity.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    PlaceEventType type = PlaceEventType.values.firstWhere(
        (PlaceEventType type) =>
            type.toString().split('.').last ==
            json['type'].toString().toUpperCase(),
        orElse: () => null);

    return PlaceActivity(
      type: type,
      user: PlaceActivityUser.fromJson(json['user']),
      activityId: json['activity_id'],
      created: json['created'],
    );
  }

  factory PlaceActivity.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    PlaceEventType type = PlaceEventType.values.firstWhere(
        (PlaceEventType type) =>
            type.toString().split('.').last ==
            snapshot['type'].toString().toUpperCase(),
        orElse: () => null);

    return PlaceActivity(
      documentId: snapshot.documentID,
      type: type,
      user: PlaceActivityUser.fromJson(snapshot['user']),
      activityId: snapshot['activity_id'],
      created: snapshot['created'],
    );
  }
}

class PlaceActivityUser {
  final String uid;
  final String name;
  final String imageUrl;

  PlaceActivityUser({
    this.uid,
    this.name,
    this.imageUrl,
  });

  factory PlaceActivityUser.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PlaceActivityUser(
      uid: json['uid'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }

  factory PlaceActivityUser.create(
    User user,
  ) {
    return PlaceActivityUser(
      uid: user.documentId,
      name: user.name,
      imageUrl: (user.image == null) ? null : user.image.secureUrl,
    );
  }
}
