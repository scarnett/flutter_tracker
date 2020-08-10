import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class GroupsChatPage extends StatefulWidget {
  final Store store;

  GroupsChatPage({
    Key key,
    this.store,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsChatPageState();
}

class _GroupsChatPageState extends State<GroupsChatPage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => _createContent(),
    );
  }

  Widget _createContent() {
    return Container();
  }
}
