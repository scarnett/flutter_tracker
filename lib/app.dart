import 'package:camera/camera.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/config.dart';
import 'package:flutter_tracker/keys.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/pages/account_camera_page.dart';
import 'package:flutter_tracker/pages/account_photo_page.dart';
import 'package:flutter_tracker/pages/activity_detection_page.dart';
import 'package:flutter_tracker/pages/activity_map_page.dart';
import 'package:flutter_tracker/pages/groups_form_page.dart';
import 'package:flutter_tracker/pages/groups_administrators_page.dart';
import 'package:flutter_tracker/pages/groups_management_page.dart';
import 'package:flutter_tracker/pages/groups_members_page.dart';
import 'package:flutter_tracker/pages/groups_members_form_page.dart';
import 'package:flutter_tracker/pages/groups_menu_page.dart';
import 'package:flutter_tracker/pages/groups_places_details_page.dart';
import 'package:flutter_tracker/pages/groups_places_list_page.dart';
import 'package:flutter_tracker/pages/groups_places_locate_page.dart';
import 'package:flutter_tracker/pages/location_sharing_page.dart';
import 'package:flutter_tracker/pages/map_type_page.dart';
import 'package:flutter_tracker/pages/privacy_policy_page.dart';
import 'package:flutter_tracker/pages/subscription_page.dart';
import 'package:flutter_tracker/pages/upgrade_page.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/utils/rc_utils.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:screen/screen.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/middleware.dart';
import 'package:flutter_tracker/reducers.dart';
import 'package:flutter_tracker/pages/root_page.dart';
import 'package:flutter_tracker/utils/plan_utils.dart';

final GlobalKey<NavigatorState> navKey = AppKeys.navKey;

class FlutterTrackerApp extends StatelessWidget {
  final store = Store<AppState>(
    appStateReducer,
    initialState: AppState(),
    middleware: [
      EpicMiddleware(allEpics),
    ]..addAll(createNavigationMiddleware(navKey)),
  );

  AuthService _authService;
  bool _loaded = false;
  List<CameraDescription> _cameras;
  Logger logger = Logger();

  @override
  Widget build(
    BuildContext context,
  ) {
    // Keeps the screen on
    Screen.keepOn(true);

    // Status bar configuration
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background(),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Set the orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: AppConfig.isDebug(context),
        theme: appThemeData,
        navigatorKey: navKey,
        initialRoute: AppRoutes.home.path,
        home: FutureBuilder<RemoteConfig>(
          future: setupRemoteConfig(context),
          builder: (
            BuildContext context,
            AsyncSnapshot<RemoteConfig> snapshot,
          ) {
            if (!_loaded) {
              _authService = AuthService();
              // authService.listen();

              // Sometimes queryProductDetails doesn't return results on the first call.
              // Let's just get this out of the way and be done with it. I have no idea why this happens.
              InAppPurchaseConnection.enablePendingPurchases();
              InAppPurchaseConnection.instance
                  .queryProductDetails([''].toSet());

              // Load cameras
              _loadCameras();
              _loaded = true;
            }

            return snapshot.hasData
                ? RootPage(
                    authService: _authService,
                    store: store,
                    remoteConfig: snapshot.data,
                  )
                : Container();
          },
        ),
        onGenerateRoute: (
          RouteSettings settings,
        ) {
          // Home
          if (settings.name == AppRoutes.home.path) {
            return MaterialPageRoute(
              builder: (context) => RootPage(
                authService: _authService,
                store: store,
              ),
              settings: RouteSettings(name: AppRoutes.home.name),
            );
            // Account Photo
          } else if (settings.name == AppRoutes.accountPhoto.path) {
            return MaterialPageRoute(
              builder: (context) => AccountPhotoPage(
                authService: _authService,
              ),
              settings: RouteSettings(name: AppRoutes.accountPhoto.name),
            );
            // Account Camera
          } else if (settings.name == AppRoutes.accountCamera.path) {
            return MaterialPageRoute(
              builder: (context) => AccountCameraPage(
                authService: _authService,
                cameras: _cameras,
              ),
              settings: RouteSettings(name: AppRoutes.accountCamera.name),
            );
            // Group Menu
          } else if (settings.name == AppRoutes.groupMenu.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsMenuPage(),
              settings: RouteSettings(name: AppRoutes.groupMenu.name),
            );
            // Group Management
          } else if (settings.name == AppRoutes.groupsManagement.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsManagementPage(),
              settings: RouteSettings(name: AppRoutes.groupsManagement.name),
            );
            // Group Form
          } else if (settings.name == AppRoutes.groupForm.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsFormPage(),
              settings: RouteSettings(name: AppRoutes.groupMembers.name),
            );
            // Group Administrators
          } else if (settings.name == AppRoutes.groupAdministrators.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsAdministratorsPage(),
              settings: RouteSettings(name: AppRoutes.groupAdministrators.name),
            );
            // Group Members
          } else if (settings.name == AppRoutes.groupMembers.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsMembersPage(),
              settings: RouteSettings(name: AppRoutes.groupMembers.name),
            );
            // Group Member Form
          } else if (settings.name == AppRoutes.groupMembersForm.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsMembersFormPage(),
              settings: RouteSettings(name: AppRoutes.groupMembersForm.name),
            );
            // Group Places List
          } else if (settings.name == AppRoutes.groupPlacesList.path) {
            GroupsViewModel viewModel = GroupsViewModel.fromStore(store);
            if (needsUpgrade(
                viewModel.activePlan, 'max_places', viewModel.placeCount)) {
              return _showUpgrade();
            }

            return MaterialPageRoute(
              builder: (context) => GroupsPlacesListPage(),
              settings: RouteSettings(name: AppRoutes.groupPlacesList.name),
            );
            // Group Places Locate
          } else if (settings.name == AppRoutes.groupPlacesLocate.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsPlacesLocatePage(),
              settings: RouteSettings(name: AppRoutes.groupPlacesLocate.name),
            );
            // Group Places Details
          } else if (settings.name == AppRoutes.groupPlacesDetails.path) {
            return MaterialPageRoute(
              builder: (context) => GroupsPlacesDetailsPage(),
              settings: RouteSettings(name: AppRoutes.groupPlacesDetails.name),
            );
            // Location Sharing
          } else if (settings.name == AppRoutes.locationSharing.path) {
            return MaterialPageRoute(
              builder: (context) => LocationSharingPage(),
              settings: RouteSettings(name: AppRoutes.locationSharing.name),
            );
            // Activity Detection
          } else if (settings.name == AppRoutes.activityDetection.path) {
            return MaterialPageRoute(
              builder: (context) => ActivityDetectionPage(),
              settings: RouteSettings(name: AppRoutes.activityDetection.name),
            );
            // Activity Map
          } else if (settings.name == AppRoutes.activityMap.path) {
            return MaterialPageRoute(
              builder: (context) => ActivityMapPage(
                store: store,
              ),
              settings: RouteSettings(
                name: AppRoutes.activityMap.name,
                arguments: settings.arguments,
              ),
            );
            // Map Type
          } else if (settings.name == AppRoutes.mapType.path) {
            return MaterialPageRoute(
              builder: (context) => MapTypePage(),
              settings: RouteSettings(name: AppRoutes.mapType.name),
            );
            // Subscription
          } else if (settings.name == AppRoutes.subscription.path) {
            return MaterialPageRoute(
              builder: (context) => SubscriptionPage(),
              settings: RouteSettings(name: AppRoutes.subscription.path),
            );
            // Upgrade
          } else if (settings.name == AppRoutes.upgrade.path) {
            return _showUpgrade();
            // Privacy Policy
          } else if (settings.name == AppRoutes.privacyPolicy.path) {
            return MaterialPageRoute(
              builder: (context) => PrivacyPolicyPage(),
              settings: RouteSettings(name: AppRoutes.privacyPolicy.path),
            );
          }

          return null;
        },
      ),
    );
  }

  PageRoute _showUpgrade() {
    return CupertinoPageRoute(
      builder: (context) => UpgradePage(),
      settings: RouteSettings(name: AppRoutes.upgrade.path),
    );
  }

  Future<void> _loadCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      logger.d('code: ${e.code}, message: ${e.description}');
    }
  }
}
