import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/location_utils.dart';
import 'package:flutter_tracker/utils/map_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';
import 'package:flutter_tracker/widgets/active_driver_data.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/location_permission_fab.dart';
import 'package:flutter_tracker/widgets/map_center.dart';
import 'package:flutter_tracker/widgets/map_type_fab.dart';
import 'package:flutter_tracker/widgets/place_pin.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/widgets/user_pin.dart';
import 'package:latlong/latlong.dart' as latlng;

class GroupsMap extends StatefulWidget {
  final String mapType;
  final GroupsMapState appState = GroupsMapState();

  GroupsMap({
    Key key,
    this.mapType = 'STREETS',
  }) : super(key: key);

  @override
  State createState() => appState;

  bool isPanning() {
    return appState._mapPanning;
  }

  void centerMap({
    bool clearPanning = true,
  }) {
    if (clearPanning) {
      appState._panningPosition = null;
      appState._mapPanning = false;
    }

    fitMarkerBounds(
      appState._mapController,
      appState._mapBounds,
      padding: const EdgeInsets.symmetric(
        vertical: 180.0,
        horizontal: 100.0,
      ),
    );
  }
}

class GroupsMapState extends State<GroupsMap> with TickerProviderStateMixin {
  AnimationController _mapAnimationController;
  AnimationController _backdropAnimationController;

  final MapController _mapController = MapController();
  List<Marker> _mapMarkers;
  List<CircleMarker> _mapGroupMarkers;
  LatLngBounds _mapBounds;
  MapPosition _panningPosition;
  bool _mapPanning = false;

  Group _currentGroup;
  GroupMember _currentGroupMember;
  Place _currentPlace;
  latlng.LatLng _currentPosition;

  double _markerSize = 74.0;
  double _markerPadding = 10.0;
  double _currentZoomLevel = 13.0;
  double _maxZoomLevel = 17.0;
  double _minZoomLevel = 10.0;
  bool _isLoaded = false;
  Timer _panningDebounce;

  Animation<double> _mapAnimation;
  Tween<double> _latTween;
  Tween<double> _lngTween;
  Tween<double> _zoomTween;

  @override
  void initState() {
    super.initState();

    setState(() {
      _mapAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      );

      _backdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );

      _backdropAnimationController.forward();
      _mapAnimation = CurvedAnimation(
        parent: _mapAnimationController,
        curve: Curves.fastOutSlowIn,
      );
    });

    _mapAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // _mapAnimationController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        // _mapAnimationController.dispose();
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        if (viewModel.user == null) {
          _currentPosition = _defaultPosition();
        } else {
          if (!_isLoaded && (_currentPosition == null)) {
            _setInitialPosition(viewModel.user);
          }

          _isLoaded = true;
        }

        if (_isLoaded) {
          _setMapData(viewModel);
        }

        List<Widget> children = []..addAll(
            [
              _buildMap(viewModel),
              ActiveDriverData(
                member: viewModel.activeGroupMember,
              ),
              MapCenter(
                mapPanning: widget.isPanning(),
                bottomPosition: DEFAULT_PANEL_FAB_OFFSET,
                onTap: widget.centerMap,
              ),
              LocationPermissionFab(
                bottomPosition: DEFAULT_PANEL_FAB_OFFSET,
                onTap: () => _tapRequestLocationPermission(),
              ),
              MapTypeFab(
                bottomPosition: DEFAULT_PANEL_FAB_OFFSET,
                onTap: () => _tapMapType(),
              ),
              showLoadingBackdrop(
                _backdropAnimationController,
                condition: !_isLoaded,
              ),
            ],
          );

        double offset = 0.0;
        if ((viewModel.activeGroupMember != null) ||
            (viewModel.activePlace != null)) {
          offset = APPBAR_HEIGHT;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: offset),
          child: Stack(
            children: filterNullWidgets(children),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _currentGroup = null;
    _currentGroupMember = null;
    _currentPlace = null;
    _panningPosition = null;
    _mapPanning = false;
    _mapAnimationController.dispose();
    _backdropAnimationController.dispose();
    super.dispose();
  }

  Widget _buildMap(
    GroupsViewModel viewModel,
  ) {
    if ((_mapMarkers == null) || (_mapMarkers.length == 0)) {
      _buildMarkers(viewModel);
    }

    FlutterMap _map = buildMap(
      viewModel,
      _mapController,
      position: _currentPosition,
      zoom: _currentZoomLevel,
      onPositionChanged: (position, hasGesture) =>
          _positionChanged(position, hasGesture, viewModel),
      circleMapMarkers: _mapGroupMarkers,
      mapMarkers: _mapMarkers,
      safeArea: (viewModel.activeGroupMember == null),
    );

    return _map;
  }

  void _moveToPosition({
    latlng.LatLng position,
    double zoom: 18.0,
  }) {
    _latTween = Tween<double>(
      begin: _mapController.center.latitude,
      end: position.latitude,
    );

    _lngTween = Tween<double>(
      begin: _mapController.center.longitude,
      end: position.longitude,
    );

    _zoomTween = Tween<double>(
      begin: _mapController.zoom,
      end: zoom,
    );

    _mapController.move(
      latlng.LatLng(
        _latTween.evaluate(_mapAnimation),
        _lngTween.evaluate(_mapAnimation),
      ),
      _zoomTween.evaluate(_mapAnimation),
    );

    _mapAnimationController.forward();
  }

  void _positionChanged(
    MapPosition position,
    bool hasGesture,
    GroupsViewModel viewModel,
  ) {
    if ((viewModel.user.mapData.currentPosition.latitude !=
            position.center.latitude) &&
        (viewModel.user.mapData.currentPosition.longitude !=
            position.center.longitude)) {
      double zoomLevel = position.zoom;
      if (zoomLevel > _maxZoomLevel) {
        _currentZoomLevel = _maxZoomLevel;
      } else if (zoomLevel < _minZoomLevel) {
        _currentZoomLevel = _minZoomLevel;
      } else {
        _currentZoomLevel = position.zoom;
      }

      if (_panningDebounce?.isActive ?? false) {
        _panningDebounce.cancel();
      }

      _panningDebounce = Timer(const Duration(milliseconds: 250), () {
        if (hasGesture) {
          _panningPosition = position;
          _mapPanning = true;
        }

        _saveCurrentPosition(position.center);
      });
    }
  }

  void _buildMarkers(
    GroupsViewModel viewModel,
  ) {
    _mapMarkers = List<Marker>();
    _mapGroupMarkers = List<CircleMarker>();
    _mapBounds = LatLngBounds();

    if (!_mapController.ready) {
      return;
    }

    if (viewModel.groupPlaces != null) {
      viewModel.groupPlaces.forEach(
        (place) {
          double groupOpacity;
          if ((viewModel.activePlace != null) &&
              (viewModel.activePlace.documentId == place.documentId)) {
            groupOpacity = 0.2; // TODO: enum
          } else {
            groupOpacity = 0.05; // TODO: enum
          }

          _mapGroupMarkers
            ..add(
              buildPlaceRadiusMarker(
                place,
                opacity: groupOpacity,
              ),
            );

          _mapMarkers
            ..add(
              _buildPlaceMarker(viewModel, place),
            );
        },
      );

      if (viewModel.activePlace != null) {
        latlng.LatLng latLng = latlng.LatLng(
          viewModel.activePlace.details.position[0],
          viewModel.activePlace.details.position[1],
        );

        _mapBounds.extend(latLng);
      }
    }

    if (viewModel.activeGroup != null) {
      List<GroupMember> members =
          List<GroupMember>.from(viewModel.activeGroup.members);

      // This let's us order the group member markers by placing the active group member at the top.
      if (viewModel.activeGroupMember != null) {
        GroupMember activeMember = members.firstWhere((GroupMember member) =>
            member.uid == viewModel.activeGroupMember.uid);
        int index = members.indexWhere((GroupMember member) =>
            member.uid == viewModel.activeGroupMember.uid);
        members.removeAt(index);
        members.add(activeMember);
      }

      for (GroupMember member in members.where((GroupMember member) =>
          (member.location != null) && (member.location.coords != null))) {
        latlng.LatLng latLng = latlng.LatLng(
          member.location.coords.latitude,
          member.location.coords.longitude,
        );

        if (viewModel.activePlace == null) {
          // Here we check to see if we're viewing an active member. If so we only want this member to be added to the map bounds.
          // This allows us to keep showing all member avatars while being zoomed in on the active member.
          if ((viewModel.activeGroupMember != null) &&
              (viewModel.activeGroupMember.uid == member.uid)) {
            _mapBounds.extend(latLng);
            // Otherwise add all online members to the map bounds.
          } else if ((viewModel.activeGroupMember == null) &&
              isOnline(member)) {
            _mapBounds.extend(latLng);
          }
        }

        _mapMarkers..add(_buildGroupMemberMarker(latLng, viewModel, member));
      }
    }

    if (_mapBounds.isValid && (_panningPosition == null)) {
      fitMarkerBounds(
        _mapController,
        _mapBounds,
        padding: const EdgeInsets.symmetric(
          vertical: 180.0,
          horizontal: 100.0,
        ),
      );
    }
  }

  Marker _buildGroupMemberMarker(
    latlng.LatLng latLng,
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    double paddedMarkerSize = (_markerSize + _markerPadding);

    return Marker(
      width: paddedMarkerSize,
      height: paddedMarkerSize,
      point: latLng,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (context) => InkWell(
        onTap: ((viewModel.activeGroupMember == null) ||
                (viewModel.activeGroupMember.uid != viewModel.user.documentId))
            ? () => _tapGroupMemberMarker(viewModel, member)
            : null,
        child: Tooltip(
          message: getGroupMemberName(member, viewModel: viewModel),
          preferBelow: false,
          margin: EdgeInsets.only(bottom: 10.0),
          child: _buildUserPin(viewModel, member),
        ),
      ),
    );
  }

  Marker _buildPlaceMarker(
    GroupsViewModel viewModel,
    Place place,
  ) {
    const double _iconSize = 30.0;

    return Marker(
      width: _iconSize,
      height: _iconSize,
      point: latlng.LatLng(
        place.details.position[0],
        place.details.position[1],
      ),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (context) => InkWell(
        onTap: (viewModel.activePlace == null)
            ? () => _tapPlaceMarker(viewModel, place)
            : null,
        child: GestureDetector(
          child: Tooltip(
            message: place.name,
            preferBelow: false,
            child: PlacePin(
              color: place.active ? AppTheme.active() : AppTheme.primaryAccent,
              size: _iconSize,
              showDot: true,
            ),
          ),
        ),
      ),
    );
  }

  UserPin _buildUserPin(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    return UserPin(
      member: member,
      glow: _getUserGlow(viewModel, member),
    );
  }

  UserPinGlow _getUserGlow(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    bool locationSharingEnabled = member.hasLocationSharingEnabled();
    if (!locationSharingEnabled) {
      return UserPinGlow(
        color: AppTheme.alert(),
        innerColor: AppTheme.alertAccent(),
      );
    } else {
      bool driving = ActivityType.isDriving(member.location.activity.type);
      if (driving) {
        return UserPinGlow(
          outerColor: AppTheme.active(),
          innerColor: AppTheme.activeAccent(),
        );
      } else if ((viewModel.activeGroupMember != null) &&
          (member.uid == viewModel.activeGroupMember.uid)) {
        return UserPinGlow(
          color: AppTheme.still(),
          innerColor: AppTheme.stillAccent(),
        );
      }
    }

    return null;
  }

  void _saveCurrentPosition(
    latlng.LatLng position,
  ) {
    if ((position != null) && (context != null)) {
      final store = StoreProvider.of<AppState>(context);
      Map<String, dynamic> mapData;
      User user = store.state.user;
      if (user != null) {
        if (user.mapData == null) {
          mapData = Map<String, dynamic>();
          mapData['map_type'] = widget.mapType;
        } else {
          mapData = store.state.user.mapData.toJson();
        }

        mapData['last_updated'] = getNow();
        mapData['current_position'] = {
          'latitude': position.latitude,
          'longitude': position.longitude
        };

        store.dispatch(SetMapDataAction(mapData));
      }
    }
  }

  void _tapRequestLocationPermission() async {
    final store = StoreProvider.of<AppState>(context);
    await checkLocationPermissionStatus(store, context);
  }

  void _tapPlaceMarker(
    GroupsViewModel viewModel,
    Place place,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ClearActiveGroupMemberAction());
    store.dispatch(CancelUserActivityAction());
    store.dispatch(ActivatePlaceAction(place));
    store.dispatch(CancelPlaceActivityAction());
    store.dispatch(RequestPlaceActivityAction(place.documentId));
  }

  void _tapGroupMemberMarker(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ClearActivePlaceAction());
    store.dispatch(CancelPlaceActivityAction());
    store.dispatch(ActivateGroupMemberAction(member.uid));
    store.dispatch(CancelUserActivityAction());
    store.dispatch(RequestUserActivityDataAction(member.uid));
  }

  void _tapMapType() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.mapType));
  }

  void _setInitialPosition(
    User user,
  ) {
    if (_currentPosition == null) {
      latlng.LatLng position;

      // TODO: Need to try and set the initial position to where the user is. Charlotte would then be the fallback if that fails

      if (user == null) {
        position = _defaultPosition();
      } else {
        if ((user.mapData == null) &&
            (user.location != null) &&
            (user.location.coords != null)) {
          position = latlng.LatLng(
            user.location.coords.latitude,
            user.location.coords.longitude,
          );
        } else if (user.mapData != null) {
          position = latlng.LatLng(
            user.mapData.currentPosition.latitude,
            user.mapData.currentPosition.longitude,
          );
        } else {
          position = _defaultPosition();
        }
      }

      if (position != null) {
        _setPosition(position);
      }
    }
  }

  // Charlotte, NC, USA
  latlng.LatLng _defaultPosition() {
    return latlng.LatLng(
      35.2051309,
      -80.8311326,
    );
  }

  void _setPosition(
    latlng.LatLng position,
  ) {
    _saveCurrentPosition(position);

    _currentPosition = latlng.LatLng(
      position.latitude,
      position.longitude,
    );

    if ((_currentPosition != null) &&
        _backdropAnimationController.isCompleted) {
      _backdropAnimationController.reverse();
    }

    if (_backdropAnimationController.isCompleted) {
      _backdropAnimationController.reverse();
    }
  }

  // TODO: Clean up this logic
  void _setMapData(
    GroupsViewModel viewModel,
  ) {
    _buildMarkers(viewModel);

    if ((_currentGroup == null) ||
        ((_currentGroup != null) &&
            (viewModel.activeGroup != null) &&
            (viewModel.activeGroup.documentId != _currentGroup.documentId))) {
      _currentGroup = viewModel.activeGroup;
      _moveToLastPanningPosition();
    } else if ((_currentGroup != null) && (viewModel.activePlace != null)) {
      if (_currentPlace == null) {
        _currentPlace = viewModel.activePlace;
        widget.centerMap(clearPanning: false);
        _mapPanning = false;
      }
    } else if ((_currentGroup != null) &&
        (viewModel.activeGroupMember != null)) {
      if ((_currentGroupMember == null) ||
          (viewModel.activeGroupMember.uid != _currentGroupMember.uid)) {
        _currentGroupMember = viewModel.activeGroupMember;
        widget.centerMap(clearPanning: false);
        _mapPanning = false;
      }
    }

    if ((_currentGroupMember != null) &&
        (viewModel.activeGroupMember == null)) {
      // Setting the group to null allows the group markers to rebuild themselves in the logic above
      _currentGroup = null;
      _currentGroupMember = null;
      _moveToLastPanningPosition();
    } else if ((_currentPlace != null) && (viewModel.activePlace == null)) {
      // Setting the group to null allows the group markers to rebuild themselves in the logic above
      _currentGroup = null;
      _currentPlace = null;
      _moveToLastPanningPosition();
    }
  }

  void _moveToLastPanningPosition() {
    if (_panningPosition != null) {
      _moveToPosition(
        position: _panningPosition.center,
        zoom: _panningPosition.zoom,
      );

      _mapPanning = true;
    }
  }
}
