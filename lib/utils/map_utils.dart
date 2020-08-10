import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart' as latlng;
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/mapbox.dart';
import 'package:flutter_tracker/widgets/map_scale_plugin.dart';

FlutterMap buildMap(
  GroupsViewModel _viewModel,
  MapController _mapController, {
  latlng.LatLng position,
  double zoom,
  double minZoom,
  double maxZoom,
  bool interactive: true,
  void Function(MapPosition, bool) onPositionChanged,
  List<Marker> mapMarkers,
  List<CircleMarker> circleMapMarkers,
  List<latlng.LatLng> points,
  double strokeWidth: 2.0,
  bool showMapScale: true,
  double mapScaleOffset: 10.0,
  bool safeArea: true,
}) {
  final String _apiKey = _viewModel.configValue('mapbox_key');
  final MapBox _mapType = getMapType(_viewModel);
  final FlutterMap _map = FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      interactive: interactive,
      center: position,
      zoom: (zoom != null) ? zoom : 13.0,
      minZoom: (minZoom != null) ? minZoom : null,
      maxZoom: (maxZoom != null) ? maxZoom : null,
      onPositionChanged: (position, hasGesture) =>
          onPositionChanged(position, hasGesture),
      plugins: [
        MapScaleLayerPlugin(),
      ],
    ),
    layers: buildMapLayerOptions(
      _viewModel,
      _apiKey,
      _mapType,
      mapMarkers: mapMarkers,
      circleMapMarkers: circleMapMarkers,
      points: points,
      strokeWidth: strokeWidth,
      showMapScale: showMapScale,
      mapScaleOffset: mapScaleOffset,
      safeArea: safeArea,
    ),
  );

  return _map;
}

List<LayerOptions> buildMapLayerOptions(
  GroupsViewModel viewModel,
  String apiKey,
  MapBox mapType, {
  List<Marker> mapMarkers,
  List<CircleMarker> circleMapMarkers,
  List<latlng.LatLng> points,
  double strokeWidth,
  bool showMapScale,
  double mapScaleOffset,
  bool safeArea,
}) {
  if ((mapType == null) || (apiKey == null)) {
    return [];
  }

  final List<LayerOptions> _layers = List<LayerOptions>();
  _layers
    ..add(
      TileLayerOptions(
        urlTemplate: viewModel.configValue(
          'mapbox_url_template',
          {
            'mapType': mapType.key,
            'apiKey': apiKey,
          },
        ),
        additionalOptions: {
          'accessToken': apiKey,
          'id': viewModel.configValue('mapbox_id'),
        },
      ),
    );

  if (showMapScale) {
    _layers
      ..add(
        MapScaleLayerPluginOption(
          lineColor: AppTheme.background(),
          lineWidth: 2,
          textStyle: TextStyle(
            color: AppTheme.background(),
            fontSize: 12.0,
          ),
          padding: EdgeInsets.only(
            top: mapScaleOffset,
          ),
          safeArea: safeArea,
        ),
      );
  }

  if (points != null) {
    _layers
      ..add(
        PolylineLayerOptions(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: strokeWidth,
              color: AppTheme.primary,
            ),
          ],
        ),
      );
  }

  if (circleMapMarkers != null) {
    _layers
      ..add(
        CircleLayerOptions(
          circles: circleMapMarkers,
        ),
      );
  }

  if (mapMarkers != null) {
    _layers
      ..add(
        MarkerLayerOptions(
          markers: mapMarkers,
        ),
      );
  }

  return _layers;
}

void fitMarkerBounds(
  MapController mapController,
  LatLngBounds mapBounds, {
  EdgeInsets padding: const EdgeInsets.symmetric(
    vertical: 40.0,
    horizontal: 20.0,
  ),
}) {
  if (((mapController != null) && mapController.ready) &&
      ((mapBounds != null) && mapBounds.isValid)) {
    try {
      mapController.fitBounds(
        mapBounds,
        options: FitBoundsOptions(
          padding: padding,
        ),
      );
    } catch (e) {
      // logger.e(e);
    }
  }
}

MapBox getMapType(
  GroupsViewModel viewModel, {
  dynamic defaultType,
}) {
  if ((viewModel.user != null) && (viewModel.user.mapData != null)) {
    String mapType = viewModel.user.mapData.mapType;
    if ((mapType != null) && (viewModel.maps != null)) {
      viewModel.maps.forEach((map) {
        if (map.code == mapType) {
          defaultType = map;
        }
      });
    }
  }

  return (defaultType != null)
      ? defaultType
      : (viewModel.maps != null) ? viewModel.maps.first : null;
}
