import 'package:cloud_firestore/cloud_firestore.dart';

class MapBox {
  final String code;
  final String name;
  final String key;
  final String image;
  final String author;
  final int sequence;
  final List<dynamic> plans;

  MapBox({
    this.code,
    this.name,
    this.key,
    this.image,
    this.author,
    this.sequence,
    this.plans,
  });

  factory MapBox.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return MapBox(
      code: json['code'],
      name: json['name'],
      key: json['key'],
      image: json['image'],
      author: json['author'],
      sequence: json['sequence'],
      plans: json['plans'],
    );
  }

  factory MapBox.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    return MapBox(
      code: snapshot['code'],
      name: snapshot['name'],
      key: snapshot['key'],
      image: snapshot['image'],
      author: snapshot['author'],
      sequence: snapshot['sequence'],
      plans: snapshot['plans'],
    );
  }
}
