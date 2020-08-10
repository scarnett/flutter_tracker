import 'package:flutter/material.dart';

enum MessageType {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
}

class Message {
  String message;
  int duration;
  MessageType type;
  double iconSize;
  double padding;
  double bottomOffset;

  Message({
    this.message,
    this.duration: 2,
    this.type: MessageType.INFO,
    this.iconSize: 28.0,
    this.padding: 8.0,
    this.bottomOffset,
  });

  toString() => 'Message.$message';

  getIcon() {
    switch (this.type) {
      case MessageType.SUCCESS:
        return Icons.check_circle_outline;

      case MessageType.WARNING:
        return Icons.warning;

      case MessageType.ERROR:
        return Icons.error_outline;

      case MessageType.INFO:
      default:
        return Icons.info_outline;
    }
  }

  getIconColor() {
    switch (this.type) {
      case MessageType.SUCCESS:
        return Colors.green;

      case MessageType.WARNING:
        return Colors.orange;

      case MessageType.ERROR:
        return Colors.red;

      case MessageType.INFO:
      default:
        return Colors.pink;
    }
  }
}

enum PushMessageType {
  CHECKIN,
  JOIN_GROUP,
  LEAVE_GROUP,
  ENTERING_GEOFENCE,
  LEAVING_GEOFENCE,
  ACCOUNT_SUBSCRIBED,
  ACCOUNT_SUBSCRIPTION_UPDATED,
  ACCOUNT_UNSUBSCRIBED,
}
