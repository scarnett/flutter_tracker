import 'package:flutter_tracker/utils/api_utils.dart';
import 'package:flutter_tracker/utils/geofence_utils.dart';
import 'package:http/http.dart' as http;

Future<dynamic> updateUserData(
  String endpointUrl,
  String authToken,
  Map<String, dynamic> data,
) async {
  return http.post(
    updateUserEndpointUrl(
      url: endpointUrl,
      data: data,
    ),
    headers: endpointHeaders(authToken),
    body: updateEndpointBody(data),
  );
}

Future<dynamic> sendMessage(
  String endpointUrl,
  String authToken,
  Map<String, dynamic> data,
) async {
  return http.post(
    updateMessageEndpointUrl(
      url: endpointUrl,
      type: getMessageType(data['action']).toString().split('.').last,
    ),
    headers: endpointHeaders(authToken),
    body: updateEndpointBody(data),
  );
}
