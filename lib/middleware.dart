import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/cloudinary.dart';
import 'package:flutter_tracker/services/places.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/iap_utils.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/widgets/pages.dart';
import 'package:latlong/latlong.dart' as latlong;
import 'package:redux_epics/redux_epics.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

Logger logger = Logger();

final allEpics = combineEpics<AppState>([
  requestPurchasesEpic,
  requestOnboardingEpic,
  requestProductsEpic,
  requestProductsSuccessEpic,
  savePurchaseDetailsEpic,
  requestPlansEpic,
  requestUserEpic,
  // requestUserSuccessEpic,
  requestUserActivityEpic,
  requestGroupsEpic,
  requestGroupByInviteCodeEpic,
  updateFamilyEpic,
  saveAccountEpic,
  saveAccountSuccessEpic,
  saveAccountErrorEpic,
  deleteAccountEpic,
  deleteAccountSuccessEpic,
  deleteAccountErrorEpic,
  activateGroupEpic,
  activateGroupSuccessEpic,
  activateGroupMemberEpic,
  clearActiveGroupMemberEpic,
  saveGroupEpic,
  saveGroupSuccessEpic,
  updateGroupEpic,
  updateGroupSuccessEpic,
  updateGroupMemberLocationSharingEpic,
  updateGroupMemberLocationSharingSuccessEpic,
  updateGroupMemberLocationSharingErrorEpic,
  updateGroupMemberActivityDetectionEpic,
  updateGroupMemberActivityDetectionSuccessEpic,
  updateGroupMemberActivityDetectionErrorEpic,
  updateGroupMemberSettingsEpic,
  updateGroupMemberSettingsSuccessEpic,
  updateGroupMemberSettingsErrorEpic,
  joinGroupSuccessEpic,
  joinGroupErrorEpic,
  joinGroupConfirmedEpic,
  joinGroupConfirmedSuccessEpic,
  joinGroupConfirmedErrorEpic,
  leaveGroupEpic,
  leaveGroupSuccessEpic,
  saveGroupAdministratorsEpic,
  saveGroupAdministratorsSuccessEpic,
  removeGroupMemberEpic,
  removeGroupMemberSuccessEpic,
  saveInviteCodeEpic,
  setMapDataEpic,
  requestPlacesEpic,
  requestPlacesSuccessEpic,
  requestPlaceActivityEpic,
  requestGroupPlacesEpic,
  requestGroupPlacesSuccessEpic,
  queryPlacesEpic,
  updateActivePlaceEpic,
  savePlaceEpic,
  savePlaceSuccessEpic,
  savePlaceErrorEpic,
  updatePlaceEpic,
  updatePlaceSuccessEpic,
  updatePlaceErrorEpic,
  deletePlaceEpic,
  deletePlaceSuccessEpic,
  pushMessageEpic,
  pushMessageSuccessEpic,
  pushMessageErrorEpic,
  saveCloudinaryEpic,
  saveCloudinarySuccessEpic,
  saveCloudinaryErrorEpic,
  requestMapsEpic,
  requestNearByPlacesEpic,
  requestNearByPlacesSuccessEpic,
  requestNearByPlacesErrorEpic,
]);

Stream requestPurchasesEpic(
  Stream actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestPurchasesAction>()
      .switchMap((RequestPurchasesAction requestAction) {
    return Stream.fromFuture(InAppPurchaseConnection.instance
        .queryPastPurchases()
        .then((res) => RequestPurchasesSuccessAction(res.pastPurchases))
        .catchError((error) => RequestPurchasesFailureAction(error)));
  });
}

Stream<dynamic> requestOnboardingEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestOnboardingAction>()
      .switchMap((RequestOnboardingAction requestAction) {
    return getOnboardingDocs()
        .map((onboardingPages) =>
            RequestOnboardingSuccessAction(onboardingPages))
        .takeUntil(
          actions.where((action) => action is CancelOnboardingAction),
        )
        .doOnError((error, stacktrace) => logger.e(error));
  });
}

Stream<List<PageModel>> getOnboardingDocs() {
  return Firestore.instance
      .collection('onboarding')
      .orderBy('sequence', descending: false)
      .snapshots()
      .map((QuerySnapshot doc) => oboarding(doc));
}

List<PageModel> oboarding(
  QuerySnapshot doc,
) {
  List<PageModel> activity = List<PageModel>();

  for (DocumentSnapshot document in doc.documents) {
    activity..add(PageModel.fromSnapshot(document));
  }

  return activity;
}

Stream<dynamic> requestProductsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestProductsAction>()
      .switchMap((RequestProductsAction action) {
    return getProductDocs(store.state.user)
        .map((products) => RequestProductsSuccessAction(products))
        .takeUntil(
          actions.where((action) => action is CancelRequestProductsAction),
        )
        .doOnError((error, stacktrace) =>
            RequestProductsFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestProductsSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestProductsSuccessAction>()
      .flatMap((payload) => () async* {
            yield getProductDetails(payload.products)
                .then((List<ProductDetails> productDetails) async {
              List<Product> products = payload.products;
              bool available =
                  await InAppPurchaseConnection.instance.isAvailable();
              if (available) {
                if (productDetails.length > 0) {
                  products.forEach((Product product) {
                    // Add the app store product details to the store
                    product.details = productDetails.firstWhere(
                        (ProductDetails details) => details.id == product.id);
                  });
                }
              }

              return SaveProductDetailsAction(products);
            });
          }());
}

Stream<List<Product>> getProductDocs(
  User user,
) {
  return Firestore.instance
      .collection('products')
      .where('enabled', isEqualTo: true)
      .snapshots()
      .map((QuerySnapshot doc) => products(user, doc));
}

List<Product> products(
  User user,
  QuerySnapshot doc,
) {
  List<Product> list = List<Product>();

  for (DocumentSnapshot document in doc.documents) {
    Product product = Product.fromSnapshot(document);
    list..add(product);
  }

  return list;
}

Stream<dynamic> savePurchaseDetailsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SavePurchaseDetailsAction>().flatMap((payload) {
    PurchaseWrapper billingClientPurchase =
        payload.purchaseDetails.billingClientPurchase;
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document(store.state.user.documentId)
        .updateData({
          'purchase': {
            'order_id': billingClientPurchase.orderId,
            'package_name': billingClientPurchase.packageName,
            'purchase_time': billingClientPurchase.purchaseTime,
            'purchase_token': billingClientPurchase.purchaseToken,
            'sku': billingClientPurchase.sku,
            'is_auto_renewing': billingClientPurchase.isAutoRenewing,
            'original_json': billingClientPurchase.originalJson,
          },
        })
        .then<dynamic>((res) => SavePurchaseDetailsSuccessAction())
        .catchError((error) => SavePurchaseDetailsErrorAction(error)));
  });
}

Stream<dynamic> requestPlansEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestPlansAction>()
      .switchMap((RequestPlansAction action) {
    return getPlanDocs()
        .map((plans) => RequestPlansSuccessAction(plans))
        .doOnError((error, stacktrace) =>
            RequestPlansFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestUserEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestFamilyDataAction>()
      .switchMap((RequestFamilyDataAction action) {
    return getUserDoc(action.userId)
        .map((user) => RequestFamilyDataSuccessAction(user))
        .takeUntil(
          actions.where((action) => action is CancelFamilyDataEventsAction),
        )
        .doOnError((error, stacktrace) =>
            RequestFamilyDataFailureAction(error, stacktrace));
  });
}

/*
Stream<dynamic> requestUserSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestFamilyDataSuccessAction>()
      .switchMap((RequestFamilyDataSuccessAction action) {
    return getPlanDoc(action.user.subscription.plan)
        .map((plan) =>
            RequestPlanSuccessAction(store.state.user.documentId, plan))
        .doOnError(
            (error, stacktrace) => RequestPlanFailureAction(error, stacktrace));
  });
}
*/

Stream<List<Plan>> getPlanDocs() {
  return Firestore.instance
      .collection('plans')
      .orderBy('sequence', descending: false)
      .snapshots()
      .map((QuerySnapshot doc) => plans(doc));
}

List<Plan> plans(
  QuerySnapshot doc,
) {
  List<Plan> plans = List<Plan>();

  for (DocumentSnapshot document in doc.documents) {
    plans..add(Plan.fromSnapshot(document));
  }

  return plans;
}

Stream<Plan> getPlanDoc(
  String planId,
) {
  return Firestore.instance
      .collection('plans')
      .document(planId)
      .snapshots()
      .map((DocumentSnapshot doc) => Plan.fromSnapshot(doc));
}

Stream<dynamic> requestUserActivityEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestUserActivityDataAction>()
      .switchMap((RequestUserActivityDataAction requestAction) {
    return getUserActivityDocs(
      requestAction.uid,
      startGt: requestAction.startGt,
      endLte: requestAction.endLte,
    )
        .map((activity) =>
            RequestUserActivitySuccessAction(requestAction.uid, activity))
        .takeUntil(
          actions.where((action) => action is CancelUserActivityAction),
        )
        .doOnError((error, stacktrace) =>
            RequestUserActivityFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestGroupsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestGroupsDataAction>()
      .switchMap((RequestGroupsDataAction action) {
    return getGroups(action.userId)
        .map((groups) => RequestGroupsDataSuccessAction(groups))
        .takeUntil(
          actions.where((action) => action is CancelGroupsDataEventsAction),
        )
        .doOnError((error, stacktrace) =>
            RequestGroupsDataFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestGroupByInviteCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<RequestGroupByInviteCodeAction>().flatMap((payload) {
    return Firestore.instance
        .collection('groups')
        .where('invite.code', isEqualTo: payload.inviteCode)
        .where('deleted', isEqualTo: false)
        .snapshots()
        .map((QuerySnapshot doc) => (doc.documents.length > 0)
            ? Group.fromSnapshot(doc.documents.first)
            : null)
        .map((group) => (group != null)
            ? JoinGroupSuccessAction(
                group,
              )
            : JoinGroupErrorAction(
                'err',
              ))
        .takeUntil(
          actions.where(
              (action) => action is CancelRequestGroupByInviteCodeEventsAction),
        )
        .doOnError((error, stacktrace) => RequestGroupByInviteCodeFailureAction(
              error,
              stacktrace,
            ));
  });
}

// TODO: Rename this
Stream<dynamic> updateFamilyEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<UpdateFamilyDataEventAction>().flatMap((payload) {
    Map<String, dynamic> data = {}
      ..addAll(payload.family)
      ..addAll({
        'last_updated': Timestamp.fromDate(getNow()),
      });

    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document((payload.userId == null)
            ? store.state.user.documentId
            : payload.userId)
        .updateData(data)
        .then<dynamic>((res) => UpdateFamilySuccessAction())
        .catchError((error) => UpdateFamilyErrorEventAction(error)));
  });
}

Stream<User> getUserDoc(
  String userId,
) {
  return Firestore.instance
      .collection('users')
      .document(userId)
      .snapshots()
      .map((DocumentSnapshot doc) => User.fromSnapshot(doc));
}

Stream<List<UserActivity>> getUserActivityDocs(
  String userId, {
  DateTime startGt,
  DateTime endLte,
}) {
  Query query = Firestore.instance
      .collection('users')
      .document(userId)
      .collection('activity');
  // .where('active', isEqualTo: false); // Don't fetch active documents

  if ((startGt == null) || (endLte == null)) {
    query = query
        .where('start_time', isGreaterThan: toTimestamp(getToday()))
        .where('start_time', isLessThanOrEqualTo: toTimestamp(getTomorrow()));
  } else {
    query = query
        .where('start_time', isGreaterThan: toTimestamp(startGt))
        .where('start_time', isLessThanOrEqualTo: toTimestamp(endLte));
  }

  return query
      .orderBy('start_time', descending: true)
      .snapshots()
      .map((QuerySnapshot doc) => userActivity(doc));
}

List<UserActivity> userActivity(
  QuerySnapshot doc,
) {
  List<UserActivity> activity = List<UserActivity>();

  for (DocumentSnapshot document in doc.documents) {
    activity..add(UserActivity.fromSnapshot(document));
  }

  return activity;
}

Stream<dynamic> saveAccountEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SaveAccountAction>().flatMap((payload) {
    Map<String, dynamic> data = {}
      ..addAll(payload.data)
      ..addAll({
        'last_updated': Timestamp.fromDate(getNow()),
      });
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document((payload.userId == null)
            ? store.state.user.documentId
            : payload.userId)
        .updateData(data)
        .then<dynamic>((res) => SaveAccountSuccessAction(
            payload.data, payload.userId,
            animationController: payload.animationController))
        .catchError((error) => SaveAccountErrorAction(error)));
  });
}

Stream<dynamic> saveAccountSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveAccountSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield UpdatingUserAction(false);
            yield SendMessageAction(
              Message(
                message: 'Your account has been updated!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> saveAccountErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveAccountErrorAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield SendMessageAction(
              Message(
                message:
                    'Your account did not update properly. Please try again.',
              ),
            );
          }());
}

Stream<dynamic> deleteAccountEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<DeleteAccountAction>().flatMap((payload) {
    Map<String, dynamic> data = {}..addAll({
        'deleted': true,
        'last_updated': Timestamp.fromDate(getNow()),
      });
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document((payload.userId == null)
            ? store.state.user.documentId
            : payload.userId)
        .updateData(data)
        .then<dynamic>((res) => DeleteAccountSuccessAction(payload.userId))
        .catchError((error) => DeleteAccountErrorAction(error)));
  });
}

Stream<dynamic> deleteAccountSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<DeleteAccountSuccessAction>()
      .flatMap((payload) => () async* {
            yield CancelFamilyDataEventsAction();
            yield CancelGroupsDataEventsAction();
            yield ClearUserAction();
            yield SetAuthStatusAction(AuthStatus.ONBOARDING);
            yield SetSelectedTabIndexAction(TAB_HOME);
            yield NavigateReplaceAction(AppRoutes.home);
            yield SendMessageAction(
              Message(
                  message:
                      'Your account has been deleted. Sorry to see you go :('),
            );

            final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
            yield _firebaseAuth.signOut();
          }());
}

Stream<dynamic> deleteAccountErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<DeleteAccountErrorAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                  message:
                      'Your account did not delete properly. Please try again.'),
            );
          }());
}

List<Group> groups(
  QuerySnapshot doc,
) {
  List<Group> groups = List<Group>();

  for (DocumentSnapshot document in doc.documents) {
    groups..add(Group.fromSnapshot(document));
  }

  return groups;
}

Stream<List<Group>> getGroups(
  String userId,
) {
  return Firestore.instance
      .collection('groups')
      .where('member_index', arrayContains: userId)
      .where('deleted', isEqualTo: false)
      .snapshots()
      .map((QuerySnapshot doc) => groups(doc));
}

Stream<dynamic> activateGroupMemberEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<ActivateGroupMemberAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document(store.state.user.documentId)
        .updateData({'active_group_member': payload.groupMemberId})
        .then<dynamic>(
            (res) => ActivateGroupMemberSuccessAction(payload.groupMemberId))
        .catchError((error) => ActivateGroupMemberErrorAction(error)));
  });
}

Stream<dynamic> activateGroupEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<ActivateGroupAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document(store.state.user.documentId)
        .updateData({
          'active_group': payload.groupId,
          'active_group_member': null,
        })
        .then<dynamic>((res) => ActivateGroupSuccessAction(payload.groupId))
        .catchError((error) => ActivateGroupErrorAction(error)));
  });
}

Stream<dynamic> activateGroupSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<ActivateGroupSuccessAction>()
      .flatMap((payload) => () async* {
            yield RequestGroupPlacesAction(payload.groupId);
          }());
}

Stream<dynamic> clearActiveGroupMemberEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<ClearActiveGroupMemberAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document(store.state.user.documentId)
        .updateData({
          'active_group_member': null,
        })
        .then<dynamic>((res) => ClearActiveGroupMemberSuccessAction())
        .catchError((error) => ClearActiveGroupMemberErrorAction(error)));
  });
}

Stream<dynamic> saveGroupEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SaveGroupAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .add(Group().toMap(payload.group))
        .then<dynamic>((res) => SaveGroupSuccessAction(res.documentID))
        .catchError((error) => SaveGroupErrorAction(error)));
  });
}

Stream<dynamic> saveGroupSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveGroupSuccessAction>()
      .flatMap((payload) => () async* {
            yield ActivateGroupAction(payload.groupId);
            yield SetSelectedTabIndexAction(TAB_HOME);
            yield NavigateReplaceAction(AppRoutes.home);
            yield SendMessageAction(
              Message(
                message: 'Your new group was created successfully!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> updateGroupEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<UpdateGroupAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .updateData(payload.data)
        .then<dynamic>(
            (res) => UpdateGroupSuccessAction(payload.groupId, payload.data))
        .catchError((error) => UpdateGroupErrorAction(error)));
  });
}

Stream<dynamic> updateGroupSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupSuccessAction>()
      .flatMap((payload) => () async* {
            yield NavigatePopAction();
            yield SendMessageAction(
              Message(message: 'Your group was updated successfully!'),
            );
          }());
}

Stream<dynamic> updateGroupMemberLocationSharingEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberLocationSharingAction>()
      .flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .setData(
          {
            'members': payload.data,
            'last_updated': getNow(),
          },
          merge: true,
        )
        .then<dynamic>((res) => UpdateGroupMemberLocationSharingSuccessAction(
              payload.groupId,
              payload.data,
              sendMessage: payload.sendMessage,
            ))
        .catchError(
            (error) => UpdateGroupMemberLocationSharingErrorAction(error)));
  });
}

Stream<dynamic> updateGroupMemberLocationSharingSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberLocationSharingSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.sendMessage) {
              yield SendMessageAction(
                Message(
                    message:
                        'Your location sharing settings were updated successfully!'),
              );
            }
          }());
}

Stream<dynamic> updateGroupMemberLocationSharingErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberLocationSharingErrorAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                message:
                    'Your location sharing settings did not update properly. Please try again.',
                type: MessageType.ERROR,
              ),
            );
          }());
}

Stream<dynamic> updateGroupMemberActivityDetectionEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberActivityDetectionAction>()
      .flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .setData(
          {
            'members': payload.data,
            'last_updated': getNow(),
          },
          merge: true,
        )
        .then<dynamic>((res) => UpdateGroupMemberActivityDetectionSuccessAction(
            payload.groupId, payload.data))
        .catchError(
            (error) => UpdateGroupMemberActivityDetectionErrorAction(error)));
  });
}

Stream<dynamic> updateGroupMemberActivityDetectionSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberActivityDetectionSuccessAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                  message:
                      'Your activity detection settings were updated successfully!'),
            );
          }());
}

Stream<dynamic> updateGroupMemberActivityDetectionErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberActivityDetectionErrorAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                message:
                    'Your activity detection settings did not update properly. Please try again.',
                type: MessageType.ERROR,
              ),
            );
          }());
}

Stream<dynamic> updateGroupMemberSettingsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberSettingsAction>()
      .flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .setData(
          {
            'members': payload.data,
            'last_updated': getNow(),
          },
          merge: true,
        )
        .then<dynamic>((res) => UpdateGroupMemberSettingsSuccessAction(
            payload.groupId, payload.data))
        .catchError((error) => UpdateGroupMemberSettingsErrorAction(error)));
  });
}

Stream<dynamic> updateGroupMemberSettingsSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberSettingsSuccessAction>()
      .flatMap((payload) => () async* {
            yield NavigatePopAction();
            yield SendMessageAction(
              Message(message: 'Your settings were updated successfully!'),
            );
          }());
}

Stream<dynamic> updateGroupMemberSettingsErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdateGroupMemberSettingsErrorAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                message:
                    'Your settings did not update properly. Please try again.',
                type: MessageType.ERROR,
              ),
            );
          }());
}

Stream<dynamic> joinGroupSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<JoinGroupSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield CancelRequestGroupByInviteCodeEventsAction();
            yield SendMessageAction(
              Message(message: 'Please confirm this group before joining!'),
            );
          }());
}

Stream<dynamic> joinGroupErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<JoinGroupErrorAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield CancelRequestGroupByInviteCodeEventsAction();
            yield SendMessageAction(
              Message(message: 'Sorry, that invite code is invalid'),
            );
          }());
}

Stream<dynamic> joinGroupConfirmedEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<JoinGroupConfirmedAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.group.documentId)
        .updateData({
          'member_index': FieldValue.arrayUnion([payload.user.documentId]),
          'last_updated': getNow(),
        })
        .then<dynamic>((res) => JoinGroupConfirmedSuccessAction(
              payload.user,
              payload.group,
            ))
        .catchError((error) => JoinGroupConfirmedErrorAction(
              error,
            )));
  });
}

Stream<dynamic> joinGroupConfirmedSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<JoinGroupConfirmedSuccessAction>()
      .flatMap((payload) => () async* {
            yield CancelRequestGroupByInviteCodeEventsAction();
            yield ClearPendingGroupInviteAction();
            yield ActivateGroupAction(payload.group.documentId);
            yield SetSelectedTabIndexAction(TAB_HOME);
            yield NavigateReplaceAction(AppRoutes.home);

            // Notify the group owner
            yield PushMessageAction(
              store.state.user.documentId,
              payload.group.owner.uid,
              payload.group.documentId,
              PushMessageType.JOIN_GROUP,
            );

            yield SendMessageAction(
              Message(
                message: 'You successfully joined the group!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> joinGroupConfirmedErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<JoinGroupConfirmedErrorAction>()
      .flatMap((payload) => () async* {
            yield CancelRequestGroupByInviteCodeEventsAction();
            yield ClearPendingGroupInviteAction();
            yield SendMessageAction(
              Message(message: 'Sorry, there was an issue joining this group'),
            );
          }());
}

Stream<dynamic> leaveGroupEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<LeaveGroupAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.activeGroup.documentId)
        .updateData({
          'admins': FieldValue.arrayRemove([payload.user.documentId]),
          'member_index': FieldValue.arrayRemove([payload.user.documentId]),
          'last_updated': getNow(),
        })
        .then<dynamic>(
            (res) => LeaveGroupSuccessAction(payload.user, payload.activeGroup))
        .catchError((error) => LeaveGroupErrorAction(error)));
  });
}

Stream<dynamic> leaveGroupSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<LeaveGroupSuccessAction>()
      .flatMap((payload) => () async* {
            yield ActivateGroupAction(payload.user.primaryGroup);
            yield SetSelectedTabIndexAction(TAB_HOME);
            yield NavigateReplaceAction(AppRoutes.home);

            String userUid = store.state.user.documentId;
            String ownerUid = payload.activeGroup.owner.uid;
            if (userUid != ownerUid) {
              // Notify the group owner
              // TODO: Let firebase do this
              yield PushMessageAction(
                userUid,
                ownerUid,
                payload.activeGroup.documentId,
                PushMessageType.LEAVE_GROUP,
              );
            }

            yield SendMessageAction(
              Message(
                message: 'You successfully left the group!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> saveGroupAdministratorsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SaveGroupAdministratorsAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .updateData({
          'admins': payload.admins,
        })
        .then<dynamic>((res) => SaveGroupAdministratorsSuccessAction(
            payload.groupId, payload.admins))
        .catchError((error) => SaveGroupAdministratorsErrorAction(error)));
  });
}

Stream<dynamic> saveGroupAdministratorsSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveGroupAdministratorsSuccessAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(message: 'The group administrators have been updated!'),
            );
          }());
}

Stream<dynamic> removeGroupMemberEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<RemoveGroupMemberAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.group.documentId)
        .updateData({
          'member_index': FieldValue.arrayRemove([payload.member.uid]),
          'last_updated': getNow(),
        })
        .then<dynamic>((res) =>
            RemoveGroupMemberSuccessAction(payload.group, payload.member))
        .catchError((error) => RemoveGroupMemberErrorAction(error)));
  });
}

Stream<dynamic> removeGroupMemberSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RemoveGroupMemberSuccessAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(message: 'The group members have been updated!'),
            );
          }());
}

Stream<dynamic> saveInviteCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SaveInviteCodeAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('groups')
        .document(payload.groupId)
        .updateData(payload.invite)
        .then<dynamic>((res) => SaveInviteCodeSuccessAction(payload.invite))
        .catchError((error) => SaveInviteCodeErrorAction(error)));
  });
}

List<Middleware<AppState>> createNavigationMiddleware(
  navigatorKey,
) {
  return [
    TypedMiddleware<AppState, NavigateReplaceAction>(
      _navigatePushNamed(navigatorKey),
    ),
    TypedMiddleware<AppState, NavigatePushAction>(_navigate(navigatorKey)),
  ];
}

Middleware<AppState> _navigatePushNamed(
  navigatorKey,
) {
  return (
    Store<AppState> store,
    action,
    NextDispatcher next,
  ) {
    final routeName = (action as NavigateReplaceAction).route.path;
    // if (store.state.route.last != routeName) {
    navigatorKey.currentState.pushReplacementNamed(routeName);
    next(action);
  };
}

Middleware<AppState> _navigate(
  navigatorKey,
) {
  return (
    Store<AppState> store,
    action,
    NextDispatcher next,
  ) {
    final _action = (action as NavigatePushAction);
    final routeName = _action.route.path;
    // if (store.state.route.last != routeName) {
    navigatorKey.currentState.pushNamed(
      routeName,
      arguments: _action.arguments,
    );

    next(action);
  };
}

Stream<dynamic> setMapDataEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SetMapDataAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('users')
        .document(store.state.user.documentId)
        .updateData({
          'map_data': payload.mapData,
        })
        .then<dynamic>((res) => SetMapDataSuccessAction(payload.mapData))
        .catchError((error) => SetMapDataErrorAction(error)));
  });
}

Stream<dynamic> requestPlacesEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestPlacesAction>()
      .switchMap((RequestPlacesAction requestAction) {
    return getPlaces(requestAction.userId)
        .map((places) => RequestPlacesSuccessAction(places))
        .takeUntil(
          actions.where((action) => action is CancelPlacesEventsAction),
        )
        .doOnError((error, stacktrace) =>
            RequestPlacesFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestPlacesSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestPlacesSuccessAction>()
      .flatMap((payload) => () async* {
            // yield buildGeofences(payload.places);
          }());
}

Stream<dynamic> requestPlaceActivityEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestPlaceActivityAction>()
      .switchMap((RequestPlaceActivityAction requestAction) {
    return getPlaceActivityDocs(
      requestAction.placeId,
      startGt: requestAction.startGt,
      endLte: requestAction.endLte,
    )
        .map((activity) =>
            RequestPlaceActivitySuccessAction(requestAction.placeId, activity))
        .takeUntil(
          actions.where((action) => action is CancelPlaceActivityAction),
        )
        .doOnError((error, stacktrace) =>
            RequestPlaceActivityFailureAction(error, stacktrace));
  });
}

Stream<List<PlaceActivity>> getPlaceActivityDocs(
  String placeId, {
  DateTime startGt,
  DateTime endLte,
}) {
  Query query = Firestore.instance
      .collection('places')
      .document(placeId)
      .collection('activity');

  if ((startGt == null) || (endLte == null)) {
    query = query
        .where('created', isGreaterThan: toTimestamp(getToday()))
        .where('created', isLessThanOrEqualTo: toTimestamp(getTomorrow()));
  } else {
    query = query
        .where('created', isGreaterThan: toTimestamp(startGt))
        .where('created', isLessThanOrEqualTo: toTimestamp(endLte));
  }

  return query
      .orderBy('created', descending: true)
      .snapshots()
      .map((QuerySnapshot doc) => placeActivity(doc));
}

List<PlaceActivity> placeActivity(
  QuerySnapshot doc,
) {
  List<PlaceActivity> activity = List<PlaceActivity>();

  for (DocumentSnapshot document in doc.documents) {
    activity..add(PlaceActivity.fromSnapshot(document));
  }

  return activity;
}

Stream<dynamic> requestGroupPlacesEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestGroupPlacesAction>()
      .switchMap((RequestGroupPlacesAction requestAction) {
    return getGroupPlaces(requestAction.groupId)
        .map((places) => RequestGroupPlacesSuccessAction(places))
        .takeUntil(
          actions.where((action) => action is CancelGroupPlacesEventsAction),
        )
        .doOnError((error, stacktrace) =>
            RequestGroupPlacesFailureAction(error, stacktrace));
  });
}

Stream<dynamic> requestGroupPlacesSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestGroupPlacesSuccessAction>()
      .flatMap((payload) => () async* {
            yield buildGeofences(payload.places);
          }());
}

Stream<List<Place>> getPlaces(
  String userId,
) {
  return Firestore.instance
      .collection('places')
      .where('owner', isEqualTo: userId)
      .orderBy('name', descending: false)
      // .orderBy('created', descending: false)
      .snapshots()
      .map((QuerySnapshot doc) => places(doc));
}

Stream<List<Place>> getGroupPlaces(
  String groupId,
) {
  return Firestore.instance
      .collection('places')
      .where('group', isEqualTo: groupId)
      .orderBy('name', descending: false)
      // .orderBy('created', descending: false)
      .snapshots()
      .map((QuerySnapshot doc) => places(doc));
}

List<Place> places(
  QuerySnapshot doc,
) {
  List<Place> places = List<Place>();

  for (DocumentSnapshot document in doc.documents) {
    places..add(Place.fromSnapshot(document));
  }

  return places;
}

Stream<dynamic> queryPlacesEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<QueryPlacesAction>().flatMap((payload) {
    return Stream.fromFuture(PlacesService.get()
        .searchPlacesByCriteria(
          store.state.config,
          payload.criteria,
          payload.latLng,
        )
        .then<dynamic>((res) =>
            QueryPlacesSuccessAction(payload.criteria, payload.latLng, res))
        .catchError((error) => QueryPlacesErrorAction(error)));
  });
}

Stream<dynamic> updateActivePlaceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<UpdateActivePlaceAction>().flatMap((payload) {
    return Stream.fromFuture(PlacesService.get()
        .geocode(
      store.state.config,
      payload.latLng,
    )
        .then<dynamic>((res) {
      if (res != null) {
        return UpdateActivePlaceSuccessAction(res);
      }

      return UpdateActivePlaceErrorAction(null);
    }).catchError((error) => UpdateActivePlaceErrorAction(error)));
  });
}

Stream<dynamic> savePlaceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SavePlaceAction>().flatMap((payload) {
    if (payload.animationController != null) {
      payload.animationController.forward();
    }

    return Stream.fromFuture(Firestore.instance
        .collection('places')
        .add(Place().toMap(payload.place))
        .then<dynamic>((res) =>
            SavePlaceSuccessAction(payload.place, payload.animationController))
        .catchError((error) =>
            SavePlaceErrorAction(error, payload.animationController)));
  });
}

Stream<dynamic> savePlaceSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SavePlaceSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield ClearActivePlaceAction();
            yield ClearPlaceActivityAction();
            yield SetSelectedTabIndexAction(TAB_PLACES);
            yield NavigatePushAction(AppRoutes.home);
            yield SendMessageAction(
              Message(
                message: 'Your new place was created successfully!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> savePlaceErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SavePlaceErrorAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield SendMessageAction(
              Message(
                message: 'Sorry, there was an issue creating this place',
              ),
            );
          }());
}

Stream<dynamic> updatePlaceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<UpdatePlaceAction>().flatMap((payload) {
    if (payload.animationController != null) {
      payload.animationController.forward();
    }

    return Stream.fromFuture(Firestore.instance
        .collection('places')
        .document(payload.placeId)
        .updateData(payload.data)
        .then<dynamic>((res) => UpdatePlaceSuccessAction(
            payload.placeId, payload.data, payload.animationController))
        .catchError((error) =>
            UpdatePlaceErrorAction(error, payload.animationController)));
  });
}

Stream<dynamic> updatePlaceSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdatePlaceSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield ClearActivePlaceAction();
            yield ClearPlaceActivityAction();
            yield SetSelectedTabIndexAction(TAB_PLACES);
            yield NavigatePushAction(AppRoutes.home);
            yield SendMessageAction(
              Message(
                message: 'Your place was updated successfully!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> updatePlaceErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<UpdatePlaceErrorAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield SendMessageAction(
              Message(
                message: 'Sorry, there was an issue updating this place',
              ),
            );
          }());
}

Stream<dynamic> deletePlaceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<DeletePlaceAction>().flatMap((payload) {
    return Stream.fromFuture(Firestore.instance
        .collection('places')
        .document(payload.place.documentId)
        .delete()
        .then<dynamic>((res) => DeletePlaceSuccessAction(payload.place))
        .catchError((error) => DeletePlaceErrorAction(error)));
  });
}

Stream<dynamic> deletePlaceSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<DeletePlaceSuccessAction>()
      .flatMap((payload) => () async* {
            yield ClearActivePlaceAction();
            yield ClearPlaceActivityAction();
            yield SendMessageAction(
              Message(
                message: 'Your places have been updated!',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> pushMessageEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<PushMessageAction>().flatMap((payload) {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['fromUid'] = payload.fromUid;
    data['toUid'] = payload.toUid;
    data['groupId'] = payload.groupId;
    data['type'] = payload.type.toString().split('.').last;
    data['created'] = getNow();

    return Stream.fromFuture(Firestore.instance
        .collection('messages')
        .add(data)
        .then<dynamic>((res) => PushMessageSuccessAction(payload.type))
        .catchError((error) => PushMessageErrorAction(error)));
  });
}

Stream<dynamic> pushMessageSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<PushMessageSuccessAction>()
      .flatMap((payload) => () async* {
            if (payload.type != null) {
              switch (payload.type) {
                case PushMessageType.CHECKIN:
                  yield SendMessageAction(
                    Message(
                      message: 'Check-in notification sent!',
                      bottomOffset: (store.state.user.activeGroupMember != null)
                          ? 10.0
                          : 53.0,
                    ),
                  );
                  break;

                default:
                  break;
              }
            }
          }());
}

Stream<dynamic> pushMessageErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<PushMessageErrorAction>()
      .flatMap((payload) => () async* {
            yield SendMessageAction(
              Message(
                message: 'There was an issue sending this message',
                bottomOffset: 53.0,
              ),
            );
          }());
}

Stream<dynamic> saveCloudinaryEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<SaveCloudinaryAction>().flatMap((payload) {
    return Stream.fromFuture(CloudinaryService.get()
        .upload(payload.data)
        .then<dynamic>((res) =>
            SaveCloudinarySuccessAction(payload.data, json.decode(res.body)))
        .catchError((error) => SaveCloudinaryErrorAction(error)));
  });
}

Stream<dynamic> saveCloudinarySuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveCloudinarySuccessAction>()
      .flatMap((payload) => () async* {
            // Update the photoUrl in the firebase user record
            if (payload.image != null) {
              UserUpdateInfo userUpdateInfo = UserUpdateInfo();
              userUpdateInfo.photoUrl = payload.image['secure_url'];
              await payload.data.user.updateProfile(userUpdateInfo);

              yield UpdateFamilyDataEventAction(
                family: {
                  'image': payload.image,
                },
                userId: payload.data.user.uid,
              );
            }

            yield UpdatingImageAction(false);
            yield SendMessageAction(
              Message(
                message: 'Your photo was updated successfully!',
              ),
            );
          }());
}

Stream<dynamic> saveCloudinaryErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<SaveCloudinaryErrorAction>()
      .flatMap((payload) => () async* {
            yield UpdatingImageAction(false);
            yield SendMessageAction(
              Message(
                message: 'Sorry, there was an issue saving this image',
              ),
            );
          }());
}

Stream<dynamic> requestMapsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestMapsAction>()
      .switchMap((RequestMapsAction requestAction) {
    return getMaps()
        .map((maps) => RequestMapsSuccessAction(maps))
        .takeUntil(
          actions.where((action) => action is CancelMapsAction),
        )
        .doOnError(
            (error, stacktrace) => RequestMapsFailureAction(error, stacktrace));
  });
}

Stream<List<MapBox>> getMaps() {
  return Firestore.instance
      .collection('maps')
      .orderBy('sequence', descending: false)
      .snapshots()
      .map((QuerySnapshot doc) => maps(doc));
}

List<MapBox> maps(
  QuerySnapshot doc,
) {
  List<MapBox> maps = List<MapBox>();

  for (DocumentSnapshot document in doc.documents) {
    maps..add(MapBox.fromSnapshot(document));
  }

  return maps;
}

Stream<dynamic> requestNearByPlacesEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions.whereType<RequestNearByPlacesAction>().flatMap((payload) {
    latlong.Distance distance = latlong.Distance();
    int nearbyDistanceUpdate = store.state.config['nearby_distance_update'];
    num meters = -1.0;

    if (payload.user.nearBy.lastPosition != null) {
      meters = distance(
        latlong.LatLng(payload.user.nearBy.lastPosition.latitude,
            payload.user.nearBy.lastPosition.longitude),
        latlong.LatLng(payload.user.location.coords.latitude,
            payload.user.location.coords.longitude),
      );
    }

    // Only update if the user passes the distance update threshold (meters)
    if ((meters < 0) || (meters > nearbyDistanceUpdate)) {
      return Stream.fromFuture(PlacesService.get()
          .nearBy(
            store.state.config,
            payload.user.location.toLatLng(),
          )
          .then<dynamic>((res) => RequestNearByPlacesSuccessAction(
              res, payload.user, payload.animationController))
          .catchError((error) => RequestNearByPlacesFailureAction(
              error, payload.animationController)));
    }

    if (payload.animationController != null) {
      payload.animationController.reverse();
    }

    return Stream.empty();
  });
}

Stream<dynamic> requestNearByPlacesSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestNearByPlacesSuccessAction>()
      .flatMap((payload) => () async* {
            yield UpdateFamilyDataEventAction(
              family: {
                'near_by': {
                  'last_updated': Timestamp.fromDate(getNow()),
                  'last_position':
                      LocationCoords().toMap(store.state.user.location.coords),
                  'places': Place().toJsonList(payload.places),
                }
              },
              userId: payload.user.documentId,
            );

            if ((payload.animationController != null) &&
                payload.animationController.isCompleted) {
              payload.animationController.reverse();
            }
          }());
}

Stream<dynamic> requestNearByPlacesErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) {
  return actions
      .whereType<RequestNearByPlacesFailureAction>()
      .flatMap((payload) => () async* {
            if (payload.animationController != null) {
              payload.animationController.reverse();
            }

            yield SendMessageAction(
              Message(
                message: 'Sorry, there was an issue getting the nearby places',
              ),
            );
          }());
}
