import 'package:flutter/material.dart';

const APPBAR_HEIGHT = 80.0;
const NOTIFICATION_MESSAGE_HEIGHT = 24.0;

const TAB_HOME = 0;
const TAB_PLACES = 1;
const TAB_CHAT = 2;
const TAB_SETTINGS = 3;

abstract class Enum<T> {
  final T _value;
  const Enum(this._value);
  T get value => _value;
}

dynamic setValue(
  dynamic value, {
  dynamic def,
}) {
  if (value == null) {
    return def;
  }

  return value;
}

// @see https://github.com/flutter/flutter/issues/17862
List<Widget> filterNullWidgets(List<Widget> widgets) {
  if (widgets == null) {
    return null;
  }

  return widgets.where((child) => child != null).toList();
}
