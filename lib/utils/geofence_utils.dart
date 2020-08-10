import 'package:flutter_tracker/model/message.dart';

PushMessageType getMessageType(
  String event,
) {
  if (event == null) {
    return null;
  }

  switch (event) {
    case 'ENTER':
      return PushMessageType.ENTERING_GEOFENCE;

    case 'EXIT':
      return PushMessageType.LEAVING_GEOFENCE;

    default:
      return null;
  }
}
