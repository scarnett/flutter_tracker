import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_tracker/model/product.dart';

/*
 * Gets a list of products for this app from the app stores
 */
Future<List<ProductDetails>> getProductDetails(
  List<Product> products,
) async {
  if ((products != null) && (products.length > 0)) {
    List<String> productIds = List<String>();

    products.forEach((Product product) {
      productIds..add(product.id);
    });

    return InAppPurchaseConnection.instance
        .queryProductDetails(productIds.toSet())
        .then((ProductDetailsResponse response) {
      List<ProductDetails> productDetails = List<ProductDetails>();

      if (response.notFoundIDs.isNotEmpty) {
        // ...
      } else {
        response.productDetails.forEach((ProductDetails details) {
          productDetails..add(details);
        });
      }

      return productDetails;
    });
  }

  return Future<List<ProductDetails>>.value(null);
}

String getResponseType(
  String type,
) {
  if (type == null) {
    return null;
  }

  return type.split('.')[1];
}
