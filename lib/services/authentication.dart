import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/message.dart';

abstract class BaseAuthService {
  Future<FirebaseUser> signIn(
    String email,
    String password,
  );

  Future<FirebaseUser> signUp(
    String name,
    String email,
    String password, {
    store,
  });

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification({
    store,
  });

  Future<void> signOut();
  Future<bool> isEmailVerified();
  Future<void> resetPassword(
    String email, {
    store,
    bottomOffset,
  });
}

class AuthService implements BaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  listen() {
    _firebaseAuth.onAuthStateChanged.listen((firebaseUser) {
      // ...
    });
  }

  @override
  Future<FirebaseUser> signIn(
    String email,
    String password,
  ) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  @override
  Future<FirebaseUser> signUp(
    String name,
    String email,
    String password, {
    store,
  }) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    FirebaseUser user = result.user;

    // Update the displayName in the firebase user record
    if (name != null) {
      UserUpdateInfo userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = name;

      await user.updateProfile(userUpdateInfo);
      await user.reload();
      user = await _firebaseAuth.currentUser();
    }

    return user;
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendEmailVerification({store}) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();

    if (store != null) {
      store.dispatch(
        SendMessageAction(
          Message(
            message: 'Account verification email sent!',
          ),
        ),
      );
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  @override
  Future<void> resetPassword(
    String email, {
    store,
    bottomOffset,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);

    if (store != null) {
      store.dispatch(
        SendMessageAction(
          Message(
            message: 'Reset password email sent!',
            bottomOffset: bottomOffset,
          ),
        ),
      );
    }
  }
}
