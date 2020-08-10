import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/map_utils.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/widgets/active_driver_data.dart';
import 'package:flutter_tracker/widgets/map_center.dart';
import 'package:flutter_tracker/widgets/place_pin.dart';
import 'package:latlong/latlong.dart' as latlng;
import 'package:flutter_tracker/widgets/user_pin.dart';

class ActivityMap extends StatefulWidget {
  final dynamic type;
  final List<dynamic> routePoints;
  final List<dynamic> members;
  final dynamic place;
  final dynamic location;
  final double maxHeight;
  final double lineWidth;
  final bool interactive;
  final bool canRecenter;
  final bool showHeading;
  final ActivityMapState appState = ActivityMapState();

  ActivityMap({
    Key key,
    this.type = ActivityType.IN_VEHICLE,
    this.routePoints,
    this.members,
    this.place,
    this.location,
    this.maxHeight,
    this.lineWidth = 2.0,
    this.interactive = false,
    this.canRecenter = false,
    this.showHeading = false,
  }) : super(key: key);

  @override
  State createState() => appState;
}

class ActivityMapState extends State<ActivityMap>
    with TickerProviderStateMixin {
  bool _loaded;
  final MapController _mapController = MapController();
  LatLngBounds _mapBounds;
  bool _mapPanning = false;
  Timer _panningDebounce;
  List<latlng.LatLng> _points = List<latlng.LatLng>();
  List<Marker> _markers;
  List<CircleMarker> _groupMarkers;
  double _minZoom = 10.0;

  @override
  void initState() {
    super.initState();

    setState(() {
      _loaded = false;
      _mapBounds = LatLngBounds();

      switch (widget.type) {
        case ActivityType.ON_FOOT:
        case ActivityType.WALKING:
        case ActivityType.RUNNING:
        case ActivityType.ON_BICYCLE:
        case ActivityType.IN_VEHICLE:
          _points = _buildRoutePoints();
          _markers = _buildRouteMarkers();
          break;

        case ActivityType.CHECKIN_SENDER:
        case ActivityType.CHECKIN_RECEIVER:
          _markers = _buildMemberMarkers();
          break;

        default:
          break;
      }

      if (_markers == null) {
        switch (widget.type) {
          case ActivityEventType.DRIVING_STARTED:
          case ActivityEventType.DRIVING_STOPPED:
          case ActivityEventType.GEOFENCE_ENTERING:
          case ActivityEventType.GEOFENCE_LEAVING:
            _markers = _buildGeofenceMarkers();
            break;

          default:
            break;
        }
      }
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
      builder: (_, viewModel) => Column(
        children: [
          _buildMap(viewModel),
        ],
      ),
    );
  }

  Widget _buildMap(
    GroupsViewModel viewModel,
  ) {
    _mapController.onReady.then((_) {
      if (!_loaded && mounted) {
        fitBounds();
        setState(() {
          _minZoom = _mapController
              .zoom; // This will not allow the user to zoom out any further
          _loaded = true;
        });
      }
    });

    Widget map = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: widget.interactive ? 0.0 : 1.0,
                    color: AppTheme.inactive(),
                  ),
                ),
                child: _getMap(viewModel),
              ),
            ]..addAll(_getMapOverlays()),
          ),
        ),
      ],
    );

    if (widget.maxHeight != null) {
      return Container(
        height: widget.maxHeight,
        child: map,
      );
    }

    return Expanded(
      child: map,
    );
  }

  FlutterMap _getMap(
    GroupsViewModel viewModel,
  ) {
    FlutterMap _map;

    switch (widget.type) {
      case ActivityType.CHECKIN_RECEIVER:
      case ActivityType.CHECKIN_SENDER:
        _map = buildMap(
          viewModel,
          _mapController,
          onPositionChanged: (position, hasGesture) =>
              _positionChanged(position, hasGesture, viewModel),
          interactive: widget.interactive,
          minZoom: _minZoom,
          mapMarkers: _markers,
        );
        break;

      case ActivityType.IN_VEHICLE:
        _map = buildMap(
          viewModel,
          _mapController,
          onPositionChanged: (position, hasGesture) =>
              _positionChanged(position, hasGesture, viewModel),
          interactive: widget.interactive,
          minZoom: _minZoom,
          mapMarkers: _markers,
          points: _points,
          strokeWidth: widget.lineWidth,
        );
        break;
    }

    if (_map == null) {
      switch (widget.type) {
        case ActivityEventType.DRIVING_STARTED:
        case ActivityEventType.DRIVING_STOPPED:
        case ActivityEventType.GEOFENCE_ENTERING:
        case ActivityEventType.GEOFENCE_LEAVING:
          _map = buildMap(
            viewModel,
            _mapController,
            onPositionChanged: (position, hasGesture) =>
                _positionChanged(position, hasGesture, viewModel),
            interactive: widget.interactive,
            minZoom: _minZoom,
            mapMarkers: _markers,
            circleMapMarkers: _groupMarkers,
          );
          break;
      }
    }

    return _map;
  }

  List<Widget> _getMapOverlays() {
    List<Widget> overlays = List<Widget>();

    switch (widget.type) {
      case ActivityEventType.DRIVING_STARTED:
      case ActivityEventType.DRIVING_STOPPED:
      case ActivityEventType.GEOFENCE_ENTERING:
      case ActivityEventType.GEOFENCE_LEAVING:
        overlays
          ..add(
            ActiveDriverData(
              location: Location.fromJson(widget.location),
            ),
          );
        break;

      default:
        break;
    }

    overlays
      ..add(
        MapCenter(
          enabled: widget.canRecenter,
          mapPanning: _mapPanning,
          onTap: _tapCenterMap,
        ),
      );

    return overlays;
  }

  List<latlng.LatLng> _buildRoutePoints() {
    List<latlng.LatLng> points = List<latlng.LatLng>();

    if (widget.routePoints != null) {
      widget.routePoints.forEach((point) {
        latlng.LatLng latLng = toLatLng(point['location']);
        if (latLng != null) {
          points..add(latLng);
          _mapBounds.extend(latLng);
        }
      });
    }

    return points;
  }

  List<Marker> _buildRouteMarkers() {
    _markers = List<Marker>();

    const double _startIconSize = 20.0;
    const double _endIconSize = 30.0;

    if ((widget.routePoints != null) && (widget.routePoints.length > 1)) {
      // Starting point
      dynamic startActivity = widget.routePoints.first;
      _markers
        ..add(
          Marker(
            width: _startIconSize,
            height: _startIconSize,
            point: toLatLng(startActivity['location']),
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) => GestureDetector(
              child: PlacePin(
                color: AppTheme.still(),
                icon: Icons.album,
                size: _startIconSize,
              ),
            ),
          ),
        );

      // Ending point
      dynamic endActivity = widget.routePoints.last;
      _markers
        ..add(
          Marker(
            width: _endIconSize,
            height: _endIconSize,
            point: toLatLng(endActivity['location']),
            anchorPos: AnchorPos.align(AnchorAlign.top),
            builder: (context) => GestureDetector(
              child: PlacePin(
                color: AppTheme.primary,
                size: _endIconSize,
              ),
            ),
          ),
        );

      // All Points in-between
      if (widget.showHeading) {
        int count = 0;
        widget.routePoints.forEach((entry) {
          count++;

          // Skip the first point, skip the last point and only show every 5th point in-between
          if ((count > 1) &&
              (count < widget.routePoints.length) &&
              (count % 5 == 0)) {
            _markers
              ..add(
                Marker(
                  width: 12.0,
                  height: 12.0,
                  point: toLatLng(entry['location']),
                  anchorPos: AnchorPos.align(AnchorAlign.center),
                  builder: (context) => GestureDetector(
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(
                          entry['location']['coords']['heading'] / 360),
                      child: Icon(
                        Icons.navigation,
                        color: Colors.black.withOpacity(0.7),
                        size: 12.0,
                      ),
                    ),
                  ),
                ),
              );
          }
        });
      }
    }

    return _markers;
  }

  List<Marker> _buildMemberMarkers() {
    _markers = List<Marker>();

    if (widget.members != null) {
      widget.members.forEach((dynamic member) {
        latlng.LatLng latLng = toLatLng(member['location']);
        _mapBounds.extend(latLng);

        UserPin userPin = UserPin(
          member: GroupMember.fromJson(member['uid'], member),
          showDot: true,
          forceOnline: true,
          showLocationSharingNotification: false,
          showLocationAccuracyNotification: false,
        );

        // Adds the activity icon to the map marker
        userPin.addAction(member['icon']);

        _markers
          ..add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng,
              anchorPos: AnchorPos.align(AnchorAlign.top),
              builder: (context) => Tooltip(
                message: (member['name'] == null) ? '' : member['name'],
                preferBelow: false,
                margin: EdgeInsets.only(bottom: 10.0),
                child: userPin,
              ),
            ),
          );
      });
    }

    return _markers;
  }

  List<Marker> _buildGeofenceMarkers() {
    _markers = List<Marker>();
    _groupMarkers = List<CircleMarker>();

    // Adds the place pin and geofence
    if (widget.place != null) {
      latlng.LatLng placeLatLng = toLatLng(widget.place['details']['position']);
      _mapBounds.extend(placeLatLng);

      _groupMarkers
        ..add(
          buildPlaceRadiusMarker(
            Place.fromJson(widget.place),
            opacity: 0.05, // TODO: enum
          ),
        );

      _markers
        ..add(
          Marker(
            width: 30.0,
            height: 30.0,
            point: placeLatLng,
            anchorPos: AnchorPos.align(AnchorAlign.top),
            builder: (context) => Tooltip(
              message: widget.place['name'],
              preferBelow: false,
              child: PlacePin(
                size: 30.0,
                showDot: true,
              ),
            ),
          ),
        );
    }

    // Adds the group member pin
    if (widget.members != null) {
      dynamic member = widget.members[0];
      if (member != null) {
        latlng.LatLng memberLatLng = toLatLng(member['location']);
        _mapBounds.extend(memberLatLng);

        UserPin userPin = UserPin(
          member: GroupMember.fromJson(member['uid'], member),
          showDot: true,
          forceOnline: true,
          showLocationSharingNotification: false,
          showLocationAccuracyNotification: false,
        );

        _markers
          ..add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: memberLatLng,
              anchorPos: AnchorPos.align(AnchorAlign.top),
              builder: (context) => Tooltip(
                message: (member['name'] == null) ? '' : member['name'],
                preferBelow: false,
                margin: EdgeInsets.only(bottom: 10.0),
                child: userPin,
              ),
            ),
          );
      }
    }

    return _markers;
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
      }
    });
  }

  void _tapCenterMap() {
    fitBounds();
    setState(() {
      _mapPanning = false;
    });
  }

  fitBounds() {
    switch (widget.type) {
      case ActivityType.CHECKIN_RECEIVER:
      case ActivityType.CHECKIN_SENDER:
        fitMarkerBounds(
          _mapController,
          _mapBounds,
          padding: const EdgeInsets.symmetric(
            vertical: 120.0,
            horizontal: 100.0,
          ),
        );
        break;

      case ActivityType.IN_VEHICLE:
        fitMarkerBounds(
          _mapController,
          _mapBounds,
        );
        break;
    }

    switch (widget.type) {
      case ActivityEventType.DRIVING_STARTED:
      case ActivityEventType.DRIVING_STOPPED:
      case ActivityEventType.GEOFENCE_ENTERING:
      case ActivityEventType.GEOFENCE_LEAVING:
        fitMarkerBounds(
          _mapController,
          _mapBounds,
          padding: const EdgeInsets.symmetric(
            vertical: 120.0,
            horizontal: 100.0,
          ),
        );
        break;

      default:
        break;
    }
  }
}
