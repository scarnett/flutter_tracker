import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Product {
  final String documentId;
  final String id;
  final bool enabled;
  ProductDetails details;

  Product({
    this.documentId,
    this.id,
    this.enabled,
    this.details,
  });

  factory Product.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Product(
      documentId: json['documentId'],
      id: json['id'],
      enabled: json['enabled'],
    );
  }

  factory Product.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return Product(
      documentId: snapshot.documentID,
      id: snapshot['id'],
      enabled: snapshot['enabled'],
    );
  }

  Map<String, dynamic> toMap(
    Product product,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = product.id;
    map['enabled'] = product.enabled;
    map['details'] = product.details;
    return map;
  }
}
