import 'package:flutter_tracker/utils/api_utils.dart';
import 'package:http/http.dart' as http;

Future<dynamic> cancelSubscription(
  String endpointUrl,
  String authToken,
  String subscriptionId,
  String purchaseToken,
) async {
  return http.post(
    '$endpointUrl?subscriptionId=$subscriptionId&purchaseToken=$purchaseToken',
    headers: endpointHeaders(authToken),
  );
}
