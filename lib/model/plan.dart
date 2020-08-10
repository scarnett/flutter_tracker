import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/utils/color_utils.dart';
import 'package:flutter_tracker/utils/plan_utils.dart';
import 'package:flutter_tracker/widgets/pages.dart';

class Plan {
  final String documentId;
  final String name;
  final String code;
  final String description;
  final int sequence;
  final PlanPricing pricing;
  final String subscribeText;
  final Map<dynamic, dynamic> options;
  final Map<dynamic, dynamic> products;
  final List<Color> colors;
  final bool enabled;
  final Timestamp created;

  Plan({
    this.documentId,
    this.name,
    this.code,
    this.description,
    this.sequence,
    this.pricing,
    this.subscribeText,
    this.options,
    this.products,
    this.colors,
    this.enabled,
    this.created,
  });

  factory Plan.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return Plan(
      documentId: json['documentId'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      sequence: json['sequence'],
      pricing: PlanPricing.fromJson(json['pricing']),
      subscribeText: json['subscribe_text'],
      options: json['options'],
      products: json['products'],
      colors: getColors(json['colors']),
      enabled: json['enabled'],
      created: json['created'],
    );
  }

  factory Plan.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return Plan(
      documentId: snapshot.documentID,
      name: snapshot['name'],
      code: snapshot['code'],
      description: snapshot['description'],
      sequence: snapshot['sequence'],
      pricing: PlanPricing.fromJson(snapshot['pricing']),
      subscribeText: snapshot['subscribe_text'],
      options: snapshot['options'],
      products: snapshot['products'],
      colors: getColors(snapshot['colors']),
      enabled: snapshot['enabled'],
      created: snapshot['created'],
    );
  }

  Map<String, dynamic> toMap(
    Plan plan,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['name'] = plan.name;
    map['code'] = plan.code;
    map['description'] = plan.description;
    map['sequence'] = plan.sequence;
    map['pricing'] = PlanPricing().toMap(plan.pricing);
    map['subscribeText'] = plan.subscribeText;
    map['options'] = plan.options;
    map['products'] = plan.products;
    map['colors'] = getColors(this.colors);
    map['enabled'] = plan.enabled;
    map['created'] = plan.created;
    return map;
  }

  PageModel toPageModel(
    dynamic context,
    final store,
    User user,
    Product monthlyProduct,
    Product annualProduct,
    bool isSubscribed,
    String endpointUrl,
  ) {
    PageModel model = PageModel(
      sequence: this.sequence,
      colors: this.colors,
      titleStr: this.name.toUpperCase(),
      bodyStr: this.description,
      iconTopMargin: 40.0,
      icon: buildIcon(
        this.pricing.monthly,
        annualPrice: this.pricing.annually,
      ),
      body: buildBody(
        this.description,
        this.options,
      ),
      footer: buildFooter(
        context,
        store,
        user,
        this,
        monthlyProduct,
        annualProduct,
        (sequence > 0), // Cannot subscribe to free plans
        isSubscribed,
        endpointUrl,
      ),
    );

    return model;
  }
}

class PlanPricing {
  final double monthly;
  final double annually;

  PlanPricing({
    this.monthly,
    this.annually,
  });

  factory PlanPricing.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PlanPricing(
      monthly: (json['monthly'] == null) ? 0.00 : json['monthly'].toDouble(),
      annually: (json['annually'] == null) ? 0.00 : json['annually'].toDouble(),
    );
  }

  Map<String, dynamic> toMap(
    PlanPricing pricing,
  ) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['monthly'] = pricing.monthly;
    map['annually'] = pricing.annually;
    return map;
  }
}
