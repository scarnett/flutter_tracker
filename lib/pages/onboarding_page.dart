import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/widgets/onboarding.dart';
import 'package:flutter_tracker/widgets/wavy_background.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
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
      onInit: (store) => store.dispatch(RequestOnboardingAction()),
      builder: (_, viewModel) => Scaffold(
        body: Stack(
          children: <Widget>[
            OnBoarding(
              pageList: hasOnboarding(viewModel) ? viewModel.onboarding : [],
              onDoneButtonPressed: () => _tapDone(),
              onSkipButtonPressed: () => _tapDone(),
            ),
            Positioned(
              bottom: 50.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: IgnorePointer(
                  child: Center(
                    child: buildLogo(),
                  ),
                ),
              ),
            ),
          ]..addAll(
              PresetWaves().noWaves(
                waves: PresetWaves().defaultWaves(),
              ),
            ),
        ),
      ),
    );
  }

  void _tapDone() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(CancelOnboardingAction());
    store.dispatch(SetAuthStatusAction(AuthStatus.NOT_LOGGED_IN));
  }

  bool hasOnboarding(
    GroupsViewModel viewModel,
  ) {
    return (viewModel.onboarding != null) && (viewModel.onboarding.length > 0);
  }
}
