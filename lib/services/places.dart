import 'dart:async';
import 'dart:convert';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart' as latlng;

class PlacesService {
  static final _placesService = PlacesService();

  static PlacesService get() {
    return _placesService;
  }

  Future<List<Place>> searchPlacesByCriteria(
    Map<String, dynamic> config,
    String criteria,
    latlng.LatLng latlng,
  ) async {
    dynamic response =
        await http.get(getTextSearchUrl(config, criteria, latlng), headers: {
      'Accept': 'application/json',
      'Authorization': buildAuthString(
        config['places_api_id'],
        config['places_app_code'],
      ),
    });

    List<Place> places = <Place>[];
    List<dynamic> results = json.decode(response.body)['results'];
    results
        .where((place) =>
            (place['resultType'] == 'place') && (place['position'] != null))
        .forEach((place) {
      PlaceDetail details = PlaceDetail.fromAutoSuggest(place);
      places..add(Place.create(details.title, details));
    });

    return places;
  }

  Future<Place> geocode(
    Map<String, dynamic> config,
    latlng.LatLng latlng,
  ) async {
    http.Response reponse = await http.get(getGeocodeUrl(config, latlng));
    dynamic response = json.decode(reponse.body);
    PlaceDetail details = PlaceDetail.fromReverseGeocode(response);
    Place place = Place.create(details.title, details);
    return place;
  }

  Future<List<Place>> nearBy(
    Map<String, dynamic> config,
    latlng.LatLng latlng,
  ) async {
    http.Response reponse = await http.get(getNearbyUrl(config, latlng));
    dynamic response = json.decode(reponse.body);
    if (response != null) {
      List<Place> places = List<Place>();
      response['results']['items'].forEach((item) {
        PlaceDetail details = PlaceDetail.fromNearby(item);
        places..add(Place.create(details.title, details));
      });
      return places;
    }

    return null;
  }
}
