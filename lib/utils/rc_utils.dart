import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/config.dart';

Future<RemoteConfig> setupRemoteConfig(
  BuildContext context,
) async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  remoteConfig.setConfigSettings(RemoteConfigSettings(
    debugMode: AppConfig.isDebug(context),
  ));

  remoteConfig.setDefaults(<String, dynamic>{
    'places_radius': 50000,
    'invite_code_valid_days': 5,
    'nearby_distance_update': 2500,
    'mapbox_id': '',
    'mapbox_key': '',
    'mapbox_url_template': '',
    'places_url': '',
    'places_explore_nearby_url': '',
    'places_api_id': '',
    'places_app_code': '',
    'reverse_geocode_url': '',
    'cloudinary_url': '',
    'cloudinary_secret': '',
    'cloudinary_key': '',
    'cloudinary_public_id': '',
    'user_endpoint_url': '',
    'message_endpoint_url': '',
    'cancel_subscription_endpoint_url': '',
    'picture_folder': '',
    'privacy_policy_url': '',
    'admob_ios_video_reward': '',
    'admob_ios_interstitial': '',
    'admob_ios_banner': '',
    'admob_android_video_reward': '',
    'admob_android_interstitial': '',
    'admob_android_banner': '',
  });

  return remoteConfig;
}

/*
   * Fetches the remote firebase config from
   */
Future<void> initRemoteConfig(
  RemoteConfig remoteConfig,
  final store,
) async {
  if (remoteConfig != null) {
    await remoteConfig.fetch(expiration: const Duration(hours: 5));
    await remoteConfig.activateFetched();

    store.dispatch(SetAppConfigurationAction({
      'invite_code_valid_days': remoteConfig.getInt('invite_code_valid_days'),
      'nearby_distance_update': remoteConfig.getInt('nearby_distance_update'),
      'places_url': remoteConfig.getString('places_url'),
      'places_explore_nearby_url':
          remoteConfig.getString('places_explore_nearby_url'),
      'places_api_id': remoteConfig.getString('places_api_id'),
      'places_app_code': remoteConfig.getString('places_app_code'),
      'places_radius': remoteConfig.getString('places_radius'),
      'reverse_geocode_url': remoteConfig.getString('reverse_geocode_url'),
      'mapbox_url_template': remoteConfig.getString('mapbox_url_template'),
      'mapbox_key': remoteConfig.getString('mapbox_key'),
      'mapbox_id': remoteConfig.getString('mapbox_id'),
      'cloudinary_url': remoteConfig.getString('cloudinary_url'),
      'cloudinary_secret': remoteConfig.getString('cloudinary_secret'),
      'cloudinary_key': remoteConfig.getString('cloudinary_key'),
      'cloudinary_public_id': remoteConfig.getString('cloudinary_public_id'),
      'user_endpoint_url': remoteConfig.getString('user_endpoint_url'),
      'message_endpoint_url': remoteConfig.getString('message_endpoint_url'),
      'cancel_subscription_endpoint_url':
          remoteConfig.getString('cancel_subscription_endpoint_url'),
      'picture_folder': remoteConfig.getString('picture_folder'),
      'privacy_policy_url': remoteConfig.getString('privacy_policy_url'),
      'admob_ios_video_reward':
          remoteConfig.getString('admob_ios_video_reward'),
      'admob_ios_interstitial':
          remoteConfig.getString('admob_ios_interstitial'),
      'admob_ios_banner': remoteConfig.getString('admob_ios_banner'),
      'admob_android_video_reward':
          remoteConfig.getString('admob_android_video_reward'),
      'admob_android_interstitial':
          remoteConfig.getString('admob_android_interstitial'),
      'admob_android_banner': remoteConfig.getString('admob_android_banner'),
    }));
  }
}
