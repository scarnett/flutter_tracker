import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';

Widget bannerAd(
  GroupsViewModel viewModel,
) {
  return Container(
    alignment: Alignment.center,
    width: double.infinity,
    padding: const EdgeInsets.only(
      top: 20.0,
      bottom: 20.0,
    ),
    child: AdmobBanner(
      adUnitId: getBannerAdUnitId(viewModel),
      adSize: AdmobBannerSize.BANNER,
    ),
  );
}

List<T> injectAd<T>(
  List<dynamic> list,
  dynamic ad, {
  int minEntriesNeeded: 10,
}) {
  if (list == null) {
    return null;
  }

  if (list.length > minEntriesNeeded) {
    List<T> _list = List<T>.from(list);
    _list.insert((_list.length ~/ 2), ad);
    return _list;
  }

  return list;
}

/*
Test Id's from:
@see https://developers.google.com/admob/ios/banner
@see https://developers.google.com/admob/android/banner
*/

String getAppId(
  String androidAppId,
  String iosAppId,
) {
  if (Platform.isIOS) {
    return androidAppId;
  } else if (Platform.isAndroid) {
    return iosAppId;
  }

  return null;
}

String getBannerAdUnitId(
  GroupsViewModel viewModel,
) {
  if (Platform.isIOS) {
    return viewModel.configValue('admob_ios_banner');
  } else if (Platform.isAndroid) {
    return viewModel.configValue('admob_android_banner');
  }

  return null;
}

String getInterstitialAdUnitId(
  GroupsViewModel viewModel,
) {
  if (Platform.isIOS) {
    return viewModel.configValue('admob_ios_interstitial');
  } else if (Platform.isAndroid) {
    return viewModel.configValue('admob_android_interstitial');
  }

  return null;
}

String getRewardBasedVideoAdUnitId(
  GroupsViewModel viewModel,
) {
  if (Platform.isIOS) {
    return viewModel.configValue('admob_ios_video_reward');
  } else if (Platform.isAndroid) {
    return viewModel.configValue('admob_android_video_reward');
  }

  return null;
}
