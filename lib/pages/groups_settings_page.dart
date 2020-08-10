import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/validators/common_validators.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/list_select_item.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/widgets/text_field.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/widgets/wavy_background.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class GroupsSettingsPage extends StatefulWidget {
  final BaseAuthService authService;
  final VoidCallback onSignedOut;

  GroupsSettingsPage({
    Key key,
    this.authService,
    this.onSignedOut,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsSettingsPageState();
}

class _GroupsSettingsPageState extends State<GroupsSettingsPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  AnimationController _backdropAnimationController;
  Map<String, List<Widget>> _sections = Map<String, List<Widget>>();

  String _name;
  String _email;
  // String _phone;
  bool _isProcessing = false;

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    setState(() {
      _backdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );

      // Creates the 'options' sections. These are the default items that the user see's
      _sections['options'] = List<Widget>()
        ..add(_createSettingsSection())
        ..add(_createAccountSection());

      // Creates the 'update' form sections. This is the account update form.
      _createUpdateSection().then((sections) {
        _sections['update'] = List<Widget>()..add(sections);
      });
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        _isProcessing = _backdropAnimationController.isCompleted;
        return _createContent(viewModel);
      },
    );
  }

  @override
  void dispose() {
    _backdropAnimationController.dispose();
    super.dispose();
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    List<Widget> children = [];
    children..add(_buildList(viewModel));
    children
      ..add(showLoadingBackdrop(
        _backdropAnimationController,
        condition: _isProcessing,
      ));

    return Stack(
      children: filterNullWidgets(children),
    );
  }

  Widget _buildList(
    GroupsViewModel viewModel,
  ) {
    List<Widget> items = [];

    if (_sections != null) {
      List<Widget> sectionItems;

      if (viewModel.updatingUser) {
        sectionItems = _sections['update'];
      } else {
        sectionItems = _sections['options'];
      }

      if (sectionItems != null) {
        items..addAll(sectionItems);
      }
    }

    return Column(
      children: [
        _buildHeader(viewModel),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 45.0,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    GroupsViewModel viewModel,
  ) {
    List<Widget> items = []
      ..addAll(PresetWaves().showHorizontalWaves())
      ..add(_showBack(viewModel))
      ..add(_buildUserDetails(viewModel))
      ..add(_buildAppVersion(viewModel));

    return Container(
      height: 140.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: items,
      ),
    );
  }

  Widget _showBack(
    GroupsViewModel viewModel,
  ) {
    return Positioned(
      top: 26.0,
      left: 5.0,
      child: RawMaterialButton(
        shape: CircleBorder(),
        constraints: BoxConstraints.tight(Size(40.0, 40.0)),
        onPressed: () => _tapBack(viewModel),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white.withAlpha(90),
          size: 26.0,
        ),
      ),
    );
  }

  Widget _buildUserDetails(
    GroupsViewModel viewModel,
  ) {
    bool canUpdate = viewModel.updatingUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (viewModel.user.image == null)
                  ? Container()
                  : UserAvatar(
                      user: viewModel.user,
                      imageUrl: viewModel.user.image.secureUrl,
                      canUpdate: canUpdate,
                      onTap: canUpdate ? null : _tapAccount,
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  (viewModel.user?.name != null) ? viewModel.user.name : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion(
    GroupsViewModel viewModel,
  ) {
    if ((viewModel.user.version.version == null) ||
        (viewModel.user.version.buildNumber == null)) {
      return Container();
    }

    return Positioned(
      bottom: 2.0,
      right: 2.0,
      child: Container(
        child: Text(
          'v${viewModel.user.version.version} - b${viewModel.user.version.buildNumber}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _createSettingsSection() {
    return StickyHeader(
      header: SectionHeader(text: 'Settings'),
      content: Column(
        children: [
          ListSelectItem(
            title: 'Group Management',
            icon: Icons.group,
            onTap: () => _tapGroupsManagemenet(),
          ),
          ListDivider(),
          ListSelectItem(
            title: 'Location Sharing',
            icon: Icons.navigation,
            onTap: () => _tapLocationSharing(),
          ),
          ListDivider(),
          ListSelectItem(
            title: 'App Permissions',
            icon: Icons.settings_applications,
            iconSize: 22.0,
            onTap: () => _tapAppPermissions(),
          ),
        ],
      ),
    );

    /*
    tiles..add(ListDivider());
    tiles..add(ListSelectItem(
      title: 'Activity Detection',
      icon: Icons.timeline,
      onTap: () => _tapActivityDetection(),
    ));
    */
  }

  Widget _createAccountSection() {
    return StickyHeader(
      header: SectionHeader(text: 'My Account'),
      content: Column(
        children: [
          ListSelectItem(
            title: 'Account',
            icon: Icons.account_box,
            iconSize: 22.0,
            onTap: () => _tapAccount(),
          ),
          ListDivider(),
          ListSelectItem(
            title: 'Subscription',
            icon: Icons.stars,
            onTap: () => _tapSubscription(),
          ),
          ListDivider(),
          ListSelectItem(
            title: 'Privacy Policy',
            icon: Icons.security,
            onTap: () => _tapPrivacyPolicy(),
          ),
          ListDivider(),
          ListSelectItem(
            title: 'Log Out',
            icon: Icons.input,
            onTap: () => _tapLogout(),
          ),
        ],
      ),
    );
  }

  Future<Widget> _createUpdateSection() async {
    FirebaseUser user = await widget.authService.getCurrentUser();
    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Update Account'));
    tiles..add(_buildNameField(user));
    tiles..add(_buildEmailField(user));
    // tiles..add(_buildPhoneField(user)); // TODO
    tiles..add(_buildSave());
    tiles..addAll(_buildResetPassword());
    tiles..addAll(_buildDeleteButton());

    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: tiles,
        ),
      ),
    );
  }

  Widget _buildNameField(
    FirebaseUser user,
  ) {
    if (user == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: CustomTextField(
        initialValue: user.displayName,
        hintText: 'Your name',
        icon: Icons.person,
        validator: (value) => CommonValidators.validateName(
          value,
          text: 'your',
        ),
        onSaved: (String val) => (_name = val),
      ),
    );
  }

  Widget _buildEmailField(
    FirebaseUser user,
  ) {
    if (user == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: CustomTextField(
        initialValue: user.email,
        hintText: 'Your email address',
        icon: Icons.email,
        validator: (value) => CommonValidators.validateEmail(value),
        onSaved: (String val) => (_email = val),
      ),
    );
  }

  /*
  Widget _buildPhoneField(FirebaseUser user) {
    if (user == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: CustomTextField(
        initialValue: user.phoneNumber,
        hintText: 'Your phone number',
        icon: Icons.phone,
        onSaved: (String val) => (_phone = val),
      ),
    );
  }
  */

  Widget _buildSave() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FlatButton(
                color: AppTheme.primary,
                splashColor: AppTheme.primaryAccent,
                textColor: Colors.white,
                child: Text('Save'),
                shape: StadiumBorder(),
                onPressed: () => _tapSave(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withAlpha(90),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () => _tapCancelSave(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResetPassword() {
    return [
      SectionHeader(text: 'Reset Password'),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: FlatButton(
          color: AppTheme.primary,
          splashColor: AppTheme.primaryAccent,
          textColor: Colors.white,
          child: Text('Reset Password'),
          shape: StadiumBorder(),
          onPressed: () => _tapResetPassword(),
        ),
      )
    ];
  }

  List<Widget> _buildDeleteButton() {
    return [
      SectionHeader(text: 'Delete Account'),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: FlatButton(
          color: Colors.red,
          splashColor: Colors.redAccent[700],
          textColor: Colors.white,
          child: Text('Delete Account'),
          shape: StadiumBorder(),
          onPressed: () => _tapDeleteAccount(),
        ),
      )
    ];
  }

  void _tapGroupsManagemenet() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupsManagement));
  }

  void _tapLocationSharing() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.locationSharing));
  }

  void _tapAppPermissions() async {
    await LocationPermissions().openAppSettings();
  }

  /*
  void _tapActivityDetection() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.activityDetection));
  }
  */

  void _tapAccount() {
    StoreProvider.of<AppState>(context).dispatch(UpdatingUserAction(true));
  }

  void _tapSubscription() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.subscription));
  }

  void _tapPrivacyPolicy() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.privacyPolicy));
  }

  void _tapSave() async {
    _backdropAnimationController.forward();

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final store = StoreProvider.of<AppState>(context);
      FirebaseUser user = await widget.authService.getCurrentUser();

      // Update the displayName in the firebase user record
      if (_name != null) {
        UserUpdateInfo userUpdateInfo = UserUpdateInfo();
        userUpdateInfo.displayName = _name;
        await user.updateProfile(userUpdateInfo);
      }

      // Update the email address in the firebase user record
      if (_email != null) {
        await user.updateEmail(_email);
      }

      // Reload the firebase user
      await user.reload();

      // Update the state
      store.dispatch(SaveAccountAction(
        {
          'name': _name,
          'email': _email,
        },
        user.uid,
        animationController: _backdropAnimationController,
      ));

      closeKeyboard(context);
    } else {
      _backdropAnimationController.reverse();
    }
  }

  void _tapCancelSave() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(UpdatingUserAction(false));
  }

  void _tapResetPassword() async {
    final store = StoreProvider.of<AppState>(context);
    FirebaseUser user = await widget.authService.getCurrentUser();
    await widget.authService.resetPassword(
      user.email,
      store: store,
      bottomOffset: 53.0,
    );
  }

  void _tapLogout() async {
    Alert(
      context: context,
      title: 'LOG OUT',
      desc: 'Are you sure you want to logout?',
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
          child: Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () => _doLogout(),
          color: AppTheme.primary,
        ),
        DialogButton(
          child: Text(
            'No',
            style: TextStyle(
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

  void _tapDeleteAccount() async {
    Alert(
      context: context,
      title: 'DELETE ACCOUNT?',
      desc: 'Are you sure you want to delete your account? If you delete your account, ' +
          'you will permanetly lose your profile, messages and activity data. ',
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
          child: Text(
            'Delete Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          onPressed: () => _doDeleteAccount(),
          color: Colors.red,
        ),
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(
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

  void _tapBack(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);
    if (viewModel.updatingUser) {
      StoreProvider.of<AppState>(context).dispatch(UpdatingUserAction(false));
    } else {
      store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
      store.dispatch(NavigatePushAction(AppRoutes.home));
    }
  }

  void _doLogout() {
    try {
      widget.authService.signOut().then((value) {
        Navigator.pop(context);

        final store = StoreProvider.of<AppState>(context);
        store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
        store.dispatch(CancelFamilyDataEventsAction());
        store.dispatch(CancelGroupsDataEventsAction());

        widget.onSignedOut();
      }).catchError((onError) => logger.e(onError)); // TODO
    } catch (e) {
      // TODO
      logger.e(e);
    }
  }

  void _doDeleteAccount() async {
    widget.authService.getCurrentUser().then((user) async {
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(DeleteAccountAction(user.uid));
    });
  }
}
