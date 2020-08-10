import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/icon_utils.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timeago/timeago.dart' as timeago;

Logger logger = Logger();

Future<void> listenFormPushMessages(
  BuildContext context,
  final store, {
  String userId,
}) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.configure(
    // onBackgroundMessage: Platform.isIOS ? null : backgroundMessageHandler,
    onMessage: (Map<String, dynamic> message) async {
      logger.d('onMessage: $message');
      showMessage(context, store, message);
    },
    onLaunch: (Map<String, dynamic> message) async {
      logger.d('onLaunch: $message');
      showMessage(context, store, message);
    },
    onResume: (Map<String, dynamic> message) async {
      logger.d('onResume: $message');
      showMessage(context, store, message);
    },
  );

  _firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ),
  );

  // TODO: IOS
  /*
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    // logger.d('Settings registered: $settings');
  });
  */

  if (userId != null) {
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      store.dispatch(UpdateFamilyDataEventAction(
        family: {
          'fcm': {
            'token': token,
          },
        },
        userId: userId,
      ));
    });
  }
}

Future<dynamic> backgroundMessageHandler(
  Map<String, dynamic> message,
) {
  // ...
  return Future<Null>.value(null);
}

void showMessage(
  BuildContext context,
  final store,
  Map<String, dynamic> message,
) {
  switch (message['data']['type']) {
    case 'CHECKIN':
    case 'JOIN_GROUP':
    case 'LEAVE_GROUP':
    case 'ENTERING_GEOFENCE':
    case 'LEAVING_GEOFENCE':
      _showUserMessage(context, store, message);
      break;

    case 'ACCOUNT_SUBSCRIBED':
    case 'ACCOUNT_SUBSCRIPTION_UPDATED':
    case 'ACCOUNT_UNSUBSCRIBED':
      _showGeneralMessage(context, store, message);
      break;

    default:
      break;
  }
}

void _showGeneralMessage(
  BuildContext context,
  final store,
  Map<String, dynamic> message,
) {
  Alert(
    context: context,
    title: message['notification']['title'],
    content: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            bottom: 20.0,
          ),
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getMaterialIcon(message['data']['icon']),
              color: Colors.white,
              size: 100.0,
            ),
          ),
        ),
        Center(
          child: Text(
            message['notification']['body'],
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    style: AlertStyle(
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      descStyle: const TextStyle(
        color: Colors.black38,
        fontStyle: FontStyle.normal,
        fontSize: 14.0,
        height: 1.5,
      ),
    ),
    closeFunction: () {},
    buttons: [
      DialogButton(
        child: Text(
          'OK',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.primary,
      ),
    ],
  ).show();
}

void _showUserMessage(
  BuildContext context,
  final store,
  Map<String, dynamic> message,
) {
  Alert(
    context: context,
    title: message['notification']['title'],
    content: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            bottom: 20.0,
          ),
          child: UserAvatar(
            user: User(
              name: message['data']['fromUserName'],
              provider: Provider.fromJson({
                'enabled':
                    true, // Forces the avatar to appear to be online (prevents the grayscale)
              }),
            ),
            imageUrl: message['data']['fromUserImage'],
            avatarRadius: 48.0,
            onTap: () => _tapViewUser(context, store, message),
          ),
        ),
        Center(
          child: Text(
            message['notification']['body'],
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 5.0,
          ),
          child: Center(
            child: Text(
              timeago.format(
                  epochToDateTime(int.parse(message['data']['send_date']))),
              style: TextStyle(
                color: AppTheme.hint,
                fontSize: 12.0,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
    style: AlertStyle(
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      descStyle: const TextStyle(
        color: Colors.black38,
        fontStyle: FontStyle.normal,
        fontSize: 14.0,
        height: 1.5,
      ),
    ),
    closeFunction: () {},
    buttons: [
      DialogButton(
        child: Text(
          'OK',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.primary,
      ),
      DialogButton(
        child: Text(
          'View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        onPressed: () => _tapViewUser(context, store, message),
        color: AppTheme.secondary,
      ),
    ],
  ).show();
}

Flushbar buildToastMessage(
  Message message,
) {
  return Flushbar(
    message: message.message,
    duration: Duration(seconds: message.duration),
    forwardAnimationCurve: Curves.elasticOut,
    reverseAnimationCurve: Curves.decelerate,
    animationDuration: const Duration(milliseconds: 150),
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    icon: Icon(
      message.getIcon(),
      size: message.iconSize,
      color: message.getIconColor(),
    ),
    shouldIconPulse: false,
    margin: EdgeInsets.only(
      left: message.padding,
      right: message.padding,
      bottom: message.bottomOffset ?? message.padding,
    ),
  );
}

/*
   * Listens for messages and displays them using Flushbar
   */
void listenForToastMessages(
  BuildContext context,
  final store,
) async {
  if ((store.state != null) && (store.state.message != null)) {
    Message message = store.state.message;
    store.dispatch(ClearMessageAction());

    await Future.delayed(const Duration(milliseconds: 25), () {
      buildToastMessage(message)
        ..onStatusChanged = (
          FlushbarStatus status,
        ) {
          switch (status) {
            case FlushbarStatus.DISMISSED:
              // Clear the message after the toast has been dismissed
              // store.dispatch(ClearMessageAction());
              break;

            default:
              break;
          }
        }
        ..show(context);
    });
  }
}

void _tapViewUser(
  BuildContext context,
  final store,
  Map<String, dynamic> message,
) {
  String groupId = message['data']['groupId'];
  String groupMemberId = message['data']['fromUid'];
  store.dispatch(ActivateGroupAction(groupId));
  store.dispatch(ActivateGroupMemberAction(groupMemberId));
  store.dispatch(CancelUserActivityAction());
  store.dispatch(RequestUserActivityDataAction(groupMemberId));
  Navigator.pop(context);
}
