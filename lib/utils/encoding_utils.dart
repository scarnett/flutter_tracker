import 'dart:convert';

String encodeBase64(
  String str,
) {
  List<int> bytes = utf8.encode(str);
  return base64.encode(bytes);
}