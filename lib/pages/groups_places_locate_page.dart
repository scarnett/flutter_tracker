import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/map_type_fab.dart';
import 'package:flutter_tracker/widgets/place_icon.dart';
import 'package:flutter_tracker/widgets/place_map.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:latlong/latlong.dart' as latlng;

class GroupsPlacesLocatePage extends StatefulWidget {
  GroupsPlacesLocatePage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsPlacesLocatePageState();
}

class _GroupsPlacesLocatePageState extends State<GroupsPlacesLocatePage>
    with TickerProviderStateMixin {
  AnimationController _detailsBackdropAnimationController;
  latlng.LatLng _position;

  @override
  void initState() {
    super.initState();

    setState(() {
      _detailsBackdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );
    });
  }

  @override
  void dispose() {
    _detailsBackdropAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      onInit: _activatePlace,
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          final store = StoreProvider.of<AppState>(context);
          // store.dispatch(ClearActivePlaceAction());
          store.dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: const Text(
              'Locate a Place',
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
    return Container(
      child: Material(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  PlaceMap(
                    initialPosition: _position,
                    expandMap: true,
                    canRecenter: false,
                    showDistance: false,
                    positionCallback: (
                      latlng.LatLng position,
                      double zoneDistance,
                    ) {
                      _position = position;
                    },
                  ),
                  MapTypeFab(
                    onTap: () => _tapMapType(),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildPlaceDetails(viewModel),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 10.0,
                          top: 0.0,
                        ),
                        child: FlatButton(
                          color: AppTheme.primary,
                          splashColor: AppTheme.primaryAccent,
                          textColor: Colors.white,
                          child: const Text('Next'),
                          shape: StadiumBorder(),
                          onPressed: () => _tapPlaceDetails(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _activatePlace(
    final store,
  ) {
    _position = latlng.LatLng(
      store.state.user.location.coords.latitude,
      store.state.user.location.coords.longitude,
    );

    store.dispatch(UpdateActivePlaceAction(_position));
  }

  Widget _buildPlaceDetails(
    GroupsViewModel viewModel,
  ) {
    Place place = viewModel.activePlace;
    if (place == null) {
      return _buildLocating();
    }

    if (place != null) {
      if (viewModel.searchingPlaces) {
        _detailsBackdropAnimationController.forward();
      } else if (_detailsBackdropAnimationController.isCompleted) {
        _detailsBackdropAnimationController.reverse();
      }
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 10.0,
            right: 10.0,
            bottom: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: PlaceIcon(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    viewModel.activePlace.details.vicinity,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        showLoadingBackdrop(
          _detailsBackdropAnimationController,
          condition: viewModel.searchingPlaces,
          backdropColor: Colors.white,
          opacity: 0.9,
        ),
      ],
    );
  }

  Widget _buildLocating() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(3.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: const Text(
              'Please Wait...',
            ),
          ),
        ],
      ),
    );
  }

  _tapMapType() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.mapType));
  }

  _tapPlaceDetails() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupPlacesDetails));
  }
}
