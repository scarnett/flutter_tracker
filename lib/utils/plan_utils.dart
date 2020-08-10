import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/play.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/currency_utils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Logger logger = Logger();

bool needsUpgrade(
  Plan plan,
  String optionKey,
  dynamic compareValue,
) {
  if (plan == null) {
    return true;
  }

  dynamic optionValue = getOptionValue(plan, optionKey);
  if (optionValue != null) {
    if (compareValue.runtimeType == int) {
      // logger.d('INT: $compareValue; VAL: $optionValue');
      if ((optionValue > -1) && (compareValue >= optionValue)) {
        return true;
      }
    } else if (compareValue.runtimeType == bool) {
      // logger.d('BOOL: $compareValue; VAL: $optionValue');
      if (compareValue == optionValue) {
        return true;
      }
    }
  }

  return false;
}

dynamic getOptionValue(
  Plan plan,
  String optionKey,
) {
  if (plan == null) {
    return null;
  }

  if (plan.options.containsKey(optionKey)) {
    Map<dynamic, dynamic> option = plan.options[optionKey];
    if (option.containsKey('value')) {
      return option['value'];
    }
  }

  return null;
}

Widget buildBody(
  String description,
  Map<dynamic, dynamic> options,
) {
  return Column(
    children: <Widget>[
      Opacity(
        opacity: 0.7,
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            shadows: commonTextShadow(),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 10.0,
            ),
            child: Text(
              'Features'.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 16.0,
                shadows: commonTextShadow(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
      buildFeatures(options),
    ],
  );
}

Widget buildFeatures(
  Map<dynamic, dynamic> options,
) {
  List<Widget> rows = List<Widget>();

  if (options != null) {
    List<dynamic> features = buildFeatureList(options);

    features.forEach(
      (option) {
        rows
          ..add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    right: 4.0,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  child: Opacity(
                    opacity: 0.7,
                    child: Text(
                      option['description'],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 14.0,
                        shadows: commonTextShadow(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
      },
    );
  }

  return Container(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: rows,
      ),
    ),
  );
}

dynamic buildFeatureList(
  Map<dynamic, dynamic> options,
) {
  List<dynamic> features = List<dynamic>();

  options.forEach((key, entry) {
    dynamic option = options[key];
    if (option['feature']) {
      features..add(option);
    }
  });

  // Sort the feature list by 'sequence'
  features.sort((a, b) => a['sequence'].compareTo(b['sequence']));
  return features;
}

Widget buildFooter(
  dynamic context,
  final store,
  User user,
  Plan plan,
  Product monthlyProduct,
  Product annualProduct,
  bool canSubscribe,
  bool isSubscribed,
  String endpointUrl,
) {
  if (!canSubscribe) {
    return Container();
  }

  List<Widget> buttonText = List<Widget>();
  buttonText
    ..add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: isSubscribed
                ? Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: 18.0,
                  )
                : Icon(
                    Icons.check,
                    color: Colors.white.withOpacity(0.7),
                    size: 18.0,
                  ),
          ),
          Text((isSubscribed ? 'Unsubscribe' : 'Subscribe').toUpperCase()),
        ],
      ),
    );

  if (!isSubscribed && (plan.subscribeText != null)) {
    buttonText
      ..add(
        Text(
          plan.subscribeText,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.7),
            fontSize: 8.0,
          ),
        ),
      );
  }

  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        isSubscribed
            ? Opacity(
                opacity: 0.5,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    ('Currently Subscribed').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: commonTextShadow(color: Colors.black87),
                    ),
                  ),
                ),
              )
            : Container(),
        FlatButton(
          color: plan.colors[0],
          disabledColor: plan.colors[0].withOpacity(0.7),
          splashColor: plan.colors[1],
          textColor: Colors.white,
          disabledTextColor: Colors.white,
          shape: StadiumBorder(),
          onPressed: isSubscribed
              ? () => _tapConfirmUnsubscribe(
                    context,
                    store,
                    endpointUrl,
                    plan,
                    user,
                  )
              : () => _tapConfirmSubscription(
                    context,
                    plan,
                    monthlyProduct,
                    annualProduct,
                    user,
                  ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: buttonText,
          ),
        )
      ]);
}

void _tapConfirmSubscription(
  context,
  Plan plan,
  Product monthlyProduct,
  Product annualProduct,
  User user,
) {
  Alert(
    context: context,
    type: AlertType.none,
    title: '${plan.name} Subscription',
    closeFunction: () {},
    buttons: [
      DialogButton(
        height: 50.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Monthly',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            Text(
              '${formatCurrency.format(plan.pricing.monthly)}/mo',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        onPressed: () =>
            _tapFinalizeSubscription(context, monthlyProduct, user),
        color: plan.colors[0],
      ),
      DialogButton(
        height: 50.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Annually',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            Text(
              '${formatCurrency.format(plan.pricing.annually)}/yr',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        onPressed: () => _tapFinalizeSubscription(context, annualProduct, user),
        color: plan.colors[1],
      )
    ],
  ).show();
}

void _tapFinalizeSubscription(
  context,
  Product product,
  User user, {
  bool autoConsume = true,
  bool sandboxTesting = false,
}) {
  bool isIOS = Platform.isIOS;
  PurchaseParam purchaseParam = PurchaseParam(
    productDetails: product.details,
    applicationUserName: user.documentId,
    sandboxTesting: (sandboxTesting && isIOS),
  );

  InAppPurchaseConnection.instance
    ..buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: (autoConsume || isIOS),
    ).then((bool status) => Navigator.pop(context));
}

void _tapConfirmUnsubscribe(
  context,
  final store,
  String endpointUrl,
  Plan plan,
  User user,
) async {
  Alert(
    context: context,
    type: AlertType.none,
    title: 'Cancel Subscription?',
    closeFunction: () {},
    buttons: [
      DialogButton(
        height: 50.0,
        child: Text(
          'Yes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        onPressed: () =>
            _tapFinalizeUnsubscribe(context, store, endpointUrl, user),
        color: plan.colors[0],
      ),
      DialogButton(
        height: 50.0,
        child: Text(
          'No',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        onPressed: () => Navigator.pop(context),
        color: plan.colors[1],
      )
    ],
  ).show();
}

void _tapFinalizeUnsubscribe(
  context,
  final store,
  String endpointUrl,
  User user,
) async {
  // POST the cancel subscription request
  await cancelSubscription(
    endpointUrl,
    user.auth.token,
    user.purchase.sku,
    user.purchase.purchaseToken,
  ).then((value) {
    Navigator.pop(context);
    store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
    store.dispatch(NavigateReplaceAction(AppRoutes.home));
  }).catchError((error) => logger.e(error));
}

Widget buildIcon(
  double monthlyPrice, {
  double annualPrice,
}) {
  List<Widget> priceData = List<Widget>();
  priceData..add(_buildMonthlyPrice(monthlyPrice));

  if (annualPrice > 0) {
    priceData..addAll(_buildAnnualPrice(annualPrice));
  }

  return Container(
    width: 140.0,
    height: 140.0,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: priceData,
      ),
    ),
  );
}

Widget _buildMonthlyPrice(
  double price,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        height: 40.0,
        child: Text(
          formatCurrency.format(price),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 36.0,
            shadows: commonTextShadow(color: Colors.black),
          ),
        ),
      ),
      Opacity(
        opacity: 0.7,
        child: Container(
          alignment: Alignment.bottomLeft,
          height: 32.0,
          child: Text(
            '/mo',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 16.0,
              shadows: commonTextShadow(),
            ),
          ),
        ),
      ),
    ],
  );
}

List<Widget> _buildAnnualPrice(
  double price,
) {
  return [
    Opacity(
      opacity: 0.7,
      child: Container(
        alignment: Alignment.center,
        height: 16.0,
        child: Text(
          'or',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
            fontSize: 10.0,
            shadows: commonTextShadow(color: Colors.black),
          ),
        ),
      ),
    ),
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.bottomLeft,
          height: 18.0,
          child: Text(
            formatCurrency.format(price),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 14.0,
              shadows: commonTextShadow(color: Colors.black),
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Container(
            alignment: Alignment.bottomLeft,
            height: 18.0,
            child: Text(
              '/yr',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 12.0,
                shadows: commonTextShadow(),
              ),
            ),
          ),
        ),
      ],
    )
  ];
}
