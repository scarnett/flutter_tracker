import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/common_utils.dart';

Logger logger = Logger();

bool isAdministrator(
  Group group,
  User user,
) {
  return ((group != null) &&
      (group.admins != null) &&
      group.admins.contains(user.documentId));
}

String getAuthToken(
  String authHeader,
) {
  if ((authHeader != null) && authHeader.startsWith('Bearer ')) {
    List<String> authHeaderParts = authHeader.split(' ');
    if (authHeaderParts.length == 2) {
      String authToken = authHeaderParts[1];
      return authToken;
    }
  }

  return null;
}

void onSignedIn(
  String email,
  String password,
) async {
  // ...
}

void onSignedOut(
  final store,
) async {
  store.dispatch(ClearUserAction());
  store.dispatch(SetAuthStatusAction(AuthStatus.NOT_LOGGED_IN));
}

// TODO: Fix this
void doSignOut(
  final store,
) async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    _firebaseAuth.signOut().then((value) {
      store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
      store.dispatch(CancelFamilyDataEventsAction());
      store.dispatch(CancelGroupsDataEventsAction());
      onSignedOut(store);
      store.dispatch(NavigateReplaceAction(AppRoutes.home));
    }).catchError((onError) => logger.e(onError)); // TODO
  } catch (e) {
    logger.e(e); // TODO
  }
}
