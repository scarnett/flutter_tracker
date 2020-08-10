import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tracker/model/app.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:latlong/latlong.dart';
import 'package:latlong/latlong.dart' as latlng;

class User {
  final String documentId;
  final String name;
  final String timezone;
  final String primaryGroup;
  final String activeGroup;
  final String activeGroupMember;
  final Purchase purchase;
  final BatteryInfo battery;
  final Location location;
  final UserConnectivity connectivity;
  final UserFCM fcm;
  final UserMapData mapData;
  final UserNearBy nearBy;
  final Timestamp created;
  final Timestamp lastUpdated;
  final Auth auth;
  final Provider provider;
  final CloudinaryImage image;
  final Map<dynamic, dynamic> device;
  final AppVersion version;

  User({
    this.documentId,
    this.name,
    this.timezone,
    this.primaryGroup,
    this.activeGroup,
    this.activeGroupMember,
    this.purchase,
    this.battery,
    this.location,
    this.connectivity,
    this.fcm,
    this.mapData,
    this.nearBy,
    this.created,
    this.lastUpdated,
    this.auth,
    this.provider,
    this.image,
    this.device,
    this.version,
  });

  factory User.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return User(
      name: json['name'],
      timezone: json['timezone'],
      primaryGroup: json['primary_Group'],
      activeGroup: json['active_group'],
      activeGroupMember: json['active_group_member'],
      purchase: json['purchase'],
      battery: json['battery'],
      location: json['location'],
      connectivity: UserConnectivity.fromJson(json['connectivity']),
      fcm: json['fcm'],
      mapData: UserMapData.fromJson(json['map_data']),
      nearBy: UserNearBy.fromJson(json['near_by']),
      created: json['created'],
      lastUpdated: json['last_updated'],
      auth: Auth.fromSnapshot(json['auth']),
      provider: Provider.fromJson(json['provider']),
      image: CloudinaryImage.fromJson(json['image']),
      device: json['device'],
      version: AppVersion.fromJson(json['version']),
    );
  }

  factory User.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return User(
      documentId: snapshot.documentID,
      name: snapshot['name'],
      timezone: snapshot['timezone'],
      primaryGroup: snapshot['primary_group'],
      activeGroup: snapshot['active_group'],
      activeGroupMember: snapshot['active_group_member'],
      purchase: Purchase.fromJson(snapshot['purchase']),
      battery: BatteryInfo.fromJson(snapshot['battery']),
      location: Location.fromJson(snapshot['location']),
      connectivity: UserConnectivity.fromJson(snapshot['connectivity']),
      fcm: UserFCM.fromJson(snapshot['fcm']),
      mapData: UserMapData.fromJson(snapshot['map_data']),
      nearBy: UserNearBy.fromJson(snapshot['near_by']),
      created: snapshot['created'],
      lastUpdated: snapshot['last_updated'],
      auth: Auth.fromJson(snapshot['auth']),
      provider: Provider.fromJson(snapshot['provider']),
      image: CloudinaryImage.fromJson(snapshot['image']),
      device: snapshot['device'],
      version: AppVersion.fromJson(snapshot['version']),
    );
  }
}

class UserConnectivity {
  final String status;
  final String wifiBssid;
  final String wifiIp;
  final String wifiName;

  UserConnectivity({
    this.status,
    this.wifiBssid,
    this.wifiIp,
    this.wifiName,
  });

  factory UserConnectivity.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return UserConnectivity(
      status: json['status'],
      wifiBssid: json['wifi_bssid'],
      wifiIp: json['wifi_ip'],
      wifiName: json['wifi_name'],
    );
  }
}

class UserFCM {
  final String token;

  UserFCM({
    this.token,
  });

  factory UserFCM.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return UserFCM(
      token: json['token'],
    );
  }
}

class UserMapData {
  final LatLng currentPosition;
  final Timestamp lastUpdated;
  final String mapType;

  UserMapData({
    this.currentPosition,
    this.lastUpdated,
    this.mapType,
  });

  factory UserMapData.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    dynamic latLng = json['current_position'];

    return UserMapData(
      currentPosition: (latLng == null)
          ? null
          : LatLng(latLng['latitude'], latLng['longitude']),
      lastUpdated: json['last_updated'],
      mapType: json['map_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'current_position': {
          'latitude': currentPosition.latitude,
          'longitude': currentPosition.longitude,
        },
        'last_updated': lastUpdated,
        'map_type': mapType,
      };
}

class UserNearBy {
  final LocationCoords lastPosition;
  final Timestamp lastUpdated;
  final List<Place> places;

  UserNearBy({
    this.lastPosition,
    this.lastUpdated,
    this.places,
  });

  factory UserNearBy.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return UserNearBy(
      lastPosition: LocationCoords.fromJson(json['last_position']),
      lastUpdated: json['last_updated'],
      places: nearByPlacesFromJsonList(json['places']),
    );
  }
}

class Purchase {
  final String orderId;
  final String packageName;
  final String purchaseToken;
  final int purchaseTime;
  final String sku;
  final bool isAutoRenewing;
  final String originalJson;

  Purchase({
    this.orderId,
    this.packageName,
    this.purchaseToken,
    this.purchaseTime,
    this.sku,
    this.isAutoRenewing,
    this.originalJson,
  });

  factory Purchase.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Purchase(
      orderId: json['order_id'],
      packageName: json['package_name'],
      purchaseToken: json['purchase_token'],
      purchaseTime: json['purchase_time'],
      sku: json['sku'],
      isAutoRenewing: json['is_auto_renewing'],
      originalJson: json['original_json'],
    );
  }
}

class Location {
  final LocationActivity activity;
  final LocationCoords coords;
  final LocationExtras extras;
  final bool isMoving;
  final double odometer;
  final String timestamp;
  final String uuid;

  Location({
    this.activity,
    this.coords,
    this.extras,
    this.isMoving,
    this.odometer,
    this.timestamp,
    this.uuid,
  });

  factory Location.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Location(
      activity: LocationActivity.fromJson(json['activity']),
      coords: LocationCoords.fromJson(json['coords']),
      extras: LocationExtras.fromJson(json['extras']),
      isMoving: json['is_moving'],
      odometer: (json['odometer'] == null) ? 0.00 : json['odometer'].toDouble(),
      timestamp: json['timestamp'],
      uuid: json['uuid'],
    );
  }

  Location.fromMap(
    LocationActivity activity,
    LocationCoords coords,
  ) : this(
          activity: activity,
          coords: coords,
        );

  latlng.LatLng toLatLng() {
    return latlng.LatLng(
      this.coords.latitude,
      this.coords.longitude,
    );
  }
}

class LocationActivity {
  final int confidence;
  final ActivityType type;

  LocationActivity({
    this.confidence,
    this.type,
  });

  factory LocationActivity.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return LocationActivity(
      confidence: json['confidence'],
      type: ActivityType.fromString(json['type']),
    );
  }
}

class ActivityType {
  final String _type;

  const ActivityType._internal(
    this._type,
  );

  toString() => 'ActivityType.$_type';

  static const STILL_STR = 'still';
  static const ON_FOOT_STR = 'on_foot';
  static const WALKING_STR = 'walking';
  static const RUNNING_STR = 'running';
  static const IN_VEHICLE_STR = 'in_vehicle';
  static const ON_BICYCLE_STR = 'on_bicycle';
  static const CHECKIN_SENDER_STR = 'checkin_sender';
  static const CHECKIN_RECEIVER_STR = 'checkin_receiver';

  static const STILL = const ActivityType._internal(STILL_STR);
  static const ON_FOOT = const ActivityType._internal(ON_FOOT_STR);
  static const WALKING = const ActivityType._internal(WALKING_STR);
  static const RUNNING = const ActivityType._internal(RUNNING_STR);
  static const IN_VEHICLE = const ActivityType._internal(IN_VEHICLE_STR);
  static const ON_BICYCLE = const ActivityType._internal(ON_BICYCLE_STR);
  static const CHECKIN_SENDER =
      const ActivityType._internal(CHECKIN_SENDER_STR);
  static const CHECKIN_RECEIVER =
      const ActivityType._internal(CHECKIN_RECEIVER_STR);

  static const WALKING_TXT = 'Walking';
  static const RUNNING_TXT = 'Running';
  static const IN_VEHICLE_TXT = 'Driving';
  static const ON_BICYCLE_TXT = 'Biking';

  String getType() {
    return this._type;
  }

  factory ActivityType.fromString(
    String type,
  ) {
    switch (type) {
      case STILL_STR:
        return ActivityType.STILL;
        break;

      case ON_FOOT_STR:
        return ActivityType.ON_FOOT;
        break;

      case WALKING_STR:
        return ActivityType.WALKING;
        break;

      case RUNNING_STR:
        return ActivityType.RUNNING;
        break;

      case IN_VEHICLE_STR:
        return ActivityType.IN_VEHICLE;
        break;

      case ON_BICYCLE_STR:
        return ActivityType.ON_BICYCLE;
        break;

      case CHECKIN_SENDER_STR:
        return ActivityType.CHECKIN_SENDER;
        break;

      case CHECKIN_RECEIVER_STR:
        return ActivityType.CHECKIN_RECEIVER;
        break;

      default:
        return null;
    }
  }

  static String toText(
    ActivityType type,
  ) {
    switch (type) {
      case WALKING:
        return ActivityType.WALKING_TXT;
        break;

      case RUNNING:
        return ActivityType.RUNNING_TXT;
        break;

      case IN_VEHICLE:
        return ActivityType.IN_VEHICLE_TXT;
        break;

      case ON_BICYCLE:
        return ActivityType.ON_BICYCLE_TXT;

      default:
        return null;
    }
  }

  static String strToText(
    String type,
  ) {
    switch (type) {
      case WALKING_STR:
        return ActivityType.WALKING_TXT;
        break;

      case RUNNING_STR:
        return ActivityType.RUNNING_TXT;
        break;

      case IN_VEHICLE_STR:
        return ActivityType.IN_VEHICLE_TXT;
        break;

      case ON_BICYCLE_STR:
        return ActivityType.ON_BICYCLE_TXT;

      default:
        return null;
    }
  }

  static bool isDriving(
    ActivityType activityType,
  ) {
    if ((activityType != null) && (activityType == ActivityType.IN_VEHICLE)) {
      return true;
    }

    return false;
  }

  static bool isMoving(
    ActivityType activityType,
  ) {
    if ((activityType != null) && (activityType != ActivityType.STILL)) {
      return true;
    }

    return false;
  }

  static List<ActivityType> getActiveTypes() {
    return [
      ActivityType.IN_VEHICLE,
      ActivityType.ON_BICYCLE,
      ActivityType.ON_FOOT,
      ActivityType.RUNNING,
      ActivityType.WALKING,
      ActivityType.CHECKIN_SENDER,
      ActivityType.CHECKIN_RECEIVER,
    ];
  }
}

class ActivityEventType {
  final String _type;

  const ActivityEventType._internal(
    this._type,
  );

  toString() => 'ActivityEventType.$_type';

  static const DRIVING_STARTED_STR = 'driving_started';
  static const DRIVING_STOPPED_STR = 'driving_stopped';
  static const GEOFENCE_ENTERING_STR = 'geofence_entering';
  static const GEOFENCE_LEAVING_STR = 'geofence_leaving';

  static const DRIVING_STARTED =
      const ActivityEventType._internal(DRIVING_STARTED_STR);
  static const DRIVING_STOPPED =
      const ActivityEventType._internal(DRIVING_STOPPED_STR);
  static const GEOFENCE_ENTERING =
      const ActivityEventType._internal(GEOFENCE_ENTERING_STR);
  static const GEOFENCE_LEAVING =
      const ActivityEventType._internal(GEOFENCE_LEAVING_STR);

  String getType() {
    return this._type;
  }

  factory ActivityEventType.fromString(
    String type,
  ) {
    switch (type) {
      case DRIVING_STARTED_STR:
        return ActivityEventType.DRIVING_STARTED;
        break;

      case DRIVING_STOPPED_STR:
        return ActivityEventType.DRIVING_STOPPED;
        break;

      case GEOFENCE_ENTERING_STR:
        return ActivityEventType.GEOFENCE_ENTERING;
        break;

      case GEOFENCE_LEAVING_STR:
        return ActivityEventType.GEOFENCE_LEAVING;
        break;

      default:
        return null;
    }
  }

  static List<ActivityEventType> getActiveEventTypes() {
    return [
      ActivityEventType.DRIVING_STARTED,
      ActivityEventType.DRIVING_STOPPED,
      ActivityEventType.GEOFENCE_ENTERING,
      ActivityEventType.GEOFENCE_LEAVING,
    ];
  }
}

class LocationCoords {
  final dynamic accuracy;
  final dynamic altitude;
  final dynamic heading;
  final double latitude;
  final double longitude;
  final dynamic speed;

  LocationCoords({
    this.accuracy,
    this.altitude,
    this.heading,
    this.latitude,
    this.longitude,
    this.speed,
  });

  factory LocationCoords.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return LocationCoords(
      accuracy: json['accuracy'],
      altitude: json['altitude'],
      heading: json['heading'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      speed: json['speed'],
    );
  }

  Map<String, dynamic> toMap(
    LocationCoords coords,
  ) {
    if (coords == null) {
      return null;
    }

    Map<String, dynamic> coordsMap = Map<String, dynamic>();
    coordsMap['accuracy'] = coords.accuracy;
    coordsMap['altitude'] = coords.altitude;
    coordsMap['heading'] = coords.heading;
    coordsMap['latitude'] = coords.latitude;
    coordsMap['longitude'] = coords.longitude;
    coordsMap['speed'] = coords.speed;
    return coordsMap;
  }
}

class LocationExtras {
  LocationExtras();

  factory LocationExtras.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    return LocationExtras();
  }
}

class BatteryInfo {
  final bool charging;
  final double level;

  BatteryInfo({
    this.charging,
    this.level,
  });

  factory BatteryInfo.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return BatteryInfo(
      charging: (json['charging'] == null) ? false : json['charging'],
      level: (json['level'] == null) ? 0.0 : json['level'].toDouble(),
    );
  }
}

class Provider {
  final bool enabled;
  final bool gps;
  final bool network;
  final int status;

  Provider({
    this.enabled,
    this.gps,
    this.network,
    this.status,
  });

  factory Provider.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Provider(
      enabled: json['enabled'],
      gps: json['gps'],
      network: json['network'],
      status: json['status'],
    );
  }
}

class UserActivity {
  final String documentId;
  final bool active;
  final ActivityType type;
  final dynamic data;
  final dynamic meta;
  final Timestamp startTime;
  final Timestamp endTime;
  final Timestamp lastUpdated;
  final List<UserActivityEvent> events;

  UserActivity({
    this.documentId,
    this.active,
    this.type,
    this.data,
    this.meta,
    this.startTime,
    this.endTime,
    this.lastUpdated,
    this.events,
  });

  factory UserActivity.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return UserActivity(
      active: json['active'],
      type: ActivityType.fromString(json['type']),
      data: activityFromJsonList(json['data']),
      meta: json['meta'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      lastUpdated: json['last_updated'],
      events: UserActivityEvent().fromJsonMap(json['events']),
    );
  }

  factory UserActivity.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return UserActivity(
      documentId: snapshot.documentID,
      active: snapshot['active'],
      type: ActivityType.fromString(snapshot['type']),
      data: activityFromJsonList(snapshot['data']),
      meta: snapshot['meta'],
      startTime: snapshot['start_time'],
      endTime: snapshot['end_time'],
      lastUpdated: snapshot['last_updated'],
      events: UserActivityEvent().fromJsonMap(snapshot['events']),
    );
  }
}

class UserActivityEvent {
  final ActivityEventType type;
  final dynamic data;
  final Timestamp created;

  UserActivityEvent({
    this.type,
    this.data,
    this.created,
  });

  factory UserActivityEvent.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return UserActivityEvent(
      type: ActivityEventType.fromString(json['type']),
      data: activityFromJsonList(json['data']),
      created: json['created'],
    );
  }

  List<UserActivityEvent> fromJsonMap(
    Map<dynamic, dynamic> map,
  ) {
    List<UserActivityEvent> events = List<UserActivityEvent>();

    if (map != null) {
      map.forEach((key, entry) {
        if (key != null) {
          dynamic option = map[key];
          if (option != null) {
            events..add(UserActivityEvent.fromJson(option));
          }
        }
      });
    }

    return events;
  }

  factory UserActivityEvent.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return UserActivityEvent(
      type: ActivityEventType.fromString(snapshot['type']),
      data: activityFromJsonList(snapshot['data']),
      created: snapshot['created'],
    );
  }
}
