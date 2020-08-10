import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final String token;
  // final Timestamp tokenExpires;
  // final Timestamp tokenIssued;
  // final Timestamp lastSeen;

  Auth({
    this.token,
    // this.tokenExpires,
    // this.tokenIssued,
    // this.lastSeen,
  });

  factory Auth.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Auth(
      token: json['token'],
      // tokenExpires: json['token_expires'],
      // tokenIssued: json['token_issued'],
      // lastSeen: json['last_seen'],
    );
  }

  factory Auth.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    return Auth(
      token: snapshot['token'],
      // tokenExpires: snapshot['token_expires'],
      // tokenIssued: snapshot['token_issued'],
      // lastSeen: snapshot['last_seen'],
    );
  }
}

enum AuthStatus {
  NOT_DETERMINED,
  ONBOARDING,
  NOT_LOGGED_IN,
  LOGGED_IN,
  NEEDS_ACCOUNT_VERIFICATION,
}
