import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/plan_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:redux/redux.dart';

class MapTypePage extends StatefulWidget {
  final Store store;

  MapTypePage({
    Key key,
    this.store,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapTypePageState();
}

class _MapTypePageState extends State<MapTypePage> {
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
              'Change Map Type',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    Plan plan = viewModel.activePlan;
    List<Widget> maps = List<Widget>();

    if (viewModel.maps != null) {
      int count = 0;

      viewModel.maps
          // .where((map) => map.plans.contains(plan.documentId))
          .forEach((map) {
        maps
          ..add(
            Padding(
              padding: EdgeInsets.only(
                top: 1.0,
                right: (count % 1 == 0) ? 1.0 : 0.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: _buildPreviewContainer(viewModel, map, plan),
                  ),
                ],
              ),
            ),
          );

        count++;
      });
    }

    List<Widget> children = List<Widget>();
    children
      ..add(
        Expanded(
          child: Container(
            width: double.infinity,
            child: GridView.count(
              crossAxisCount: 2,
              children: maps,
            ),
          ),
        ),
      );

    if (needsUpgrade(viewModel.activePlan, 'map_types_advanced', true)) {
      children
        ..add(
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.inactive(),
                ),
              ),
            ),
            child: Material(
              child: InkWell(
                onTap: () => _tapSubscriptions(),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: const Icon(
                          Icons.stars,
                          color: AppTheme.primary,
                          size: 20.0,
                        ),
                      ),
                      Text(
                        'Upgrade for more map types!',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildPreviewContainer(
    GroupsViewModel viewModel,
    MapBox map,
    Plan plan,
  ) {
    // Check the plan to make sure the map type is allowed to be used
    if ((plan == null) ||
        (needsUpgrade(viewModel.activePlan, 'map_types_advanced', true) &&
            !map.plans.contains(plan.documentId))) {
      return Opacity(
        opacity: 0.3,
        child: _buildPreviewImage(
          map,
          canTap: false,
        ),
      );
    }

    return _buildPreviewImage(map);
  }

  Widget _buildPreviewImage(
    MapBox map, {
    bool canTap = true,
  }) {
    final store = StoreProvider.of<AppState>(context);
    if (store.state.user == null) {
      return Container();
    }

    UserMapData mapData = store.state.user.mapData;
    String imageUrl = cloudinaryTransformUrl(
      map.image,
      transformation: 'map',
    );

    return Stack(
      children: <Widget>[
        (map.image == null)
            ? Container(
                color: AppTheme.hint,
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error),
                ),
              ),
        Container(
          color: AppTheme.background().withOpacity(0.5),
          height: 40.0,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  map.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                (mapData.mapType == map.code)
                    ? RawMaterialButton(
                        fillColor: AppTheme.primary,
                        shape: CircleBorder(),
                        constraints: BoxConstraints.tight(Size(20.0, 20.0)),
                        onPressed: null,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14.0,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        canTap
            ? Positioned.fill(
                child: Material(
                  child: InkWell(
                    onTap: () => _tapMapType(map),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  _tapMapType(
    MapBox map,
  ) {
    final store = StoreProvider.of<AppState>(context);
    Map<String, dynamic> mapData = store.state.user.mapData.toJson();
    mapData['map_type'] = map.code;
    store.dispatch(SetMapDataAction(mapData));

    // The purpose of this delay is to keep the view from closing to quickly after a map type was tapped in the menu.
    // I wanted to show the checkbox updating itself in the menu before the navigation popped. - Scott
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
    });
  }

  _tapSubscriptions() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.subscription));
  }
}
