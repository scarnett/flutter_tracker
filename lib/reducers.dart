import 'package:flutter/cupertino.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/widgets/pages.dart';
import 'package:redux/redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/state.dart';

AppState appStateReducer(
  AppState state,
  dynamic action,
) {
  return AppState(
    config: configReducer(state.config, action),
    appState: applicationStateReducer(state.appState, action),
    authStatus: authStatusReducer(state.authStatus, action),
    locationPermissionStatus:
        locationPermissionStatusReducer(state.locationPermissionStatus, action),
    onboarding: onboardingReducer(state.onboarding, action),
    products: productsReducer(state.products, action),
    plans: plansReducer(state.plans, action),
    user: userReducer(state.user, action),
    userActivity: userActivityReducer(state.userActivity, action),
    updatingUser: updatingUserReducer(state.updatingUser, action),
    updatingImage: updatingImageReducer(state.updatingImage, action),
    groups: groupsReducer(state.groups, action),
    pendingGroupInvite:
        pendingGroupInviteReducer(state.pendingGroupInvite, action),
    places: placesReducer(state.places, action),
    groupPlaces: groupPlacesReducer(state.groupPlaces, action),
    activePlace: activePlaceReducer(state.activePlace, action),
    placeActivity: placeActivityReducer(state.placeActivity, action),
    maps: mapsReducer(state.maps, action),
    searchingPlaces: searchingPlacesReducer(state.searchingPlaces, action),
    searchPlaces: searchPlacesReducer(state.searchPlaces, action),
    route: routeReducer(state.route, action),
    selectedTabIndex: selectedTabIndexReducer(state.selectedTabIndex, action),
    message: messageReducer(state.message, action),
  );
}

// ------------------------------------------------------- Firebase Remote Config
final configReducer = combineReducers<Map<String, dynamic>>([
  TypedReducer<Map<String, dynamic>, SetAppConfigurationAction>(
    _setConfig,
  ),
]);

Map<String, dynamic> _setConfig(
  Map<String, dynamic> oldConfig,
  SetAppConfigurationAction action,
) {
  return action.config;
}

// ------------------------------------------------------- AppLifecycleState
final applicationStateReducer = combineReducers<AppLifecycleState>([
  TypedReducer<AppLifecycleState, SetAppStateAction>(
    _setAppState,
  ),
]);

AppLifecycleState _setAppState(
  AppLifecycleState oldApState,
  SetAppStateAction action,
) {
  return action.state;
}

// ------------------------------------------------------- AuthStatus
final authStatusReducer = combineReducers<AuthStatus>([
  TypedReducer<AuthStatus, SetAuthStatusAction>(
    _setAuthStatus,
  ),
]);

AuthStatus _setAuthStatus(
  AuthStatus oldAuthStatus,
  SetAuthStatusAction action,
) {
  return action.status;
}

// ------------------------------------------------------- PermissionStatus
final locationPermissionStatusReducer = combineReducers<PermissionStatus>([
  TypedReducer<PermissionStatus, SetLocationPermissionStatusAction>(
    _setLocationPermissionStatus,
  ),
]);

PermissionStatus _setLocationPermissionStatus(
  PermissionStatus oldLocationPermissionStatus,
  SetLocationPermissionStatusAction action,
) {
  return action.status;
}

// ------------------------------------------------------- Onboarding
final onboardingReducer = combineReducers<List<PageModel>>([
  TypedReducer<List<PageModel>, RequestOnboardingSuccessAction>(
    _setOnboarding,
  ),
]);

List<PageModel> _setOnboarding(
  List<PageModel> oldOnboarding,
  RequestOnboardingSuccessAction action,
) {
  return action.pages;
}

// ------------------------------------------------------- Products
final productsReducer = combineReducers<List<Product>>([
  TypedReducer<List<Product>, RequestProductsSuccessAction>(
    _setProducts,
  ),
  TypedReducer<List<Product>, SaveProductDetailsAction>(
    _saveProductDetails,
  ),
  TypedReducer<List<Product>, UpdateProductDetailsAction>(
    _updateProductDetails,
  )
]);

List<Product> _setProducts(
  List<Product> oldProducts,
  RequestProductsSuccessAction action,
) {
  return action.products;
}

List<Product> _saveProductDetails(
  List<Product> oldProducts,
  SaveProductDetailsAction action,
) {
  return action.products;
}

List<Product> _updateProductDetails(
  List<Product> products,
  UpdateProductDetailsAction action,
) {
  products.forEach((product) {
    if (product.id == action.product.id) {
      product = action.product;
    }
  });

  return products;
}

// ------------------------------------------------------- Plans
final plansReducer = combineReducers<List<Plan>>([
  TypedReducer<List<Plan>, RequestPlansSuccessAction>(
    _setPlans,
  ),
]);

List<Plan> _setPlans(
  List<Plan> oldPlans,
  RequestPlansSuccessAction action,
) {
  return action.plans;
}

// ------------------------------------------------------- User
final userReducer = combineReducers<User>([
  TypedReducer<User, RequestFamilyDataSuccessAction>(
    _setUser,
  ),
  TypedReducer<User, ClearUserAction>(
    _clearUser,
  ),
]);

User _setUser(
  User oldUser,
  RequestFamilyDataSuccessAction action,
) {
  return action.user;
}

User _clearUser(
  User oldUser,
  ClearUserAction action,
) {
  return null;
}

// ------------------------------------------------------- User Activity & Events
final userActivityReducer = combineReducers<List<dynamic>>([
  // UserActivity
  TypedReducer<List<dynamic>, RequestUserActivitySuccessAction>(
    _setUserActivity,
  ),
  // UserActivity
  TypedReducer<List<dynamic>, CancelUserActivityAction>(
    _clearUserActivity,
  ),
]);

List<dynamic> _setUserActivity(
  List<dynamic> oldUserActivity,
  RequestUserActivitySuccessAction action,
) {
  return action.activity;
}

List<dynamic> _clearUserActivity(
  List<dynamic> oldUserActivity,
  CancelUserActivityAction action,
) {
  return null;
}

// ------------------------------------------------------- Updating User
final updatingUserReducer = combineReducers<bool>([
  TypedReducer<bool, UpdatingUserAction>(
    _setUpdatingUserStatus,
  ),
]);

bool _setUpdatingUserStatus(
  bool oldStatus,
  dynamic action,
) {
  return action.status;
}

// ------------------------------------------------------- Updating Image
final updatingImageReducer = combineReducers<bool>([
  TypedReducer<bool, UpdatingImageAction>(
    _setUpdatingImageStatus,
  ),
]);

bool _setUpdatingImageStatus(
  bool oldStatus,
  dynamic action,
) {
  return action.status;
}

// ------------------------------------------------------- Groups
final groupsReducer = combineReducers<List<Group>>([
  TypedReducer<List<Group>, RequestGroupsDataSuccessAction>(
    _setGroups,
  ),
]);

List<Group> _setGroups(
  List<Group> oldGroups,
  RequestGroupsDataSuccessAction action,
) {
  return action.groups;
}

// ------------------------------------------------------- PendingGroupInvite
final pendingGroupInviteReducer = combineReducers<PendingGroupInvite>([
  TypedReducer<PendingGroupInvite, JoinGroupSuccessAction>(
    _setPendingGroupInvite,
  ),
  TypedReducer<PendingGroupInvite, JoinGroupDeclineAction>(
    _declinePendingGroupInvite,
  ),
  TypedReducer<PendingGroupInvite, ClearPendingGroupInviteAction>(
    _clearPendingGroupInvite,
  ),
]);

PendingGroupInvite _setPendingGroupInvite(
  PendingGroupInvite oldPendingGroupInvite,
  JoinGroupSuccessAction action,
) {
  return PendingGroupInvite(
    group: action.group,
  );
}

PendingGroupInvite _declinePendingGroupInvite(
  PendingGroupInvite oldPendingGroupInvite,
  JoinGroupDeclineAction action,
) {
  return null;
}

PendingGroupInvite _clearPendingGroupInvite(
  PendingGroupInvite oldPendingGroupInvite,
  ClearPendingGroupInviteAction action,
) {
  return null;
}

// ------------------------------------------------------- Places
final placesReducer = combineReducers<List<Place>>([
  TypedReducer<List<Place>, RequestPlacesSuccessAction>(
    _setPlaces,
  ),
]);

List<Place> _setPlaces(
  List<Place> oldPlaces,
  RequestPlacesSuccessAction action,
) {
  return action.places;
}

// ------------------------------------------------------- Group Places
final groupPlacesReducer = combineReducers<List<Place>>([
  TypedReducer<List<Place>, RequestGroupPlacesSuccessAction>(
    _setGroupPlaces,
  ),
]);

List<Place> _setGroupPlaces(
  List<Place> oldPlaces,
  RequestGroupPlacesSuccessAction action,
) {
  return action.places;
}

// ------------------------------------------------------- Active Place
final activePlaceReducer = combineReducers<Place>([
  TypedReducer<Place, ActivatePlaceAction>(
    _setActivePlace,
  ),
  TypedReducer<Place, UpdateActivePlaceSuccessAction>(
    _setUpdatedActivePlace,
  ),
  TypedReducer<Place, ClearActivePlaceAction>(
    _clearActivePlace,
  ),
]);

Place _setActivePlace(
  Place oldActivePlace,
  ActivatePlaceAction action,
) {
  return action.place;
}

Place _setUpdatedActivePlace(
  Place oldActivePlace,
  UpdateActivePlaceSuccessAction action,
) {
  if (oldActivePlace != null) {
    if (oldActivePlace.documentId != null) {
      action.place.documentId = oldActivePlace.documentId;
    }

    if (oldActivePlace.group != null) {
      action.place.group = oldActivePlace.group;
    }
  }

  return action.place;
}

Place _clearActivePlace(
  Place oldActivePlace,
  ClearActivePlaceAction action,
) {
  return null;
}

// ------------------------------------------------------- Place Activity
final placeActivityReducer = combineReducers<List<PlaceActivity>>([
  TypedReducer<List<PlaceActivity>, RequestPlaceActivitySuccessAction>(
    _setPlaceActivity,
  ),
  TypedReducer<List<PlaceActivity>, CancelPlaceActivityAction>(
    _clearPlaceActivity,
  ),
]);

List<PlaceActivity> _setPlaceActivity(
  List<PlaceActivity> oldPlaceActivity,
  RequestPlaceActivitySuccessAction action,
) {
  return action.activity;
}

List<PlaceActivity> _clearPlaceActivity(
  List<PlaceActivity> oldPlaceActivity,
  CancelPlaceActivityAction action,
) {
  return null;
}

// ------------------------------------------------------- Searching Places
final searchingPlacesReducer = combineReducers<bool>([
  TypedReducer<bool, QueryPlacesAction>(
    _setSearchingPlaces,
  ),
  TypedReducer<bool, UpdateActivePlaceAction>(
    _setSearchingPlaces,
  ),
  TypedReducer<bool, QueryPlacesSuccessAction>(
    _setNotSearchingPlaces,
  ),
  TypedReducer<bool, QueryPlacesErrorAction>(
    _setNotSearchingPlaces,
  ),
  TypedReducer<bool, UpdateActivePlaceSuccessAction>(
    _setNotSearchingPlaces,
  ),
  TypedReducer<bool, UpdateActivePlaceErrorAction>(
    _setNotSearchingPlaces,
  ),
]);

bool _setSearchingPlaces(
  bool oldSearching,
  dynamic action,
) {
  return true;
}

bool _setNotSearchingPlaces(
  bool oldSearching,
  dynamic action,
) {
  return false;
}

// ------------------------------------------------------- Search Places
final searchPlacesReducer = combineReducers<List<Place>>([
  TypedReducer<List<Place>, QueryPlacesSuccessAction>(
    _setSearchPlaces,
  ),
  TypedReducer<List<Place>, ClearPlacesAction>(
    _clearSearchPlaces,
  ),
]);

List<Place> _setSearchPlaces(
  List<Place> oldPlaces,
  QueryPlacesSuccessAction action,
) {
  return action.places;
}

List<Place> _clearSearchPlaces(
  List<Place> oldPlaces,
  ClearPlacesAction action,
) {
  return null;
}

// ------------------------------------------------------- Maps
final mapsReducer = combineReducers<List<MapBox>>([
  TypedReducer<List<MapBox>, RequestMapsSuccessAction>(
    _setMaps,
  ),
]);

List<MapBox> _setMaps(
  List<MapBox> oldMaps,
  RequestMapsSuccessAction action,
) {
  return action.maps;
}

// ------------------------------------------------------- AppRoute
final routeReducer = combineReducers<List<AppRoute>>([
  TypedReducer<List<AppRoute>, NavigateReplaceAction>(
    _navigateReplace,
  ),
  TypedReducer<List<AppRoute>, NavigatePushAction>(
    _navigatePush,
  ),
  TypedReducer<List<AppRoute>, NavigatePopAction>(
    _navigatePop,
  ),
]);

List<AppRoute> _navigateReplace(
  List<AppRoute> route,
  NavigateReplaceAction action,
) =>
    [action.route];

List<AppRoute> _navigatePush(
  List<AppRoute> route,
  NavigatePushAction action,
) {
  List<AppRoute> result = List<AppRoute>.from(route);
  result..add(action.route);
  return result;
}

List<AppRoute> _navigatePop(
  List<AppRoute> route,
  NavigatePopAction action,
) {
  List<AppRoute> result = List<AppRoute>.from(route);
  result.removeLast();
  return result;
}

// ------------------------------------------------------- Selected Tab Index
final selectedTabIndexReducer = combineReducers<int>([
  TypedReducer<int, SetSelectedTabIndexAction>(
    _setSelectedTabIndex,
  ),
]);

int _setSelectedTabIndex(
  int selectedTabIndex,
  SetSelectedTabIndexAction action,
) {
  return action.selectedTabIndex;
}

// ------------------------------------------------------- Message
final messageReducer = combineReducers<Message>([
  TypedReducer<Message, SendMessageAction>(
    _sendMessage,
  ),
  TypedReducer<Message, ClearMessageAction>(
    _clearMessage,
  ),
]);

Message _sendMessage(
  Message message,
  SendMessageAction action,
) {
  return action.message;
}

Message _clearMessage(
  Message message,
  ClearMessageAction action,
) {
  return null;
}
