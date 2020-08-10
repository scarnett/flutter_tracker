import 'package:firebase_auth/firebase_auth.dart';

class CloudinaryUploadData {
  final String filePath;
  final FirebaseUser user;
  final String apiKey;
  final String apiSecret;
  final String apiUrl;
  final String publicId;

  CloudinaryUploadData({
    this.filePath,
    this.user,
    this.apiKey,
    this.apiSecret,
    this.apiUrl,
    this.publicId,
  });
}

class CloudinaryImage {
  final String publicId;
  final int version;
  final String signature;
  final int width;
  final int height;
  final String format;
  final String resourceType;
  final String createdAt;
  final List<dynamic> tags;
  final int bytes;
  final String type;
  final String etag;
  final bool placeholder;
  final String url;
  final String secureUrl;

  CloudinaryImage({
    this.publicId,
    this.version,
    this.signature,
    this.width,
    this.height,
    this.format,
    this.resourceType,
    this.createdAt,
    this.tags,
    this.bytes,
    this.type,
    this.etag,
    this.placeholder,
    this.url,
    this.secureUrl,
  });

  factory CloudinaryImage.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) {
      return null;
    }

    return CloudinaryImage(
      publicId: json['public_id'],
      version: json['version'],
      signature: json['signature'],
      width: json['width'],
      height: json['height'],
      format: json['format'],
      resourceType: json['resource_type'],
      createdAt: json['created_at'],
      tags: json['tags'],
      bytes: json['bytes'],
      type: json['type'],
      etag: json['etag'],
      placeholder: json['placeholder'],
      url: json['url'],
      secureUrl: json['secure_url'],
    );
  }
}