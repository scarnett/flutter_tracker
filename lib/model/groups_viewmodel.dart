import 'package:flutter/scheduler.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/widgets/pages.dart';
import 'package:redux/redux.dart';

// TODO: Refactor this; theres to much in here
class GroupsViewModel {
  final Map<String, dynamic> config;
  final int selectedTabIndex;
  final Function(
    String, [
    Map<String, String>,
    String,
  ]) configValue;
  final Message message;
  final AppLifecycleState appState;
  final AuthStatus authStatus;
  final PermissionStatus locationPermissionStatus;
  final List<PageModel> onboarding;
  final List<Product> products;
  final List<Plan> plans;
  final Plan activePlan;
  final User user;
  final List<UserActivity> userActivity;
  final bool updatingUser;
  final bool updatingImage;
  final Location location;
  final List<Group> groups;
  final Function([
    String,
  ]) group;
  final Function([
    bool,
  ]) groupCount;
  final Function(
    Group, [
    Function callback,
  ]) activationCallback;
  final Group activeGroup;
  final GroupMember activeGroupMember;
  final Place activePlace;
  final List<PlaceActivity> placeActivity;
  final PlaceActivity latestPlaceActivity;
  final PendingGroupInvite pendingGroupInvite;
  final List<Place> places;
  final int placeCount;
  final List<Place> groupPlaces;
  final bool searchingPlaces;
  final List<Place> searchPlaces;
  final List<MapBox> maps;

  GroupsViewModel({
    this.config,
    this.selectedTabIndex,
    this.configValue,
    this.message,
    this.appState,
    this.authStatus,
    this.locationPermissionStatus,
    this.onboarding,
    this.products,
    this.plans,
    this.activePlan,
    this.user,
    this.userActivity,
    this.updatingUser,
    this.updatingImage,
    this.location,
    this.groups,
    this.group,
    this.groupCount,
    this.activationCallback,
    this.activeGroup,
    this.activeGroupMember,
    this.activePlace,
    this.placeActivity,
    this.latestPlaceActivity,
    this.pendingGroupInvite,
    this.places,
    this.placeCount,
    this.groupPlaces,
    this.searchingPlaces,
    this.searchPlaces,
    this.maps,
  });

  static GroupsViewModel fromStore(
    Store<AppState> store,
  ) {
    return GroupsViewModel(
      config: store.state.config,
      selectedTabIndex: store.state.selectedTabIndex,
      configValue: (configKey, [context, defaultValue]) => getConfigValue(
        store.state,
        configKey,
        context,
        defaultValue,
      ),
      message: store.state.message,
      appState: getAppState(store.state),
      authStatus: getAuthStatus(store.state),
      locationPermissionStatus: getLocationPermissionStatus(store.state),
      onboarding: getOnboarding(store.state),
      products: getProducts(store.state),
      plans: getPlans(store.state),
      activePlan: getActivePlan(store.state),
      user: getUser(store.state),
      userActivity: getUserActivity(store.state),
      updatingUser: store.state.updatingUser,
      updatingImage: store.state.updatingImage,
      location: getLocation(store.state),
      groups: getGroups(store.state),
      groupCount: ([ownerOnly]) => getGroupCount(
        store.state,
        ownerOnly: ownerOnly,
      ),
      group: ([groupId]) => getGroup(
        store.state,
        groupId,
      ),
      activeGroup: getActiveGroup(store.state),
      activeGroupMember: getActiveGroupMember(store.state),
      activePlace: store.state.activePlace,
      placeActivity: getPlaceActivity(store.state),
      latestPlaceActivity: getLatestPlaceActivity(store.state),
      pendingGroupInvite: store.state.pendingGroupInvite,
      places: getPlaces(store.state),
      placeCount: getPlaceCount(store.state),
      groupPlaces: getGroupPlaces(store.state),
      searchingPlaces: store.state.searchingPlaces,
      searchPlaces: getSearchPlaces(store.state),
      activationCallback: (group, [callback]) => () {
        runCallback(
          store,
          group,
          callback,
        );
      },
      maps: store.state.maps,
    );
  }

  static dynamic getConfigValue(
    AppState state,
    String configKey,
    Map<String, String> context,
    String defaultValue,
  ) {
    if (context == null) {
      dynamic value =
          ((state.config == null) || (state.config[configKey] == ''))
              ? defaultValue
              : state.config[configKey];
      return value;
    }

    if (state.config != null) {
      String value = state.config[configKey];
      if (value != null) {
        context.forEach((key, val) {
          if ((key != null) && (val != null)) {
            value = value.replaceAll('\${$key}', val);
            value = value.replaceAll('{$key}', val);
          }
        });
      }

      if (value == null) {
        return defaultValue;
      }

      return value;
    }

    return null;
  }

  static AppLifecycleState getAppState(
    AppState state,
  ) {
    if (state.appState == null) {
      return null;
    }

    return state.appState;
  }

  static AuthStatus getAuthStatus(
    AppState state,
  ) {
    if (state.authStatus == null) {
      return null;
    }

    return state.authStatus;
  }

  static PermissionStatus getLocationPermissionStatus(
    AppState state,
  ) {
    if (state.locationPermissionStatus == null) {
      return null;
    }

    return state.locationPermissionStatus;
  }

  static List<PageModel> getOnboarding(
    AppState state,
  ) {
    if (state.onboarding == null) {
      return null;
    }

    return state.onboarding;
  }

  static List<Product> getProducts(
    AppState state,
  ) {
    if (state.products == null) {
      return null;
    }

    return state.products;
  }

  static List<Plan> getPlans(
    AppState state,
  ) {
    if (state.plans == null) {
      return null;
    }

    return state.plans;
  }

  static Plan getActivePlan(
    AppState state,
  ) {
    if ((state.user == null) || (state.plans == null)) {
      return null;
    }

    if (state.user.purchase == null) {
      return state.plans.firstWhere((plan) => plan.sequence == 0);
    }

    List<String> skuParts = state.user.purchase.sku.split('_');
    return state.plans.firstWhere((plan) => plan.code == skuParts[0]);
  }

  static User getUser(
    AppState state,
  ) {
    if (state.user == null) {
      return null;
    }

    return state.user;
  }

  static List<UserActivity> getUserActivity(
    AppState state,
  ) {
    if (state.userActivity == null) {
      return null;
    }

    return state.userActivity;
  }

  static Location getLocation(
    AppState state,
  ) {
    User user = getUser(state);
    if ((user == null) || (user.location == null)) {
      return null;
    }

    return user.location;
  }

  static List<Group> getGroups(
    AppState state,
  ) {
    if (state.groups == null) {
      return [];
    }

    return state.groups;
  }

  static Group getGroup(
    AppState state,
    String groupId,
  ) {
    if ((state.groups == null) || (groupId == null)) {
      return null;
    }

    List<Group> groups = getGroups(state);
    if (groups.length > 0) {
      Group group = groups.firstWhere((group) => group.documentId == groupId);
      if (group == null) {
        return null;
      }

      return group;
    }

    return null;
  }

  static dynamic getGroupCount(
    AppState state, {
    bool ownerOnly = false,
  }) {
    if (state.groups == null) {
      return 0;
    }

    if (ownerOnly) {
      List groups = state.groups
          .map((group) => (group.owner.uid == state.user.documentId))
          .toList();
      return groups.length;
    }

    return state.groups.length;
  }

  static Group getActiveGroup(
    AppState state,
  ) {
    if ((state.groups == null) || (state.user == null)) {
      return null;
    }

    List<Group> groups = getGroups(state);
    if (groups.length > 0) {
      Group group = groups
          .firstWhere((group) => group.documentId == state.user.activeGroup);
      if (group == null) {
        return null;
      }

      return group;
    }

    return null;
  }

  static GroupMember getActiveGroupMember(
    AppState state,
  ) {
    Group activeGroup = getActiveGroup(state);
    if (activeGroup == null) {
      return null;
    }

    Iterable<GroupMember> filtered = activeGroup.members
        .where((member) => member.uid == state.user.activeGroupMember);
    if ((filtered == null) || filtered.isEmpty) {
      return null;
    }

    return filtered.first;
  }

  static List<Place> getPlaces(
    AppState state,
  ) {
    if (state.places == null) {
      return [];
    }

    return state.places;
  }

  static int getPlaceCount(
    AppState state,
  ) {
    if (state.places == null) {
      return 0;
    }

    return state.places.length;
  }

  static List<PlaceActivity> getPlaceActivity(
    AppState state,
  ) {
    if (state.placeActivity == null) {
      return null;
    }

    return state.placeActivity;
  }

  static PlaceActivity getLatestPlaceActivity(
    AppState state,
  ) {
    if ((state.placeActivity == null) || (state.placeActivity.length == 0)) {
      return null;
    }

    return state.placeActivity.first;
  }

  static List<Place> getGroupPlaces(
    AppState state,
  ) {
    if (state.groupPlaces == null) {
      return [];
    }

    return state.groupPlaces;
  }

  static List<Place> getSearchPlaces(
    AppState state,
  ) {
    if (state.searchPlaces == null) {
      return [];
    }

    return state.searchPlaces;
  }

  static void runCallback(
    store,
    group, [
    callback,
  ]) {
    store.dispatch(ActivateGroupAction(group.documentId));

    // The purpose of this delay is to keep the menu from closing to quickly after a group was tapped in the menu.
    // I wanted to show the active group updating itself in the menu before it closed itself. - Scott
    Future.delayed(const Duration(milliseconds: 300), () {
      if (callback != null) {
        callback();
      }
    });
  }
}
