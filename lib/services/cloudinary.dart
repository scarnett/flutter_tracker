import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final _cloudinaryService = CloudinaryService();

  static CloudinaryService get() {
    return _cloudinaryService;
  }

  Future<dynamic> upload(
    CloudinaryUploadData data,
  ) async {
    String timestamp = getNow().millisecondsSinceEpoch.toString();
    String base64Image = base64Encode(File(data.filePath).readAsBytesSync());

    return http.post(data.apiUrl, body: {
      'api_key': data.apiKey,
      'file': 'data:image/png;base64,$base64Image',
      'folder': data.user.uid,
      'tags': data.user.uid,
      'timestamp': timestamp,
      'signature': _buildAuthSignature(
          data.user.uid, data.publicId, data.apiSecret, timestamp),
    });
  }

  // @see https://cloudinary.com/documentation/upload_images#generating_authentication_signatures
  String _buildAuthSignature(
    String uid,
    String publicId,
    String apiSecret,
    String timestamp,
  ) {
    List<int> bytes = utf8
        .encode('folder=$uid&tags=$uid&timestamp=$timestamp$apiSecret'); // TODO
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }
}
