import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/widgets/pages.dart';
import 'package:latlong/latlong.dart' as latlng;

class SetAppStateAction {
  final AppLifecycleState state;

  SetAppStateAction(this.state);

  @override
  String toString() => 'SetAppStateAction{state: $state}';
}

class SetAuthStatusAction {
  final AuthStatus status;

  SetAuthStatusAction(this.status);

  @override
  String toString() => 'SetAuthStatusAction{status: $status}';
}

class SetLocationPermissionStatusAction {
  final PermissionStatus status;

  SetLocationPermissionStatusAction(this.status);

  @override
  String toString() => 'SetLocationPermissionStatusAction{status: $status}';
}

class SetAppConfigurationAction {
  final Map<String, dynamic> config;

  SetAppConfigurationAction(this.config);

  @override
  String toString() => 'SetAppConfigurationAction{config: $config}';
}

class UpdatingUserAction {
  final bool status;

  UpdatingUserAction(this.status);

  @override
  String toString() => 'UpdatingUserAction{status: $status}';
}

class ClearUserAction {}

class RequestPurchasesAction {
  RequestPurchasesAction();
}

class RequestPurchasesSuccessAction {
  final List<PurchaseDetails> purchases;

  RequestPurchasesSuccessAction(
    this.purchases,
  );

  @override
  String toString() => 'RequestPurchasesSuccessAction{purchases: $purchases}';
}

class RequestPurchasesFailureAction {
  final dynamic error;

  RequestPurchasesFailureAction(
    this.error,
  );

  @override
  String toString() => 'RequestPurchasesFailureAction{error: $error}';
}

class RequestOnboardingAction {
  RequestOnboardingAction();
}

class RequestOnboardingSuccessAction {
  final List<PageModel> pages;

  RequestOnboardingSuccessAction(
    this.pages,
  );

  @override
  String toString() => 'RequestOnboardingSuccessAction{pages: $pages}';
}

class RequestOnboardingFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestOnboardingFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestOnboardingFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelOnboardingAction {}

// TODO: Rename this
class RequestFamilyDataAction {
  final String userId;

  RequestFamilyDataAction(this.userId);

  @override
  String toString() => 'RequestFamilyDataAction{userId: $userId}';
}

// TODO: Rename this
class RequestFamilyDataSuccessAction {
  final User user;

  RequestFamilyDataSuccessAction(this.user);

  @override
  String toString() => 'RequestFamilyDataSuccessAction{user: $user}';
}

// TODO: Rename this
class RequestFamilyDataFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestFamilyDataFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestFamilyDataFailureAction{error: $error, stacktrace: $stacktrace}';
}

// TODO: Rename this
class CancelFamilyDataEventsAction {}

class RequestProductsAction {
  @override
  String toString() => 'RequestProductsAction{}';
}

class RequestProductsSuccessAction {
  List<Product> products;

  RequestProductsSuccessAction(
    this.products,
  );

  @override
  String toString() => 'RequestProductsSuccessAction{products: $products}';
}

class RequestProductsFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestProductsFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestProductsFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelRequestProductsAction {}

class SaveProductDetailsAction {
  final List<Product> products;

  SaveProductDetailsAction(
    this.products,
  );

  @override
  String toString() => 'SaveProductDetailsAction{products: $products}';
}

class UpdateProductDetailsAction {
  final Product product;

  UpdateProductDetailsAction(
    this.product,
  );

  @override
  String toString() => 'UpdateProductDetailsAction{product: $product}';
}

class RequestPlansAction {
  @override
  String toString() => 'RequestPlansAction{}';
}

class SavePurchaseDetailsAction {
  final PurchaseDetails purchaseDetails;

  SavePurchaseDetailsAction(
    this.purchaseDetails,
  );

  @override
  String toString() =>
      'SavePurchaseDetailsAction{purchaseDetails: $purchaseDetails}';
}

class SavePurchaseDetailsSuccessAction {
  @override
  String toString() => 'SavePurchaseDetailsSuccessAction{}';
}

class SavePurchaseDetailsErrorAction {
  final dynamic error;

  SavePurchaseDetailsErrorAction(this.error);

  @override
  String toString() => 'SavePurchaseDetailsErrorAction{error: $error}';
}

class RequestPlansSuccessAction {
  List<Plan> plans;

  RequestPlansSuccessAction(
    this.plans,
  );

  @override
  String toString() => 'RequestPlansSuccessAction{plans: $plans}';
}

class RequestPlansFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestPlansFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestPlansFailureAction{error: $error, stacktrace: $stacktrace}';
}

class RequestPlanAction {
  final String planId;

  RequestPlanAction(
    this.planId,
  );

  @override
  String toString() => 'RequestPlanAction{planId: $planId}';
}

class RequestPlanSuccessAction {
  final String planId;
  Plan plan;

  RequestPlanSuccessAction(
    this.planId,
    this.plan,
  );

  @override
  String toString() =>
      'RequestPlansSuccessAction{planId: $planId, plan: $plan}';
}

class RequestPlanFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestPlanFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestPlanFailureAction{error: $error, stacktrace: $stacktrace}';
}

class RequestPlanSubscriptionAction {
  final String userId;

  RequestPlanSubscriptionAction(
    this.userId,
  );

  @override
  String toString() => 'RequestPlanSubscriptionAction{userId: $userId}';
}

class RequestPlanSubscriptionSuccessAction {
  RequestPlanSubscriptionSuccessAction();

  @override
  String toString() => 'RequestPlanSubscriptionSuccessAction{}';
}

class RequestPlanSubscriptionFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestPlanSubscriptionFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestPlanSubscriptionFailureAction{error: $error, stacktrace: $stacktrace}';
}

class RequestUserActivityDataAction {
  final String uid;
  DateTime startGt;
  DateTime endLte;

  RequestUserActivityDataAction(
    this.uid, {
    this.startGt,
    this.endLte,
  });

  @override
  String toString() =>
      'RequestUserActivityDataAction{uid: $uid, startGt: $startGt, endLte: $endLte}';
}

class ClearUserActivityDataAction {
  ClearUserActivityDataAction();

  @override
  String toString() => 'ClearUserActivityDataAction{}';
}

class RequestUserActivitySuccessAction {
  final String uid;
  final List<UserActivity> activity;

  RequestUserActivitySuccessAction(
    this.uid,
    this.activity,
  );

  @override
  String toString() => 'RequestUserActivitySuccessAction{uid: $uid}';
}

class RequestUserActivityFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestUserActivityFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestUserActivityFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelUserActivityAction {}

class RequestGroupsDataAction {
  final String userId;

  RequestGroupsDataAction(this.userId);

  @override
  String toString() => 'RequestGroupsDataAction{userId: $userId}';
}

class RequestGroupsDataSuccessAction {
  final List<Group> groups;

  RequestGroupsDataSuccessAction(this.groups);

  @override
  String toString() => 'RequestGroupsDataSuccessAction{groups: $groups}';
}

class RequestGroupsDataFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestGroupsDataFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestGroupsDataFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelGroupsDataEventsAction {}

class RequestGroupByInviteCodeAction {
  final String inviteCode;
  final User user;

  RequestGroupByInviteCodeAction(
    this.inviteCode,
    this.user,
  );

  @override
  String toString() =>
      'RequestGroupByInviteCodeAction{inviteCode: $inviteCode, user: $user}';
}

class RequestGroupByInviteCodeFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestGroupByInviteCodeFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestGroupByInviteCodeFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelRequestGroupByInviteCodeEventsAction {}

class RequestGroupMembersDataAction {
  final Group group;

  RequestGroupMembersDataAction(this.group);

  @override
  String toString() => 'RequestGroupMembersDataAction{group: $group}';
}

class RequestGroupMembersDataSuccessAction {
  final List<GroupMember> members;

  RequestGroupMembersDataSuccessAction(this.members);

  @override
  String toString() =>
      'RequestGroupMembersDataSuccessAction{members: $members}';
}

class RequestGroupMembersDataFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestGroupMembersDataFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestGroupMembersDataFailureAction{error: $error, stacktrace: $stacktrace}';
}

class RequestNearByPlacesAction {
  final User user;
  final AnimationController animationController;

  RequestNearByPlacesAction(
    this.user,
    this.animationController,
  );

  @override
  String toString() => 'RequestNearByPlacesAction{user: $user}';
}

class RequestNearByPlacesSuccessAction {
  final List<Place> places;
  final User user;
  final AnimationController animationController;

  RequestNearByPlacesSuccessAction(
    this.places,
    this.user,
    this.animationController,
  );

  @override
  String toString() =>
      'RequestNearByPlacesSuccessAction{places: $places, user: $user}';
}

class RequestNearByPlacesFailureAction {
  final dynamic error;
  final AnimationController animationController;

  RequestNearByPlacesFailureAction(this.error, this.animationController);

  @override
  String toString() => 'RequestNearByPlacesFailureAction{error: $error}';
}

class CancelGroupMembersDataEventsAction {}

class UpdateFamilyDataEventAction {
  final Map<String, dynamic> family;
  final String userId;

  UpdateFamilyDataEventAction({
    this.family,
    this.userId,
  });

  @override
  String toString() =>
      'UpdateFamilyDataEventAction{family: $family, userId: $userId}';
}

class UpdateFamilySuccessAction {}

class UpdateFamilyErrorEventAction {
  final dynamic error;

  UpdateFamilyErrorEventAction(this.error);

  @override
  String toString() => 'UpdateFamilyErrorEventAction{error: $error}';
}

class SaveAccountAction {
  final Map<String, dynamic> data;
  final String userId;
  final AnimationController animationController;

  SaveAccountAction(
    this.data,
    this.userId, {
    this.animationController,
  });

  @override
  String toString() => 'SaveAccountAction{data: $data, userId: $userId}';
}

class SaveAccountSuccessAction {
  final Map<String, dynamic> data;
  final String userId;
  final AnimationController animationController;

  SaveAccountSuccessAction(
    this.data,
    this.userId, {
    this.animationController,
  });

  @override
  String toString() => 'SaveAccountSuccessAction{data: $data, userId: $userId}';
}

class SaveAccountErrorAction {
  final dynamic error;
  final AnimationController animationController;

  SaveAccountErrorAction(
    this.error, {
    this.animationController,
  });

  @override
  String toString() => 'SaveAccountErrorAction{error: $error}';
}

class DeleteAccountAction {
  final String userId;

  DeleteAccountAction(
    this.userId,
  );

  @override
  String toString() => 'DeleteAccountAction{ userId: $userId}';
}

class DeleteAccountSuccessAction {
  final String userId;

  DeleteAccountSuccessAction(
    this.userId,
  );

  @override
  String toString() => 'DeleteAccountSuccessAction{userId: $userId}';
}

class DeleteAccountErrorAction {
  final dynamic error;

  DeleteAccountErrorAction(
    this.error,
  );

  @override
  String toString() => 'DeleteAccountErrorAction{error: $error}';
}

class ActivateGroupAction {
  final String groupId;

  ActivateGroupAction(this.groupId);

  @override
  String toString() => 'ActivateGroupAction{group: $groupId}';
}

class ActivateGroupSuccessAction {
  final String groupId;

  ActivateGroupSuccessAction(this.groupId);

  @override
  String toString() => 'ActivateGroupSuccessAction{group: $groupId}';
}

class ActivateGroupErrorAction {
  final dynamic error;

  ActivateGroupErrorAction(this.error);

  @override
  String toString() => 'ActivateGroupErrorAction{error: $error}';
}

class ActivateGroupMemberAction {
  final String groupMemberId;

  ActivateGroupMemberAction(
    this.groupMemberId,
  );

  @override
  String toString() =>
      'ActivateGroupMemberAction{groupMemberId: $groupMemberId}';
}

class ActivateGroupMemberSuccessAction {
  final String groupMemberId;

  ActivateGroupMemberSuccessAction(
    this.groupMemberId,
  );

  @override
  String toString() =>
      'ActivateGroupMemberSuccessAction{groupMemberId: $groupMemberId}';
}

class ActivateGroupMemberErrorAction {
  final dynamic error;

  ActivateGroupMemberErrorAction(this.error);

  @override
  String toString() => 'ActivateGroupMemberErrorAction{error: $error}';
}

class ClearActiveGroupMemberAction {
  ClearActiveGroupMemberAction();

  @override
  String toString() => 'ClearActiveGroupMemberAction{}';
}

class ClearActiveGroupMemberSuccessAction {
  ClearActiveGroupMemberSuccessAction();

  @override
  String toString() => 'ClearActiveGroupMemberSuccessAction{}';
}

class ClearActiveGroupMemberErrorAction {
  final dynamic error;

  ClearActiveGroupMemberErrorAction(this.error);

  @override
  String toString() => 'ClearActiveGroupMemberErrorAction{error: $error}';
}

class SaveGroupAction {
  final Group group;

  SaveGroupAction(
    this.group,
  );

  @override
  String toString() => 'SaveGroupAction{group: $group}';
}

class SaveGroupSuccessAction {
  final String groupId;

  SaveGroupSuccessAction(
    this.groupId,
  );

  @override
  String toString() => 'SaveGroupSuccessAction{groupId: $groupId}';
}

class SaveGroupErrorAction {
  final dynamic error;

  SaveGroupErrorAction(this.error);

  @override
  String toString() => 'SaveGroupErrorAction{error: $error}';
}

class UpdateGroupAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() => 'UpdateGroupAction{groupId: $groupId, data: $data}';
}

class UpdateGroupSuccessAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupSuccessAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() =>
      'UpdateGroupSuccessAction{groupId: $groupId, data: $data}';
}

class UpdateGroupErrorAction {
  final dynamic error;

  UpdateGroupErrorAction(this.error);

  @override
  String toString() => 'UpdateGroupErrorAction{error: $error}';
}

class UpdateGroupMemberLocationSharingAction {
  final String groupId;
  final Map<String, dynamic> data;
  final bool sendMessage;

  UpdateGroupMemberLocationSharingAction(
    this.groupId,
    this.data, {
    this.sendMessage: true,
  });

  @override
  String toString() =>
      'UpdateGroupMemberLocationSharingAction{groupId: $groupId, data: $data, sendMessage: $sendMessage}';
}

class UpdateGroupMemberLocationSharingSuccessAction {
  final String groupId;
  final Map<String, dynamic> data;
  final bool sendMessage;

  UpdateGroupMemberLocationSharingSuccessAction(
    this.groupId,
    this.data, {
    this.sendMessage: true,
  });

  @override
  String toString() =>
      'UpdateGroupMemberLocationSharingSuccessAction{groupId: $groupId, data: $data, sendMessage: $sendMessage}';
}

class UpdateGroupMemberLocationSharingErrorAction {
  final dynamic error;

  UpdateGroupMemberLocationSharingErrorAction(this.error);

  @override
  String toString() =>
      'UpdateGroupMemberLocationSharingErrorAction{error: $error}';
}

class UpdateGroupMemberActivityDetectionAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupMemberActivityDetectionAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() =>
      'UpdateGroupMemberActivityDetectionAction{groupId: $groupId, data: $data}';
}

class UpdateGroupMemberActivityDetectionSuccessAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupMemberActivityDetectionSuccessAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() =>
      'UpdateGroupMemberActivityDetectionSuccessAction{groupId: $groupId, data: $data}';
}

class UpdateGroupMemberActivityDetectionErrorAction {
  final dynamic error;

  UpdateGroupMemberActivityDetectionErrorAction(this.error);

  @override
  String toString() =>
      'UpdateGroupMemberActivityDetectionErrorAction{error: $error}';
}

class PushMessageAction {
  final String fromUid;
  final String toUid;
  final String groupId;
  final PushMessageType type;

  PushMessageAction(
    this.fromUid,
    this.toUid,
    this.groupId,
    this.type,
  );

  @override
  String toString() =>
      'PushMessageAction{fromUid: $fromUid, toUid: $toUid, groupId: $groupId, type: $type}';
}

class PushMessageSuccessAction {
  final PushMessageType type;

  PushMessageSuccessAction(
    this.type,
  );

  @override
  String toString() => 'PushMessageSuccessAction{type: $type}';
}

class PushMessageErrorAction {
  final dynamic error;

  PushMessageErrorAction(this.error);

  @override
  String toString() => 'PushMessageErrorAction{error: $error}';
}

class UpdateGroupMemberSettingsAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupMemberSettingsAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() =>
      'UpdateGroupMemberSettingsAction{groupId: $groupId, data: $data}';
}

class UpdateGroupMemberSettingsSuccessAction {
  final String groupId;
  final Map<String, dynamic> data;

  UpdateGroupMemberSettingsSuccessAction(
    this.groupId,
    this.data,
  );

  @override
  String toString() =>
      'UpdateGroupMemberSettingsSuccessAction{groupId: $groupId, data: $data}';
}

class UpdateGroupMemberSettingsErrorAction {
  final dynamic error;

  UpdateGroupMemberSettingsErrorAction(this.error);

  @override
  String toString() => 'UpdateGroupMemberSettingsErrorAction{error: $error}';
}

class SaveInviteCodeAction {
  final String groupId;
  final Map<String, dynamic> invite;

  SaveInviteCodeAction(
    this.groupId,
    this.invite,
  );

  @override
  String toString() =>
      'SaveInviteCodeAction{groupId: $groupId, invite: $invite}';
}

class SaveInviteCodeSuccessAction {
  final Map<String, dynamic> invite;

  SaveInviteCodeSuccessAction(this.invite);

  @override
  String toString() => 'SaveInviteCodeSuccessAction{invite: $invite}';
}

class SaveInviteCodeErrorAction {
  final dynamic error;

  SaveInviteCodeErrorAction(this.error);

  @override
  String toString() => 'SaveInviteCodeErrorAction{error: $error}';
}

class JoinGroupSuccessAction {
  final Group group;
  final AnimationController animationController;

  JoinGroupSuccessAction(
    this.group, {
    this.animationController,
  });

  @override
  String toString() => 'JoinGroupSuccessAction{group: $group}';
}

class JoinGroupErrorAction {
  final dynamic error;
  final AnimationController animationController;

  JoinGroupErrorAction(
    this.error, {
    this.animationController,
  });

  @override
  String toString() => 'JoinGroupErrorAction{error: $error}';
}

class JoinGroupConfirmedAction {
  final User user;
  final Group group;

  JoinGroupConfirmedAction(
    this.user,
    this.group,
  );

  @override
  String toString() => 'JoinGroupConfirmedAction{user: $user, group: $group}';
}

class JoinGroupConfirmedSuccessAction {
  final User user;
  final Group group;

  JoinGroupConfirmedSuccessAction(
    this.user,
    this.group,
  );

  @override
  String toString() =>
      'JoinGroupConfirmedSuccessAction{user: $user, group: $group}';
}

class JoinGroupConfirmedErrorAction {
  final dynamic error;

  JoinGroupConfirmedErrorAction(
    this.error,
  );

  @override
  String toString() => 'JoinGroupConfirmedErrorAction{error: $error}';
}

class JoinGroupDeclineAction {}

class ClearPendingGroupInviteAction {}

class LeaveGroupAction {
  final User user;
  final Group activeGroup;

  LeaveGroupAction(
    this.user,
    this.activeGroup,
  );

  @override
  String toString() =>
      'LeaveGroupAction{user: $user, activeGroup: $activeGroup}';
}

class LeaveGroupSuccessAction {
  final User user;
  final Group activeGroup;

  LeaveGroupSuccessAction(
    this.user,
    this.activeGroup,
  );

  @override
  String toString() =>
      'LeaveGroupSuccessAction{user: $user, activeGroup: $activeGroup}';
}

class LeaveGroupErrorAction {
  final dynamic error;

  LeaveGroupErrorAction(this.error);

  @override
  String toString() => 'LeaveGroupErrorAction{error: $error}';
}

class SaveGroupAdministratorsAction {
  final String groupId;
  final List<dynamic> admins;

  SaveGroupAdministratorsAction(
    this.groupId,
    this.admins,
  );

  @override
  String toString() =>
      'SaveGroupAdministratorsAction{groupId: $groupId, admins: $admins}';
}

class SaveGroupAdministratorsSuccessAction {
  final String groupId;
  final List<dynamic> admins;

  SaveGroupAdministratorsSuccessAction(
    this.groupId,
    this.admins,
  );

  @override
  String toString() =>
      'SaveGroupAdministratorsSuccessAction{groupId: $groupId, admins: $admins}';
}

class SaveGroupAdministratorsErrorAction {
  final dynamic error;

  SaveGroupAdministratorsErrorAction(this.error);

  @override
  String toString() => 'SaveGroupAdministratorsErrorAction{error: $error}';
}

class RemoveGroupMemberAction {
  final Group group;
  final GroupMember member;

  RemoveGroupMemberAction(
    this.group,
    this.member,
  );

  @override
  String toString() =>
      'RemoveGroupMemberAction{group: $group, member: $member}';
}

class RemoveGroupMemberSuccessAction {
  final Group group;
  final GroupMember member;

  RemoveGroupMemberSuccessAction(
    this.group,
    this.member,
  );

  @override
  String toString() =>
      'RemoveGroupMemberSuccessAction{group: $group, member: $member}';
}

class RemoveGroupMemberErrorAction {
  final dynamic error;

  RemoveGroupMemberErrorAction(this.error);

  @override
  String toString() => 'RemoveGroupMemberErrorAction{error: $error}';
}

class SetSelectedTabIndexAction {
  final int selectedTabIndex;

  SetSelectedTabIndexAction(this.selectedTabIndex);

  @override
  String toString() =>
      'SetSelectedTabIndexAction{selectedTabIndex: $selectedTabIndex}';
}

class SendMessageAction {
  final Message message;

  SendMessageAction(this.message);

  @override
  String toString() => 'SendMessageAction{message: $message}';
}

class ClearMessageAction {
  ClearMessageAction();

  @override
  String toString() => 'ClearMessageAction';
}

class NavigateReplaceAction {
  final AppRoute route;

  NavigateReplaceAction(this.route);

  @override
  String toString() => 'MainMenuNavigateAction{route: $route}';
}

class NavigatePushAction {
  final AppRoute route;
  final Object arguments;

  NavigatePushAction(
    this.route, {
    this.arguments,
  });

  @override
  String toString() =>
      'NavigatePushAction{route: $route, arguments: $arguments}';
}

class NavigatePopAction {
  @override
  String toString() => 'NavigatePopAction';
}

class SetMapDataAction {
  final dynamic mapData;

  SetMapDataAction(this.mapData);

  @override
  String toString() => 'SetMapDataAction{mapData: $mapData}';
}

class SetMapDataSuccessAction {
  final dynamic mapData;

  SetMapDataSuccessAction(this.mapData);

  @override
  String toString() => 'SetMapDataSuccessAction{mapData: $mapData}';
}

class SetMapDataErrorAction {
  final dynamic error;

  SetMapDataErrorAction(this.error);

  @override
  String toString() => 'SetMapDataErrorAction{error: $error}';
}

class RequestPlacesAction {
  final String userId;

  RequestPlacesAction(this.userId);

  @override
  String toString() => 'RequestPlacesAction{userId: $userId}';
}

class RequestPlacesSuccessAction {
  final List<Place> places;

  RequestPlacesSuccessAction(this.places);

  @override
  String toString() => 'RequestPlacesSuccessAction{}';
}

class RequestPlacesFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestPlacesFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestPlacesFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelPlacesEventsAction {}

class RequestPlaceActivityAction {
  final String placeId;
  DateTime startGt;
  DateTime endLte;

  RequestPlaceActivityAction(
    this.placeId, {
    this.startGt,
    this.endLte,
  });

  @override
  String toString() =>
      'RequestPlaceActivityAction{placeId: $placeId, startGt: $startGt, endLte: $endLte}';
}

class ClearPlaceActivityAction {
  ClearPlaceActivityAction();

  @override
  String toString() => 'ClearPlaceActivityAction{}';
}

class RequestPlaceActivitySuccessAction {
  final String placeId;
  final List<PlaceActivity> activity;

  RequestPlaceActivitySuccessAction(
    this.placeId,
    this.activity,
  );

  @override
  String toString() => 'RequestPlaceActivitySuccessAction{uid: $placeId}';
}

class RequestPlaceActivityFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestPlaceActivityFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestPlaceActivityFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelPlaceActivityAction {}

class RequestGroupPlacesAction {
  final String groupId;

  RequestGroupPlacesAction(this.groupId);

  @override
  String toString() => 'RequestGroupPlacesAction{groupId: $groupId}';
}

class RequestGroupPlacesSuccessAction {
  final List<Place> places;

  RequestGroupPlacesSuccessAction(this.places);

  @override
  String toString() => 'RequestGroupPlacesSuccessAction{}';
}

class RequestGroupPlacesFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestGroupPlacesFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestGroupPlacesFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelGroupPlacesEventsAction {}

class QueryPlacesAction {
  final String criteria;
  final latlng.LatLng latLng;

  QueryPlacesAction(
    this.criteria,
    this.latLng,
  );

  @override
  String toString() =>
      'QueryPlacesAction{criteria: $criteria, latlng: $latLng}';
}

class QueryPlacesSuccessAction {
  final String criteria;
  final latlng.LatLng latLng;
  final List<Place> places;

  QueryPlacesSuccessAction(
    this.criteria,
    this.latLng,
    this.places,
  );

  @override
  String toString() =>
      'QueryPlacesSuccessAction{criteria: $criteria, latlng: $latLng}';
}

class QueryPlacesErrorAction {
  final dynamic error;

  QueryPlacesErrorAction(
    this.error,
  );

  @override
  String toString() => 'QueryPlacesErrorAction{error: $error}';
}

class ClearPlacesAction {}

class ActivatePlaceAction {
  final Place place;

  ActivatePlaceAction(this.place);

  @override
  String toString() => 'ActivatePlaceAction{place: $place}';
}

class UpdateActivePlaceAction {
  final latlng.LatLng latLng;

  UpdateActivePlaceAction(this.latLng);

  @override
  String toString() => 'UpdateActivePlaceAction{latlng: $latLng}';
}

class UpdateActivePlaceSuccessAction {
  final Place place;

  UpdateActivePlaceSuccessAction(
    this.place,
  );

  @override
  String toString() => 'UpdateActivePlaceSuccessAction{place: $place}';
}

class UpdateActivePlaceErrorAction {
  final dynamic error;

  UpdateActivePlaceErrorAction(
    this.error,
  );

  @override
  String toString() => 'UpdateActivePlaceErrorAction{error: $error}';
}

class ClearActivePlaceAction {}

class SavePlaceAction {
  final Place place;
  final AnimationController animationController;

  SavePlaceAction(
    this.place,
    this.animationController,
  );

  @override
  String toString() => 'SavePlaceAction{place: $place}';
}

class SavePlaceSuccessAction {
  final Place place;
  final AnimationController animationController;

  SavePlaceSuccessAction(
    this.place,
    this.animationController,
  );

  @override
  String toString() => 'SavePlaceSuccessAction{place: $place}';
}

class SavePlaceErrorAction {
  final dynamic error;
  final AnimationController animationController;

  SavePlaceErrorAction(
    this.error,
    this.animationController,
  );

  @override
  String toString() => 'SavePlaceErrorAction{error: $error}';
}

class UpdatePlaceAction {
  final String placeId;
  final Map<String, dynamic> data;
  final AnimationController animationController;

  UpdatePlaceAction(
    this.placeId,
    this.data,
    this.animationController,
  );

  @override
  String toString() => 'UpdatePlaceAction{placeId: $placeId, data: $data}';
}

class UpdatePlaceSuccessAction {
  final String placeId;
  final Map<String, dynamic> data;
  final AnimationController animationController;

  UpdatePlaceSuccessAction(
    this.placeId,
    this.data,
    this.animationController,
  );

  @override
  String toString() =>
      'UpdatePlaceSuccessAction{placeId: $placeId, data: $data}';
}

class UpdatePlaceErrorAction {
  final dynamic error;
  final AnimationController animationController;

  UpdatePlaceErrorAction(
    this.error,
    this.animationController,
  );

  @override
  String toString() => 'UpdatePlaceErrorAction{error: $error}';
}

class DeletePlaceAction {
  final Place place;

  DeletePlaceAction(
    this.place,
  );

  @override
  String toString() => 'DeletePlaceAction{place: $place}';
}

class DeletePlaceSuccessAction {
  final Place place;

  DeletePlaceSuccessAction(
    this.place,
  );

  @override
  String toString() => 'DeletePlaceSuccessAction{place: $place}';
}

class DeletePlaceErrorAction {
  final dynamic error;

  DeletePlaceErrorAction(this.error);

  @override
  String toString() => 'DeletePlaceErrorAction{error: $error}';
}

class UpdatingImageAction {
  final bool status;

  UpdatingImageAction(this.status);

  @override
  String toString() => 'UpdatingImageAction{status: $status}';
}

class SaveCloudinaryAction {
  final CloudinaryUploadData data;

  SaveCloudinaryAction(this.data);

  @override
  String toString() => 'SaveCloudinaryAction{data: $data}';
}

class SaveCloudinarySuccessAction {
  final CloudinaryUploadData data;
  final Map<dynamic, dynamic> image;

  SaveCloudinarySuccessAction(this.data, this.image);

  @override
  String toString() => 'SaveCloudinaryAction{data: $data, image: $image}';
}

class SaveCloudinaryErrorAction {
  final dynamic error;

  SaveCloudinaryErrorAction(this.error);

  @override
  String toString() => 'SaveCloudinaryErrorAction{error: $error}';
}

class RequestMapsAction {
  RequestMapsAction();

  @override
  String toString() => 'RequestMapsAction{}';
}

class RequestMapsSuccessAction {
  final List<MapBox> maps;

  RequestMapsSuccessAction(this.maps);

  @override
  String toString() => 'RequestMapsSuccessAction{}';
}

class RequestMapsFailureAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestMapsFailureAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestMapsFailureAction{error: $error, stacktrace: $stacktrace}';
}

class CancelMapsAction {}
