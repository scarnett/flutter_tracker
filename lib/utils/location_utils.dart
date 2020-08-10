import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:location_permissions/location_permissions.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/config.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/services/users.dart';
import 'package:flutter_tracker/utils/api_utils.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/color_utils.dart';
import 'package:flutter_tracker/utils/connectivity_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:latlong/latlong.dart' as latlng;

Logger logger = Logger();

bg.Config getBaseConfig(
  AppConfig appConfig,
  final store,
) {
  // TODO: Add advanced settings that allows the user to change some of this stuff
  return bg.Config(
    url: updateUserEndpointUrl(
      url: appConfig.userEndpointUrl,
      type: 'location',
    ),
    method: 'POST',
    headers: endpointHeaders(store.state.user.auth.token),
    extras: {
      'user_endpoint': appConfig.userEndpointUrl,
      'message_endpoint': appConfig.messageEndpointUrl,
    },
    desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
    notification: bg.Notification(
      priority: bg.Config.NOTIFICATION_PRIORITY_MIN,
      title: 'Checking for activity...',
      text: '',
      color: colorToHex(AppTheme.primary),
      smallIcon: 'mipmap/ic_stat',
    ),
    distanceFilter: 20.0,
    stationaryRadius: 25.0,
    heartbeatInterval: 300, // 5min
    desiredOdometerAccuracy: 10.0,
    preventSuspend: true,
    geofenceModeHighAccuracy: false,
    geofenceInitialTriggerEntry: false,
    disableElasticity: false,
    stopOnTerminate: false,
    startOnBoot: true,
    foregroundService: true,
    enableHeadless: true,
    autoSync: true,
    batchSync: true,
    httpRootProperty: 'location',
    maxRecordsToPersist: 1000,
    logLevel: bg.Config.LOG_LEVEL_OFF,
    debug: false,
    reset: true,
  );
}

Future<void> requestLocationPermission({
  LocationPermissionLevel permissionLevel: LocationPermissionLevel.location,
}) async {
  final PermissionStatus permissionRequestResult = await LocationPermissions()
      .requestPermissions(permissionLevel: permissionLevel);
  return permissionRequestResult;
}

void initLocation(
  BuildContext context,
  final store,
) {
  bg.BackgroundGeolocation.onLocation((event) => _onLocationEvent(event));
  bg.BackgroundGeolocation.onGeofence((event) => _onGeofenceEvent(event));
  bg.BackgroundGeolocation.onHeartbeat((event) => _onHeartbeatEvent(event));
  bg.BackgroundGeolocation.onProviderChange(
      (event) => _onProviderChangeEvent(event));

  // bg.BackgroundGeolocation.onActivityChange((event) => _onActivityEvent(event));
  // bg.BackgroundGeolocation.onHttp((bg.HttpEvent event) => print(event.toMap()));

  AppConfig appConfig = AppConfig.of(context);
  bg.Config config = getBaseConfig(appConfig, store);
  bg.BackgroundGeolocation.ready(config).then((bg.State state) {
    if (state.enabled) {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        logger.d('Location sharing has been disabled');
        _startBackgroundGeolocation();
      });
    } else {
      _startBackgroundGeolocation();
    }

    getCurrentPosition(appConfig);
  }).catchError((error) => logger.e('[ready] ERROR: $error'));
}

void _startBackgroundGeolocation() {
  bg.BackgroundGeolocation.start().then((bg.State state) {
    logger.d('Location sharing has been enabled');
  });
}

Future<void> getCurrentPosition(
  AppConfig appConfig,
) {
  return bg.BackgroundGeolocation.getCurrentPosition()
      .then((bg.Location location) => _onLocationEvent(location))
      .catchError((error) => _onLocationError(error));
}

/*
void _onActivityEvent(
  bg.ActivityChangeEvent event,
) {
  bg.BackgroundGeolocation.state.then((bg.State state) async {
    String url = state.extras['user_endpoint'];
    if (url != null) {
      String authToken = getAuthToken(state.headers['Authorization']);
      Map<String, dynamic> messageData = Map<String, dynamic>();
      messageData['activity'] = event.toMap();
      await updateUserData(url, authToken, messageData);
    }
  });
}
*/

void _onLocationEvent(
  bg.Location location,
) {
  bg.BackgroundGeolocation.state.then((bg.State state) async {
    String url = state.extras['user_endpoint'];
    if (url != null) {
      String authToken = getAuthToken(state.headers['Authorization']);
      Map<String, dynamic> messageData = Map<String, dynamic>();
      messageData['location'] = location.toMap();
      await updateUserData(url, authToken, messageData);
    }
  });
}

// https://github.com/transistorsoft/flutter_background_geolocation/wiki/Android-Headless-Mode
void onHeadlessTask(
  bg.HeadlessEvent headlessEvent,
) async {
  switch (headlessEvent.name) {
    case bg.Event.LOCATION:
      bg.Location locationEvent = headlessEvent.event;
      _onLocationEvent(locationEvent);
      break;

    // case bg.Event.GEOFENCESCHANGE:
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      _onGeofenceEvent(geofenceEvent);
      break;

    /*
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent activityChangeEvent = headlessEvent.event;
      _onActivityEvent(activityChangeEvent);
      break;
    */

    default:
      break;
  }
}

void _onGeofenceEvent(
  bg.GeofenceEvent event,
) {
  bg.BackgroundGeolocation.state.then((bg.State state) async {
    String url = state.extras['message_endpoint'];
    if (url != null) {
      String authToken = getAuthToken(state.headers['Authorization']);
      Map<String, dynamic> messageData = Map<String, dynamic>();
      messageData['identifier'] = event.identifier;
      messageData['action'] = event.action;
      messageData['location'] = event.location.toMap();
      await sendMessage(url, authToken, messageData);
    }
  });
}

void _onLocationError(
  bg.LocationError error,
) {
  // TODO: Sentry?
  logger.e('[location] ERROR - $error');

  /*
  store.dispatch(SendMessageAction(
    Message(
      message: 'Location Error...',
      bottomOffset: 53.0,
    ),
  ));
  */
}

void _onHeartbeatEvent(
  bg.HeartbeatEvent event,
) async {
  bg.BackgroundGeolocation.state.then((bg.State state) async {
    String url = state.extras['user_endpoint'];
    if (url != null) {
      String authToken = getAuthToken(state.headers['Authorization']);
      Map<String, dynamic> userData = Map<String, dynamic>();
      // userData['location'] = (await bg.BackgroundGeolocation.getCurrentPosition()).toMap();
      userData['provider'] = await _getProviderData();
      userData['connectivity'] = await getConnectionData();
      userData['battery'] = {
        'level': (event.location.battery.level * 100.0),
        'charging': event.location.battery.isCharging,
      };
      await updateUserData(url, authToken, userData);
    }
  });
}

Future<Map<String, dynamic>> _getProviderData() async {
  bg.ProviderChangeEvent provider =
      await bg.BackgroundGeolocation.providerState;
  return provider.toMap();
}

void _onProviderChangeEvent(
  bg.ProviderChangeEvent event,
) async {
  bg.BackgroundGeolocation.state.then((bg.State state) async {
    String url = state.extras['user_endpoint'];
    if (url != null) {
      String authToken = getAuthToken(state.headers['Authorization']);
      Map<String, dynamic> userData = Map<String, dynamic>();
      userData['provider'] = event.toMap();
      await updateUserData(url, authToken, userData);
    }
  });
}

Future<void> checkLocationPermissionStatus(
  final store,
  BuildContext context,
) async {
  if ((store.state.user != null) &&
      (store.state.locationPermissionStatus != PermissionStatus.granted)) {
    Map<String, dynamic> locationSharing = {};
    PermissionStatus status =
        await LocationPermissions().checkPermissionStatus();

    store.dispatch(SetLocationPermissionStatusAction(status));

    if (status == PermissionStatus.granted) {
      locationSharing = {
        'status': true,
        'sharing_disabled': null,
      };
    } else {
      await requestLocationPermission();

      PermissionStatus status =
          await LocationPermissions().checkPermissionStatus();

      store.dispatch(SetLocationPermissionStatusAction(status));

      if (status == PermissionStatus.granted) {
        locationSharing = {
          'status': true,
          'sharing_disabled': null,
        };
      } else {
        locationSharing = {
          'status': false,
          'sharing_disabled': getNow(),
        };
      }
    }

    store.dispatch(
      UpdateGroupMemberLocationSharingAction(
        store.state.user.activeGroup,
        {
          store.state.user.documentId: {
            'location_sharing': locationSharing,
          },
        },
        sendMessage: false,
      ),
    );

    // GroupsViewModel viewModel = GroupsViewModel.fromStore(store);
    // await getCurrentPosition(viewModel, store);
  }
}

Future<void> configureLocationSharing(
  GroupsViewModel viewModel,
) async {
  bg.State state = await bg.BackgroundGeolocation.state;
  GroupMember member = getGroupMember(viewModel.activeGroup, viewModel.user);
  if ((state.enabled &&
      (member != null) &&
      (!locationSharingEnabled(member)))) {
    bg.BackgroundGeolocation.stop();
    logger.d('Location sharing has been disabled');
  }
}

Future<void> buildGeofences(
  List<Place> places,
) async {
  if ((places == null) || (places.length == 0)) {
    logger.d('Purging all geofences');
    await bg.BackgroundGeolocation.removeGeofences();
  } else {
    await Future.forEach(places, (place) async {
      bool exists =
          await bg.BackgroundGeolocation.geofenceExists(place.documentId);

      if (exists) {
        await bg.BackgroundGeolocation.removeGeofence(place.documentId);
        logger.d('Updating geofence ${place.documentId}');
      } else {
        logger.d('Adding geofence ${place.documentId}');
      }

      await bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: place.documentId,
          radius: place.distance,
          latitude: place.details.position[0],
          longitude: place.details.position[1],
          notifyOnEntry: true,
          notifyOnExit: true,
          notifyOnDwell: false,
        ),
      );
    });

    // Clean up the existing places that are stored in the location plugin db
    await bg.BackgroundGeolocation.geofences
        .then((List<bg.Geofence> geofences) async {
      await Future.forEach(geofences, (bg.Geofence geofence) async {
        if (places != null) {
          Place place = places.firstWhere(
            (Place place) => place.documentId == geofence.identifier,
            orElse: () => null,
          );

          if (place == null) {
            logger.d('Purging geofence ${geofence.identifier}');
            await bg.BackgroundGeolocation.removeGeofence(geofence.identifier);
          }
        }
      });
    });
  }
}

int getSpeed(
  Location location, {
  Timestamp lastUpdated,
  String uom = 'imperial',
}) {
  if ((location == null) || !location.isMoving) {
    return 0;
  }

  if (lastUpdated != null) {
    // If we haven't received an update in 30+ seconds then lets just assume
    // that the vehicle is not moving.
    Duration difference = getNow().difference(lastUpdated.toDate());
    if (difference.inSeconds > 30) {
      return 0;
    }
  }

  int speed = 0;
  double metersPerSecond = location.coords.speed.toDouble();

  switch (uom) {
    case 'metric':
      speed = (metersPerSecond * 3.6)
          .round(); // meters per second --> kilometers per hour
      break;

    case 'imperial':
    default:
      speed = (metersPerSecond * 2.237)
          .round(); // meters per second --> miles per hour
      break;
  }

  if (speed < 0) {
    return 0;
  }

  return speed;
}

String getSpeedText({
  String uom = 'imperial',
}) {
  String unit;

  switch (uom) {
    case 'metric':
      unit = 'KPH';
      break;

    case 'imperial':
    default:
      unit = 'MPH';
      break;
  }

  return unit;
}

int convertMeters(
  double value, {
  String uom = 'imperial',
}) {
  switch (uom) {
    case 'metric':
      return (value * 0.001).round(); // meters --> kilometers

    case 'imperial':
    default:
      return (value * 0.000621).round(); // meters --> miles
  }
}

String activityDistanceText(
  dynamic value, {
  String uom = 'imperial',
}) {
  String unit;

  if (value.runtimeType == int) {
    value = value.toDouble();
  }

  int distance = convertMeters(value, uom: uom);

  switch (uom) {
    case 'metric':
      unit = 'KM';
      break;

    case 'imperial':
    default:
      unit = ' Mile';
      break;
  }

  return '$distance$unit Drive'; // TODO Drive, Walk, Run, Ride...
}

String activityTimeText(
  Timestamp startTime,
  Timestamp endTime,
) {
  if ((startTime != null) && (endTime != null)) {
    String timeDiff;
    String formattedStartTime = formatTimestamp(startTime, 'h:mm a');
    String formattedEndTime = formatTimestamp(endTime, 'h:mm a');
    Duration difference = endTime.toDate().difference(startTime.toDate());
    if (difference.inMinutes > 60) {
      timeDiff = '${difference.inHours} hr';
    } else {
      timeDiff = '${difference.inMinutes} min';
    }

    return '$formattedStartTime - $formattedEndTime ($timeDiff)';
  }

  return null;
}

latlng.LatLng toLatLng(dynamic location) {
  if (location == null) {
    return null;
  }

  if (location.runtimeType.toString() == 'List<dynamic>') {
    return latlng.LatLng(
      location[0],
      location[1],
    );
  }

  return latlng.LatLng(
    location['coords']['latitude'],
    location['coords']['longitude'],
  );
}
