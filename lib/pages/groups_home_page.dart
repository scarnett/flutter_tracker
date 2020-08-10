import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/pages/groups_chat_page.dart';
import 'package:flutter_tracker/pages/groups_places_page.dart';
import 'package:flutter_tracker/pages/groups_settings_page.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/widgets/groups_app_bar.dart';
import 'package:flutter_tracker/widgets/groups_panel.dart';
import 'package:flutter_tracker/widgets/groups_bottom_app_bar.dart';
import 'package:flutter_tracker/widgets/place_panel.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GroupsHomePage extends StatefulWidget {
  final BaseAuthService authService;
  final VoidCallback onSignedOut;

  GroupsHomePage({
    Key key,
    this.authService,
    this.onSignedOut,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsHomePageState();
}

class _GroupsHomePageState extends State<GroupsHomePage>
    with TickerProviderStateMixin {
  final PanelController _groupsPanelController = PanelController();
  final PanelController _placePanelController = PanelController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () => _willPop(viewModel),
        child: Scaffold(
          // extendBody: true,
          appBar: _buildAppBar(viewModel),
          body: Stack(
            children: _buildContent(viewModel),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPop(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    if (viewModel.updatingUser) {
      store.dispatch(UpdatingUserAction(false));
    } else {
      if (viewModel.activeGroupMember != null) {
        if (_groupsPanelController.panelPosition >
            DEFAULT_PANEL_ACTIVE_HEIGHT) {
          _groupsPanelController.close();
        } else {
          store.dispatch(ClearActiveGroupMemberAction());
          store.dispatch(CancelUserActivityAction());
          store.dispatch(ClearActivePlaceAction());
          store.dispatch(CancelPlaceActivityAction());
        }
      } else if (viewModel.activePlace != null) {
        if (_placePanelController.panelPosition > DEFAULT_PANEL_ACTIVE_HEIGHT) {
          _placePanelController.close();
        } else {
          store.dispatch(ClearActivePlaceAction());
        }
      } else if (_groupsPanelController.isAttached &&
          (_groupsPanelController.panelPosition >
              DEFAULT_PANEL_ACTIVE_HEIGHT)) {
        _groupsPanelController.close();
      } else if (_placePanelController.isAttached &&
          (_placePanelController.panelPosition > DEFAULT_PANEL_ACTIVE_HEIGHT)) {
        _placePanelController.close();
      } else if (viewModel.selectedTabIndex == TAB_HOME) {
        return _confirmExit();
      }

      _selectedTab(TAB_HOME);
    }

    return Future.value(false);
  }

  AppBar _buildAppBar(
    GroupsViewModel viewModel,
  ) {
    if ((viewModel.activeGroupMember == null) &&
        (viewModel.activePlace == null)) {
      return null;
    }

    return AppBar(
      title: GroupsAppBar(),
      titleSpacing: 0.0,
      automaticallyImplyLeading: false,
    );
  }

  List<Widget> _buildContent(
    GroupsViewModel viewModel,
  ) {
    List<Widget> children = [];
    children..add(_buildBody(viewModel));

    if (viewModel.user != null) {
      // children..add(GroupsMenu());
      // children..add(GroupsAppBar());

      /*
      GroupMember member = viewModel.activeGroupMember;
      if (member != null) {
        if (!locationSharingEnabled(member)) {
          children..add(_buildLocationSharingNotification(member, viewModel));
        } else if (!wifiConnected(member)) {
          children..add(_buildWifiNotification(member, viewModel));
        } else if (needsToChargeBattery(member) && !member.battery.charging) {
          children..add(_buildBatteryNotification(member, viewModel));
        }
      }
      */

      children
        ..add(
          GroupsBottomAppBar(
            color: AppTheme.hint,
            selectedColor: AppTheme.primary,
            onTabSelected: _selectedTab,
            items: [
              GroupsBottomAppBarItem(
                iconData: Icons.person_pin,
                text: 'People',
              ),
              GroupsBottomAppBarItem(
                iconData: Icons.location_city,
                text: 'Places',
              ),
              GroupsBottomAppBarItem(
                iconData: Icons.chat,
                text: 'Chat',
                disabled: true,
              ),
              GroupsBottomAppBarItem(
                iconData: Icons.settings,
                text: 'Settings',
              ),
            ],
          ),
        );
    }

    return children;
  }

  Widget _buildBody(
    GroupsViewModel viewModel,
  ) {
    switch (viewModel.selectedTabIndex) {
      case TAB_PLACES:
        return GroupsPlacesPage();
        break;

      case TAB_CHAT:
        return GroupsChatPage();
        break;

      case TAB_SETTINGS:
        return GroupsSettingsPage(
          authService: widget.authService,
          onSignedOut: widget.onSignedOut,
        );
        break;

      case TAB_HOME:
      default:
        if (viewModel.activePlace != null) {
          return PlacePanel(
            controller: _placePanelController,
          );
        } else {
          return GroupsPanel(
            panelController: _groupsPanelController,
          );
        }
        break;
    }
  }

  /*
  Widget _buildLocationSharingNotification(
    GroupMember member,
    GroupsViewModel viewModel,
  ) {
    return GroupsMemberLocationSharing(
      member: member,
      child: _buildNotification(
        member,
        'Turn ${getGroupMemberName(member, viewModel: viewModel)}\'s location sharing on',
        Icons.error,
      ),
    );
  }

  Widget _buildWifiNotification(
    GroupMember member,
    GroupsViewModel viewModel,
  ) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      child: GroupsMemberLocationAccuracy(
        member: member,
        child: _buildNotification(
          member,
          'Improve ${getGroupMemberName(member, viewModel: viewModel)}\'s location accuracy',
          Icons.signal_wifi_off,
        ),
      ),
    );
  }

  Widget _buildBatteryNotification(
    GroupMember member,
    GroupsViewModel viewModel,
  ) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      child: GroupsMemberChargeBattery(
        member: member,
        child: _buildNotification(
          member,
          'Charge ${getGroupMemberName(member, viewModel: viewModel)}\'s battery',
          Icons.battery_alert,
        ),
      ),
    );
  }

  Widget _buildNotification(
    GroupMember member,
    String text,
    IconData icon,
  ) {
    return Container(
      height: NOTIFICATION_MESSAGE_HEIGHT,
      color: Colors.redAccent.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                icon,
                color: Colors.white,
                size: 12.0,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ),
            Icon(
              Icons.arrow_right,
              color: Colors.white,
              size: 12.0,
            ),
          ],
        ),
      ),
    );
  }
  */

  Future<bool> _confirmExit() {
    return Alert(
      context: context,
      title: 'Exit?',
      desc: 'Are you sure you want to exit?',
      style: AlertStyle(
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        descStyle: const TextStyle(
          color: Colors.black38,
          fontStyle: FontStyle.normal,
          fontSize: 14.0,
          height: 1.5,
        ),
      ),
      closeFunction: () {},
      buttons: [
        DialogButton(
          child: const Text(
            'Yes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () => SystemChannels.platform.invokeMethod(
              'SystemNavigator.pop'), // @see https://api.flutter.dev/flutter/services/SystemNavigator/pop.html
          color: AppTheme.primary,
        ),
        DialogButton(
          child: const Text(
            'No',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.inactive(),
        ),
      ],
    ).show();
  }

  void _selectedTab(
    int index,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetSelectedTabIndexAction(index));
    store.dispatch(UpdatingUserAction(false));
  }
}
