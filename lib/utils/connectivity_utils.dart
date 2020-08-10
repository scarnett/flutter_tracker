import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/services/users.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';

final Connectivity _connectivity = Connectivity();

Future<Map<String, dynamic>> getConnectionData({
  String authToken,
  ConnectivityResult result,
}) async {
  if (authToken == null) {
    bg.State state = await bg.BackgroundGeolocation.state;
    authToken = getAuthToken(state.headers['Authorization']);
  }

  if (result == null) {
    result = await _connectivity.checkConnectivity();
  }

  Map<String, dynamic> data = Map<String, dynamic>();
  data['status'] = result.toString().split('.')[1];

  switch (result) {
    case ConnectivityResult.wifi:
      try {
        data['wifi_name'] = await _connectivity.getWifiName();
      } on PlatformException {
        // logger.e(e);
      }

      try {
        data['wifi_bssid'] = await _connectivity.getWifiBSSID();
      } on PlatformException {
        // logger.e(e);
      }

      try {
        data['wifi_ip'] = await _connectivity.getWifiIP();
      } on PlatformException {
        // logger.e(e);
      }

      break;

    case ConnectivityResult.mobile:
    case ConnectivityResult.none:
      data['wifi_name'] = null;
      data['wifi_bssid'] = null;
      data['wifi_ip'] = null;
      break;

    default:
      break;
  }

  return data;
}

Future<void> updateConnectionStatus(
  ConnectivityResult result,
  RemoteConfig remoteConfig,
  final store,
) async {
  if (store.state.user != null) {
    bg.BackgroundGeolocation.state.then((state) async {
      Map<String, dynamic> connectivity =
          await getConnectionData(result: result);

      if (isAppActive(store.state.appState)) {
        store.dispatch(UpdateFamilyDataEventAction(
          family: {
            'connectivity': connectivity,
          },
          userId: store.state.user.documentId,
        ));
      } else {
        String endpointUrl = state.extras['user_endpoint'];
        if ((endpointUrl != null) && (endpointUrl != '')) {
          String authToken = getAuthToken(state.headers['Authorization']);
          Map<String, dynamic> userData = Map<String, dynamic>();
          userData['connectivity'] = connectivity;
          await updateUserData(endpointUrl, authToken, userData);
        }
      }
    });
  }
}
