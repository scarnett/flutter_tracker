import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/widgets/wavy_background.dart';

class UpgradePage extends StatefulWidget {
  UpgradePage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage>
    with TickerProviderStateMixin {
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
      onInit: (store) {
        store.dispatch(RequestPlansAction());
      },
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: _createContent(context, viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 0.9],
              colors: [
                Colors.pink,
                Colors.pink[900],
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'WHOOPS!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 28.0,
                      shadows: commonTextShadow(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 40.0),
                    child: Text(
                      'It looks like you\'ve reached a limit on your current subscription level. ' +
                          'Please upgrade your subscription to unlock more space.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        shadows: commonTextShadow(),
                      ),
                    ),
                  ),
                  FlatButton(
                    color: AppTheme.primary,
                    splashColor: AppTheme.primaryAccent,
                    textColor: Colors.white,
                    child: Text('Upgrade Now'),
                    shape: StadiumBorder(),
                    onPressed: () => _tapSubscription(),
                  ),
                  FlatButton(
                    color: Colors.transparent,
                    splashColor: AppTheme.primaryAccent,
                    textColor: Colors.white.withOpacity(0.7),
                    child: Text('No, Thanks'),
                    shape: StadiumBorder(),
                    onPressed: () => _tapNoThanks(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 26.0,
          left: 5.0,
          child: RawMaterialButton(
            shape: CircleBorder(),
            constraints: BoxConstraints.tight(Size(40.0, 40.0)),
            onPressed: () => _tapNoThanks(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white.withAlpha(90),
              size: 26.0,
            ),
          ),
        ),
      ]..addAll(
          PresetWaves().noWaves(
            waves: PresetWaves().defaultWaves(),
          ),
        ),
    );
  }

  void _tapSubscription() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.subscription));
  }

  void _tapNoThanks() {
    Navigator.pop(context);
  }
}
