import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool> showAlert(
  BuildContext context,
  String title,
  Widget content,
) {
  return Alert(
    context: context,
    title: title,
    style: AlertStyle(
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      descStyle: const TextStyle(
        color: Colors.black38,
        fontStyle: FontStyle.normal,
        fontSize: 14.0,
        height: 1.5,
      ),
      buttonAreaPadding: const EdgeInsets.all(10.0),
    ),
    content: content,
    closeFunction: () {},
    buttons: [],
  ).show();
}
