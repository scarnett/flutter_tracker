import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tracker/utils/map_utils.dart';
import 'package:flutter_tracker/utils/math_utils.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/utils/uom_utils.dart';
import 'package:flutter_tracker/widgets/map_center.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:latlong/latlong.dart' as latlng;

class PlaceMap extends StatefulWidget {
  final latlng.LatLng initialPosition;
  final double mapHeight;
  final bool expandMap;
  final bool canRecenter;
  final bool showDistance;
  final double initialDistance;
  final Function positionCallback;
  final PlaceMapState appState = PlaceMapState();

  PlaceMap({
    Key key,
    this.initialPosition,
    this.mapHeight = 240.0,
    this.expandMap = false,
    this.canRecenter = true,
    this.showDistance = true,
    this.initialDistance = 100.0,
    this.positionCallback,
  }) : super(key: key);

  @override
  State createState() => appState;
}

class PlaceMapState extends State<PlaceMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Place _originalPlace;
  latlng.LatLng _currentPosition;
  double _currentZoomLevel;
  double _maxZoomLevel = 17.0;
  double _minZoomLevel = 10.0;
  double _sliderValue;
  double _distanceRadius;
  double _minDistanceRadius = 100.0;
  bool _mapPanning = false;
  Timer _panningDebounce;
  LatLngBounds _mapBounds;

  @override
  void initState() {
    super.initState();

    setState(() {
      _distanceRadius = widget.initialDistance;
      _currentZoomLevel = _autoMapZoomLevel(_distanceRadius);
      _sliderValue = _currentZoomLevel;
    });
  }

  @override
  void dispose() {
    _mapPanning = false;
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      onInit: (store) {
        if (widget.initialPosition != null) {
          _currentPosition = widget.initialPosition;
        }
      },
      builder: (_, viewModel) {
        if (_originalPlace == null) {
          _originalPlace = viewModel.activePlace;
        }

        if (_currentPosition == null) {
          if (viewModel.activePlace == null) {
            _currentPosition = latlng.LatLng(
              viewModel.user.location.coords.latitude,
              viewModel.user.location.coords.longitude,
            );
          } else {
            _currentPosition = latlng.LatLng(
              viewModel.activePlace.details.position[0],
              viewModel.activePlace.details.position[1],
            );
          }
        }

        List<Widget> children = [
          widget.expandMap
              ? Expanded(
                  child: _buildMap(viewModel),
                )
              : _buildMap(viewModel),
          _buildDistanceSlider(),
        ];

        return Column(
          children: filterNullWidgets(children),
        );
      },
    );
  }

  Widget _buildMap(
    GroupsViewModel viewModel,
  ) {
    _mapBounds = LatLngBounds();
    _mapBounds.extend(_currentPosition);

    FlutterMap _map = buildMap(
      viewModel,
      _mapController,
      position: _currentPosition,
      zoom: _currentZoomLevel,
      // minZoom: _currentZoomLevel,
      // maxZoom: _currentZoomLevel,
      // interactive: false,
      onPositionChanged: (position, hasGesture) =>
          _positionChanged(position, hasGesture, viewModel),
      mapScaleOffset: 20.0,
    );

    return SizedBox(
      height: widget.mapHeight,
      width: double.infinity,
      child: Stack(
        children: [
          _map,
          MapCenter(
            enabled: widget.canRecenter,
            mapPanning: _mapPanning,
            onTap: _tapCenterMap,
          ),
          Center(
            child: buildMarkerLayer(showDistance: widget.showDistance),
          ),
        ],
      ),
    );
  }

  /*
  Marker _buildMarker(
    latlng.LatLng latLng,
  ) {
    return Marker(
      width: MediaQuery.of(context).size.width,
      // height: widget.mapHeight,
      point: latLng,
      anchorPos: AnchorPos.align(AnchorAlign.center),
      builder: (context) => InkWell(
        onTap: null,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildMarkerGroup(),
            PlaceIcon(),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildDistanceSlider() {
    return widget.showDistance
        ? Column(
            children: [
              SectionHeader(text: 'Zone Distance'),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Slider(
                        min: _minZoomLevel,
                        max: _maxZoomLevel,
                        onChanged: _setZoom,
                        value: _sliderValue,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(formatMetersToFeet(_distanceRadius)),
                    ),
                  ],
                ),
              ),
            ],
          )
        : null;
  }

  void _positionChanged(
    MapPosition position,
    bool hasGesture,
    GroupsViewModel viewModel,
  ) {
    if (_panningDebounce?.isActive ?? false) {
      _panningDebounce.cancel();
    }

    _panningDebounce = Timer(const Duration(milliseconds: 250), () {
      if (hasGesture) {
        setState(() {
          _mapPanning = true;
        });

        _setZoom(position.zoom);

        StoreProvider.of<AppState>(context)
            .dispatch(UpdateActivePlaceAction(position.center));
      }

      if (widget.positionCallback != null) {
        widget.positionCallback(
          position.center,
          _distanceRadius,
        );
      }
    });
  }

  void _tapCenterMap() {
    setState(() {
      _mapPanning = false;
    });

    fitMarkerBounds(
      _mapController,
      _mapBounds,
    );

    StoreProvider.of<AppState>(context)
        .dispatch(UpdateActivePlaceAction(_mapController.center));
  }

  double _autoMapZoomLevel(
    double radius,
  ) {
    if (radius != null) {
      double _zoomLevel = 0;
      double _radius = (radius + (radius * 2.0));
      double _scale = (_radius / 328.084); // ~ 100m

      try {
        _zoomLevel = (_maxZoomLevel - (math.log(_scale) / math.log(2)));
        if (_zoomLevel == double.infinity) {
          _zoomLevel = _maxZoomLevel;
        }
      } catch (exception) {
        _zoomLevel = _maxZoomLevel;
      }

      if (_zoomLevel > _maxZoomLevel) {
        _zoomLevel = _maxZoomLevel;
      } else if (_zoomLevel < _minZoomLevel) {
        _zoomLevel = _minZoomLevel;
      }

      return _zoomLevel;
    }

    return _minZoomLevel;
  }

  void _setZoom(
    double zoomLevel,
  ) {
    setState(() {
      if (zoomLevel > _maxZoomLevel) {
        _sliderValue = _maxZoomLevel;
      } else if (zoomLevel < _minZoomLevel) {
        _sliderValue = _minZoomLevel;
      } else {
        _sliderValue = zoomLevel;
      }

      double percent = round(
          (_sliderValue - _maxZoomLevel) / (_minZoomLevel - _maxZoomLevel), 2);
      double multiplier = ((_maxZoomLevel - zoomLevel) + 1);
      _distanceRadius = (multiplier * (1000.0 * percent));
      if (_distanceRadius < _minDistanceRadius) {
        _distanceRadius = _minDistanceRadius;
      }

      // logger.d(_sliderValue);
      // logger.d(_autoMapZoomLevel(_distanceRadius));
      // logger.d(_distanceRadius);
    });

    // final double zoom = _autoMapZoomLevel(_distanceRadius);
    _mapController.move(_mapController.center, zoomLevel);
  }
}
