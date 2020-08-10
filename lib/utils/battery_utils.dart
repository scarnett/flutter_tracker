import 'package:battery/battery.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/services/users.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';

updateBatteryState(
  Battery battery,
  BatteryState batteryState,
  RemoteConfig remoteConfig,
  final store,
) {
  if (store.state.user != null) {
    bg.BackgroundGeolocation.state.then((state) async {
      Map<String, dynamic> data = Map<String, dynamic>();

      try {
        data['level'] = await battery.batteryLevel;
      } on PlatformException catch (e) {
        logger.e(e);
      }

      switch (batteryState) {
        case BatteryState.charging:
          data['charging'] = true;
          break;

        case BatteryState.full:
        case BatteryState.discharging:
        default:
          data['charging'] = false;
          break;
      }

      if (isAppActive(store.state.appState)) {
        store.dispatch(UpdateFamilyDataEventAction(
          family: {
            'battery': data,
          },
          userId: store.state.user.documentId,
        ));
      } else {
        String url = remoteConfig.getString('user_endpoint_url');
        if ((url != null) && (url != '')) {
          String authToken = getAuthToken(state.headers['Authorization']);
          Map<String, dynamic> userData = Map<String, dynamic>();
          userData['battery'] = data;
          await updateUserData(url, authToken, userData);
        }
      }
    });
  }
}
