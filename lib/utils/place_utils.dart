import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/encoding_utils.dart';
import 'package:latlong/latlong.dart' as latlng;
import 'package:flutter_tracker/widgets/place_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

String buildAuthString(
  String appId,
  String appCode,
) {
  String encodedAuthStr = encodeBase64('$appId:$appCode');
  return 'Basic $encodedAuthStr';
}

List<Place> nearByPlacesFromJsonList(
  List<dynamic> list,
) {
  List<Place> places = List<Place>();

  if (list != null) {
    list.forEach((place) => places..add(Place.fromJson(place)));
  }

  return places;
}

Place getPlace(
  List<Place> places,
  Place place,
) {
  Place _place = places.firstWhere(
      (_place) => _place.details.id == place.details.id,
      orElse: () => null);
  return _place;
}

bool hasPlace(
  List<Place> places,
  Place place,
) {
  Place _place = getPlace(places, place);
  return (_place != null);
}

String getTextSearchUrl(
  Map<String, dynamic> config,
  String criteria,
  latlng.LatLng latlng,
) {
  return '${config['places_url']}?q=$criteria&in=${latlng.latitude},${latlng.longitude};r=${config['places_radius']}' +
      '&tf=plain';
}

String getGeocodeUrl(
  Map<String, dynamic> config,
  latlng.LatLng latlng, {
  int radius: 500,
  int maxResults: 1,
  int gen: 9,
  String mode: 'retrieveAddresses',
}) {
  String appId = config['places_api_id'];
  String appCode = config['places_app_code'];
  return '${config['reverse_geocode_url']}?prox=${latlng.latitude},${latlng.longitude},$radius' +
      '&mode=$mode&maxresults=$maxResults&gen=$gen&app_id=$appId&app_code=$appCode';
}

String getNearbyUrl(
  Map<String, dynamic> config,
  latlng.LatLng latlng, {
  int radius: 2500,
}) {
  String appId = config['places_api_id'];
  String appCode = config['places_app_code'];
  return '${config['places_explore_nearby_url']}?in=${latlng.latitude},${latlng.longitude};r=$radius' +
      '&tf=plain&app_id=$appId&app_code=$appCode';
}

// TODO: Make this a bit smarter. Maybe show the date if the day diff is greater than 1d
String lastPlaceActivity(
  Place place,
  PlaceActivity placeActivity, {
  bool useTimeago = false,
}) {
  if (place == null) {
    return null;
  }

  if (placeActivity == null) {
    return 'No activity yet';
  }

  DateTime date = placeActivity.created.toDate();

  if (useTimeago) {
    return 'Last activity ${timeago.format(date)}';
  }

  return 'Last activity ${formatDateTime(date, getDateFormat(date))}';
}

String getEventType(
  PlaceEventType type,
) {
  switch (type) {
    case PlaceEventType.ENTERING:
      return 'entering';

    case PlaceEventType.LEAVING:
      return 'leaving';

    default:
      return 'n/a';
  }
}

String getEventText(
  PlaceEventType type,
) {
  switch (type) {
    case PlaceEventType.ENTERING:
      return 'Entering';

    case PlaceEventType.LEAVING:
      return 'Leaving';

    default:
      return 'N/A';
  }
}

List<Widget> getPlaceText(
  Place place,
  PlaceActivity placeActivity,
) {
  return [
    Text(
      (place != null) && (place.details != null) && (place.name != null)
          ? place.name // Active place title
          : '',
      style: TextStyle(fontSize: 18.0),
    ),
    Text(
      (place != null)
          ? lastPlaceActivity(
              place,
              placeActivity,
            )
          : '',
      style: TextStyle(
        color: AppTheme.hint,
        fontSize: 12.0,
      ),
    ),
  ];
}

IconData getEventIcon(
  PlaceEventType type,
) {
  switch (type) {
    case PlaceEventType.ENTERING:
      return Icons.arrow_back;
      break;

    case PlaceEventType.LEAVING:
      return Icons.arrow_forward;
      break;

    default:
      return null;
  }
}

/*
  // This is used to draw a marker directly onto the map.
  // @see _buildMarkerLayer()
  MarkerLayerOptions buildMarkerLayerOptions() {
    return MarkerLayerOptions(
      markers: [
        _buildMarker(_currentPosition),
      ],
    );
  }
  */

// This is used to draw a horizontally and vertically centered marker layer over the map. This is preferred.
// @see buildMarkerLayerOptions()
Widget buildMarkerLayer({
  bool showDistance = true,
}) {
  return Container(
    child: Center(
      child: IgnorePointer(
        child: Stack(
          children: <Widget>[
            Center(
              child: buildMarkerCircle(showDistance),
            ),
            Center(
              child: PlaceIcon(),
            ),
          ],
        ),
      ),
    ),
  );
}

/*
  // Use this to draw the zone circle.
  // @see _buildMarkerCircle()
  CircleLayerOptions buildCircleLayerOptions() {
    return CircleLayerOptions(
      circles: [
        CircleMarker(
          point: _currentPosition,
          color: AppTheme.primary.withOpacity(0.2),
          borderColor: AppTheme.primary,
          useRadiusInMeter: true,
          radius: _distanceRadius,
        ),
      ],
    );
  }
  */

// Use this to draw the zone circle.
// This draws a group behind the marker but it's not an ideal solution.
// @see buildCircleLayerOptions()
Widget buildMarkerCircle(
  bool showDistance,
) {
  double size = 205.0; // ~100 meters

  // Ignore touch events on this. It is purely for display.
  return showDistance
      ? IgnorePointer(
          child: Container(
            height: size,
            width: size,
            child: SizedBox(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.2),
              border: Border.all(
                color: Colors.pink.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
        )
      : Container();
}

CircleMarker buildPlaceRadiusMarker(
  Place place, {
  double opacity: 0.2, // TODO: enum
  double activeOpacity: 0.25, // TODO: enum
}) {
  Color color = place.active ? AppTheme.activeAccent() : AppTheme.primaryAccent;
  double _opacity = place.active ? activeOpacity : opacity;

  return CircleMarker(
    point: latlng.LatLng(
      place.details.position[0],
      place.details.position[1],
    ),
    color: color.withOpacity(_opacity),
    borderColor: color.withOpacity(_opacity + 0.1),
    borderStrokeWidth: 1,
    useRadiusInMeter: true,
    radius: place.distance.toDouble(),
  );
}
