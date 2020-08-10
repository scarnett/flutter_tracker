import 'dart:convert';

String updateUserEndpointUrl({
  String url,
  Map<String, dynamic> data,
  String type,
}) {
  int index = 0;
  String types = '';

  if (data != null) {
    data.forEach((key, value) {
      if (index > 0) {
        types += ',';
      }

      types += key;
      index++;
    });
  } else if (type != null) {
    types = type;
  }

  url = '$url?types=$types';
  return url;
}

String updateMessageEndpointUrl({
  String url,
  String type,
}) {
  url = '$url?type=$type';
  return url;
}

Map<String, String> endpointHeaders(
  String authToken,
) {
  return {
    'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };
}

dynamic updateEndpointBody(
  Map<String, dynamic> data,
) {
  dynamic _data = {};

  if (data != null) {
    data.forEach((key, value) {
      _data[key] = value;
    });
  }

  return json.encode(_data);
}
