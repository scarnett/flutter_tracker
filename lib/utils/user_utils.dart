import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/plan_utils.dart';

String getUserInitials(
  String name,
) {
  if (name == null) {
    return '';
  }

  List<String> parts = name.split(' ');
  if (parts.length == 1) {
    return name.substring(0, 1).toUpperCase();
  }

  String firstName = parts[0];
  String firstInitial = firstName.substring(0, 1).toUpperCase();

  String lastName = parts[parts.length - 1];
  String lastInitial = lastName.substring(0, 1).toUpperCase();
  return '$firstInitial $lastInitial';
}

bool isOnlineAndSharingLocation(
  dynamic user,
) {
  if (isOnline(user) && locationSharingEnabled(user)) {
    return true;
  }

  return false;
}

bool isOnline(
  dynamic user,
) {
  Provider provider;

  if ((user.runtimeType == User) || (user.runtimeType == GroupMember)) {
    provider = user.provider;
  }

  if ((provider != null) && (provider.enabled != null) && provider.enabled) {
    return true;
  }

  return false;
}

bool wifiConnected(
  dynamic user,
) {
  if ((user != null) &&
      (user.connectivity != null) &&
      (user.provider != null)) {
    if (((user.connectivity.status == 'wifi') && isOnline(user))) {
      return true;
    }
  }

  return false;
}

bool needsToChargeBattery(
  dynamic user,
) {
  if ((user.battery != null) &&
      (user.battery.level != null) &&
      (user.battery.level <= 25.0)) {
    return true;
  }

  return false;
}

Map<String, DateTime> getActivityRange(
  Plan plan,
) {
  String activity = getOptionValue(plan, 'activity');
  switch (activity) {
    case 'all':
      return {
        'start': DateTime.now().subtract(Duration(days: 365)),
        'end': DateTime.now(), // getLastDayOfWeek(offset: 0),
      };

    case 'month':
      return {
        'start': getDaysAgo(29),
        'end': DateTime.now(), // getLastDayOfWeek(offset: 0),
      };

    case 'day':
      return {
        'start': getToday(),
        'end': getTomorrow(),
      };

    case 'week':
    default:
      return {
        'start': getDaysAgo(6),
        'end': DateTime.now(), // getLastDayOfWeek(offset: 0),
      };
  }
}

bool locationSharingEnabled(
  dynamic user,
) {
  if ((user.locationSharing != null) &&
      (user.locationSharing.status != null) &&
      user.locationSharing.status) {
    return true;
  }

  return false;
}

bool activityDetectionEnabled(
  dynamic user,
) {
  if ((user.activityDetection != null) && user.activityDetection.status) {
    return true;
  }

  return false;
}

String cloudinaryTransformUrl(
  String imageUrl, {
  String transformation = 'avatar',
  List<String> extraOptions,
}) {
  if (imageUrl == null) {
    return null;
  }

  if (hasAlreadyBeenTransformed(imageUrl)) {
    return imageUrl;
  }

  List<String> urlParts = imageUrl.split('upload/');
  String options = '';

  if ((extraOptions != null) && (extraOptions.length > 0)) {
    for (String option in extraOptions) {
      options += ',$option';
    }
  }

  // Adds the cloudinary 'transformation' to the url
  String transformedUrl =
      '${urlParts[0]}upload/t_$transformation$options/${urlParts[1]}';
  return transformedUrl;
}

String cloudinaryTransformImage(
  CloudinaryImage image, {
  String transformation = 'avatar',
  List<String> extraOptions,
}) {
  if (image == null) {
    return null;
  }

  return cloudinaryTransformUrl(
    image.secureUrl,
    transformation: transformation,
    extraOptions: extraOptions,
  );
}

bool hasAlreadyBeenTransformed(
  String url,
) {
  if (url == null) {
    return false;
  }

  if (url.contains('upload/t_')) {
    return true;
  }

  return false;
}

dynamic activityFromJsonList(
  dynamic list,
) {
  if (list == null) {
    return [];
  } else if (list.runtimeType != List) {
    return list;
  }

  List<dynamic> activity = List<dynamic>();

  list.forEach((data) {
    activity..add(data);
  });

  return activity;
}

IconData getActivityIcon(
  ActivityType type,
) {
  switch (type) {
    case ActivityType.ON_FOOT:
    case ActivityType.WALKING:
      return Icons.directions_walk;
      break;

    case ActivityType.RUNNING:
      return Icons.directions_run;
      break;

    case ActivityType.IN_VEHICLE:
      return Icons.directions_car;
      break;

    case ActivityType.ON_BICYCLE:
      return Icons.directions_bike;

    default:
      return null;
  }
}
