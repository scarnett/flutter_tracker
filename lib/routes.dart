class AppRoutes {
  static const home = AppRoute('home', '/');
  static const accountPhoto = AppRoute('account_photo', '/account_photo');
  static const accountCamera = AppRoute('account_camera', '/account_camera');
  static const groupMenu = AppRoute('groups_menu', '/groups_menu');
  static const groupsManagement =
      AppRoute('groups_management', '/groups_management');
  static const groupForm = AppRoute('group_form', '/group_form');
  static const groupAdministrators =
      AppRoute('group_administrators', '/group_administrators');
  static const groupMembers = AppRoute('group_members', '/group_members');
  static const groupMembersForm =
      AppRoute('group_members_form', '/group_members_form');
  static const groupPlacesList =
      AppRoute('group_places_list', '/group_places_list');
  static const groupPlacesLocate =
      AppRoute('group_places_locate', '/group_places_locate');
  static const groupPlacesDetails =
      AppRoute('group_places_details', '/group_places_details');
  static const locationSharing =
      AppRoute('location_sharing', '/location_sharing');
  static const activityDetection =
      AppRoute('activity_detection', '/activity_detection');
  static const activityMap = AppRoute('activity_map', '/activity_map');
  static const mapType = AppRoute('map_type', '/map_type');
  static const subscription = AppRoute('subscription', '/subscription');
  static const upgrade = AppRoute('upgrade', '/upgrade');
  static const privacyPolicy = AppRoute('privacy_policy', '/privacy_policy');
}

class AppRoute {
  final String name;
  final String path;

  const AppRoute(
    this.name,
    this.path,
  );
}
