import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with TickerProviderStateMixin {
  Completer<WebViewController> _controller = Completer<WebViewController>();

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
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            title: Text(
              'Privacy Policy',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: Stack(
            children: <Widget>[
              WebView(
                initialUrl: viewModel.configValue('privacy_policy_url'),
                onWebViewCreated: (
                  WebViewController webViewController,
                ) {
                  _controller.complete(webViewController);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
