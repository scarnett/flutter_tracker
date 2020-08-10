import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/place_utils.dart';

class GroupsAppBar extends StatefulWidget {
  GroupsAppBar({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => GroupsAppBarState();
}

class GroupsAppBarState extends State<GroupsAppBar>
    with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: BackButton(
              onPressed: () => _tapBack(viewModel),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _getText(viewModel),
              ),
            ),
          ),
          /*
            RawMaterialButton(
              shape: GroupBorder(),
              constraints: BoxConstraints.tight(Size(40.0, 40.0)),
              onPressed: () {},
              child: const Icon(
                Icons.autorenew,
                color: AppTheme.primary,
                size: 26.0,
              ),
            ),
            RawMaterialButton(
              shape: GroupBorder(),
              constraints: BoxConstraints.tight(Size(40.0, 40.0)),
              onPressed: () {},
              child: const Icon(
                Icons.chat_bubble,
                color: AppTheme.primary,
                size: 26.0,
              ),
            ),
            */
        ],
      ),
    );
  }

  void _tapBack(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    if (viewModel.activeGroupMember != null) {
      store.dispatch(ClearActiveGroupMemberAction());
    }

    if (viewModel.activePlace != null) {
      store.dispatch(ClearActivePlaceAction());
    }
  }

  List<Widget> _getText(
    GroupsViewModel viewModel,
  ) {
    if (viewModel.activeGroupMember != null) {
      return getGroupMemberText(viewModel.activeGroupMember, viewModel);
    } else if (viewModel.activePlace != null) {
      return getPlaceText(viewModel.activePlace, viewModel.latestPlaceActivity);
    }

    return [];
  }
}
