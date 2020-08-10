import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/widgets/empty_state_message.dart';
import 'package:flutter_tracker/widgets/fab_list.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/list_show_more.dart';
import 'package:flutter_tracker/widgets/place_icon.dart';
import 'package:redux/redux.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class GroupsPlacesPage extends StatefulWidget {
  final Store store;

  GroupsPlacesPage({
    Key key,
    this.store,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsPlacesPageState();
}

class _GroupsPlacesPageState extends State<GroupsPlacesPage> {
  final SlidableController _slidableController = SlidableController();

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          _tapBack();
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              'Places',
              style: TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _tapBack(),
            ),
          ),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);
    List<Widget> tiles = [];
    List<Widget> actionItems = [];

    if (viewModel.groupPlaces == null) {
      tiles..add(_buildNoneFound());
      tiles..add(ListDivider());
    } else {
      List<dynamic> places = viewModel.groupPlaces;
      if ((places == null) || (places.length == 0)) {
        tiles..add(_buildNoneFound());
        tiles..add(ListDivider());
      } else {
        /*
        if (needsUpgrade(
            viewModel.activePlan, 'advertisements_enabled', true)) {
          places = injectAd<dynamic>(places, bannerAd(viewModel));
        }
        */

        places.forEach((place) {
          if (place.runtimeType == Place) {
            tiles
              ..add(
                Slidable(
                  key: ValueKey(place.documentId),
                  controller: _slidableController,
                  actionPane: SlidableBehindActionPane(),
                  actionExtentRatio: 0.25,
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        place.name,
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      subtitle: Text(
                        place.details.vicinity,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                      ),
                      leading: PlaceIcon(),
                      trailing: ListShowMore(),
                      onTap: () => _tapPlace(place),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                    ),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Activity',
                      color: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      icon: Icons.notification_important,
                      onTap: () => _tapPlaceActivity(place),
                    ),
                  ],
                ),
              );
          } else {
            tiles..add(place);
          }

          tiles..add(ListDivider());
        });
      }
    }

    actionItems
      ..add(
        menuActionButton(
          'Add Place',
          Icons.add,
          AppTheme.primary,
          () => showCreateGroup(context, store),
        ),
      );

    tiles..add(buildMenuActions(actionItems));

    /*
    if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
      tiles
        ..addAll(
          [
            ListDivider(),
            bannerAd(viewModel),
          ],
        );
    }
    */

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 45.0,
            ),
            child: FabList(
              tiles: tiles,
              tooltip: 'Add Place',
              onTap: () => _tapPlaceList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoneFound() {
    return EmptyStateMessage(message: 'You haven\'t added any places yet');
  }

  void _tapPlace(
    Place place,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ActivatePlaceAction(place));
    store.dispatch(NavigatePushAction(AppRoutes.groupPlacesDetails));
  }

  void _tapPlaceActivity(
    Place place,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ActivatePlaceAction(place));
    store.dispatch(CancelPlaceActivityAction());
    store.dispatch(RequestPlaceActivityAction(place.documentId));
    store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
    store.dispatch(NavigatePushAction(AppRoutes.home));
  }

  void _tapPlaceList() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupPlacesList));
  }

  void _tapBack() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
    store.dispatch(NavigatePushAction(AppRoutes.home));
  }
}
