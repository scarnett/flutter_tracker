import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

@immutable
class AppState {
  final Map<String, dynamic> config;
  final AppLifecycleState appState;
  final AuthStatus authStatus;
  final PermissionStatus locationPermissionStatus;
  final List<PageModel> onboarding;
  final List<Product> products;
  final List<Plan> plans;
  final User user;
  final List<UserActivity> userActivity;
  final bool updatingUser;
  final bool updatingImage;
  final List<Group> groups;
  final PendingGroupInvite pendingGroupInvite;
  final List<Place> places;
  final List<Place> groupPlaces;
  final Place activePlace;
  final List<PlaceActivity> placeActivity;
  final bool searchingPlaces;
  final List<Place> searchPlaces;
  final List<MapBox> maps;
  final List<AppRoute> route;
  final int selectedTabIndex;
  final Message message;

  AppState({
    this.config,
    this.appState = AppLifecycleState.resumed,
    this.authStatus,
    this.locationPermissionStatus,
    this.onboarding,
    this.products,
    this.plans,
    this.user,
    this.userActivity,
    this.updatingUser = false,
    this.updatingImage = false,
    this.groups,
    this.pendingGroupInvite,
    this.places,
    this.groupPlaces,
    this.activePlace,
    this.placeActivity,
    this.searchingPlaces = false,
    this.searchPlaces,
    this.maps,
    this.route = const [AppRoutes.home],
    this.selectedTabIndex = 0,
    this.message,
  });

  AppState copyWith({
    Map<String, dynamic> config,
    AppLifecycleState appState,
    List<PurchaseDetails> purchases,
    List<PageModel> onboarding,
    AuthStatus authStatus,
    PermissionStatus locationPermissionStatus,
    List<Product> products,
    List<Plan> plans,
    Plan activePlan,
    User user,
    List<UserActivity> userActivity,
    bool updatingUser,
    bool updatingImage,
    List<Group> groups,
    PendingGroupInvite pendingGroupInvite,
    List<Place> places,
    List<Place> groupPlaces,
    Place activePlace,
    List<PlaceActivity> placeActivity,
    bool searchingPlaces,
    List<Place> searchPlaces,
    List<MapBox> maps,
    List<String> route,
    int selectedTabIndex,
    Message message,
  }) =>
      AppState(
        config: config ?? this.config,
        appState: appState ?? this.appState,
        onboarding: onboarding ?? this.onboarding,
        authStatus: authStatus ?? this.authStatus,
        locationPermissionStatus:
            locationPermissionStatus ?? this.locationPermissionStatus,
        products: products ?? this.products,
        plans: plans ?? this.plans,
        user: user ?? this.user,
        userActivity: userActivity ?? this.userActivity,
        updatingUser: updatingUser ?? this.updatingUser,
        updatingImage: updatingImage ?? this.updatingImage,
        groups: groups ?? this.groups,
        pendingGroupInvite: pendingGroupInvite ?? this.pendingGroupInvite,
        places: places ?? this.places,
        groupPlaces: groupPlaces ?? this.groupPlaces,
        activePlace: activePlace ?? this.activePlace,
        placeActivity: placeActivity ?? this.placeActivity,
        searchingPlaces: searchingPlaces ?? this.searchingPlaces,
        searchPlaces: searchPlaces ?? this.searchPlaces,
        maps: maps ?? this.maps,
        route: route ?? this.route,
        selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
        message: message ?? this.message,
      );
}
