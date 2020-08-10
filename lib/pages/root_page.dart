import 'dart:async';
import 'dart:io';
import 'package:battery/battery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/app.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/pages/groups_home_page.dart';
import 'package:flutter_tracker/pages/login_signup_page.dart';
import 'package:flutter_tracker/pages/onboarding_page.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/battery_utils.dart';
import 'package:flutter_tracker/utils/connectivity_utils.dart';
import 'package:flutter_tracker/utils/device_utils.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/message_utils.dart';
import 'package:flutter_tracker/utils/rc_utils.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';

class RootPage extends StatefulWidget {
  final BaseAuthService authService;
  final Store<AppState> store;
  final RemoteConfig remoteConfig;

  RootPage({
    Key key,
    this.authService,
    this.store,
    this.remoteConfig,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  bool _userDataRequested = false;
  bool _userLoaded = false;
  bool _pushMessagesListening = false;
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  Logger logger = Logger();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initRemoteConfig(widget.remoteConfig, widget.store);

    _connectivity.onConnectivityChanged.listen((result) =>
        updateConnectionStatus(result, widget.remoteConfig, widget.store));

    _battery.onBatteryStateChanged.listen((state) =>
        updateBatteryState(_battery, state, widget.remoteConfig, widget.store));

    updateConnectionStatus(null, widget.remoteConfig, widget.store);
  }

  /*
   * This observes the 'state' of the application.
   * If the state is 'resumed' then the app should interact directly with firebase.
   * If the state is 'inactive', 'paused' or 'suspending' then the app should use the user endpoint url.
   */
  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    widget.store.dispatch(SetAppStateAction(state));

    /*
    setState(() {
      switch (state) {
        case AppLifecycleState.resumed:
          logger.d('Using firebase');
          setActiveConfig(context, widget.store);
          break;

        // case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          logger.d('Using endpoint');
          GroupsViewModel viewModel = GroupsViewModel.fromStore(widget.store);
          setInactiveConfig(context, viewModel, widget.store);
          break;

        default:
          break;
      }
    });
    */
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        if ((viewModel.authStatus != null) &&
            (viewModel.authStatus != _authStatus)) {
          _authStatus = viewModel.authStatus;
        }

        _checkUser(viewModel);
        listenForToastMessages(context, widget.store);

        if (!_pushMessagesListening && (viewModel.user != null)) {
          listenFormPushMessages(
            context,
            widget.store,
            userId: viewModel.user.documentId,
          );

          _pushMessagesListening = true;
        }

        switch (_authStatus) {
          case AuthStatus.NOT_DETERMINED:
            return showScaffoldLoadingBackdrop();
            break;

          case AuthStatus.ONBOARDING:
            return OnboardingPage();
            break;

          case AuthStatus.NEEDS_ACCOUNT_VERIFICATION:
          case AuthStatus.NOT_LOGGED_IN:
            _userDataRequested = false;
            _userLoaded = false;

            return LoginSignUpPage(
              authService: widget.authService,
              onSignedIn: (email, password) => _checkUser(
                viewModel,
                email: email,
                password: password,
              ),
              onVerify: _onVerify,
            );

            break;

          case AuthStatus.LOGGED_IN:
            return GroupsHomePage(
              authService: widget.authService,
              onSignedOut: () => onSignedOut(widget.store),
            );

            break;

          default:
            return showScaffoldLoadingBackdrop();
        }
      },
    );
  }

  void _checkUser(
    GroupsViewModel viewModel, {
    String email,
    String password,
  }) async {
    FirebaseUser user = await widget.authService.getCurrentUser();
    if (user == null) {
      setState(() {
        // _authStatus = AuthStatus.NOT_LOGGED_IN;
        _authStatus = AuthStatus.ONBOARDING;
      });
    } else if ((user != null) &&
        (!_userDataRequested ||
            !_userLoaded ||
            (_authStatus == AuthStatus.NOT_LOGGED_IN))) {
      setState(() {
        _authStatus = AuthStatus.LOGGED_IN;
        widget.store.dispatch(SetAuthStatusAction(_authStatus));
      });

      if (user.isEmailVerified) {
        if (!_userDataRequested) {
          widget.store.dispatch(CancelFamilyDataEventsAction());
          widget.store.dispatch(RequestFamilyDataAction(user.uid));
          widget.store.dispatch(CancelGroupsDataEventsAction());
          widget.store.dispatch(RequestGroupsDataAction(user.uid));

          setState(() {
            _userDataRequested = true;
          });
        }

        if ((viewModel != null) && (viewModel.user != null)) {
          widget.store.dispatch(RequestProductsAction());
          widget.store.dispatch(RequestPlacesAction(user.uid));
          widget.store.dispatch(RequestMapsAction());
          widget.store.dispatch(RequestPlansAction());

          _listenForAppVersion(user);
          _listenForDevice(user);
          _listenForTimezone(user);

          // Load the background location service
          initLocation(context, widget.store);
          configureLocationSharing(viewModel);

          // Activates the users' primary group if one isn't already activated
          if (viewModel.user.activeGroup == null) {
            widget.store
                .dispatch(ActivateGroupAction(viewModel.user.primaryGroup));
            // Requests the active group member activity if a group member is already activated
          } else if (viewModel.user.activeGroupMember != null) {
            widget.store.dispatch(CancelUserActivityAction());
            widget.store.dispatch(RequestUserActivityDataAction(
                viewModel.user.activeGroupMember));
          } else if (viewModel.user.activeGroup != null) {
            widget.store
                .dispatch(RequestGroupPlacesAction(viewModel.user.activeGroup));
          }

          setState(() {
            _userLoaded = true;
          });

          await checkLocationPermissionStatus(widget.store, context);
        }
      } else {
        setState(() {
          _authStatus = AuthStatus.NEEDS_ACCOUNT_VERIFICATION;
          widget.store.dispatch(SetAuthStatusAction(_authStatus));
        });
      }
    }
  }

  void _onVerify() {
    widget.authService.getCurrentUser().then((user) {
      setState(() {
        _authStatus = AuthStatus.LOGGED_IN;
        widget.store.dispatch(SetAuthStatusAction(_authStatus));
      });

      // Listen to the user doc
      widget.store.dispatch(RequestFamilyDataAction(user.uid));

      // Listen to the users' places
      widget.store.dispatch(RequestPlacesAction(user.uid));

      // Pull the display name from the firebase user and update the user doc
      widget.store.dispatch(UpdateFamilyDataEventAction(
        family: {
          'name': user.displayName,
        },
        userId: user.uid,
      ));
    });
  }

  /*
   * Listens for the app version & build number
   */
  Future<void> _listenForAppVersion(
    FirebaseUser user,
  ) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppVersion version = AppVersion().fromPackageInfo(packageInfo);

    if (!mounted) {
      return;
    }

    // Pull the display name from the firebase user and update the user doc
    widget.store.dispatch(UpdateFamilyDataEventAction(
      family: {
        'version': AppVersion().toMap(version),
      },
      userId: user.uid,
    ));
  }

  /*
   * Listens for the users' device
   */
  Future<void> _listenForDevice(
    FirebaseUser user,
  ) async {
    Map<dynamic, dynamic> _deviceData;

    try {
      if (Platform.isAndroid) {
        _deviceData = readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      _deviceData = <String, dynamic>{
        'error:': 'Failed to get platform version.',
      };
    }

    if (!mounted) {
      return;
    }

    // Pull the display name from the firebase user and update the user doc
    widget.store.dispatch(UpdateFamilyDataEventAction(
      family: {
        'device': _deviceData,
      },
      userId: user.uid,
    ));
  }

  /*
   * Listens for the users' timezone
   */
  Future<void> _listenForTimezone(
    FirebaseUser user,
  ) async {
    String timezone;

    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }

    if (!mounted) {
      return;
    }

    // Pull the display name from the firebase user and update the user doc
    widget.store.dispatch(UpdateFamilyDataEventAction(
      family: {
        'timezone': timezone,
      },
      userId: user.uid,
    ));
  }
}
