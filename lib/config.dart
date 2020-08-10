import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum Flavor {
  DEVELOPMENT,
  RELEASE,
}

class AppConfig extends InheritedWidget {
  final Flavor flavor;
  final String userEndpointUrl;
  final String messageEndpointUrl;

  AppConfig({
    @required this.flavor,
    @required this.userEndpointUrl,
    @required this.messageEndpointUrl,
    @required Widget child,
  }) : super(child: child);

  static AppConfig of(
    BuildContext context,
  ) {
    return context.dependOnInheritedWidgetOfExactType(aspect: AppConfig);
  }

  static bool isDebug(
    BuildContext context,
  ) {
    Flavor flavor = AppConfig.of(context).flavor;
    switch (flavor) {
      case Flavor.DEVELOPMENT:
        return true;

      case Flavor.RELEASE:
      default:
        return false;
    }
  }

  static bool isRelease(
    BuildContext context,
  ) {
    Flavor flavor = AppConfig.of(context).flavor;
    switch (flavor) {
      case Flavor.RELEASE:
        return true;

      case Flavor.DEVELOPMENT:
      default:
        return false;
    }
  }

  @override
  bool updateShouldNotify(
    InheritedWidget oldWidget,
  ) =>
      false;
}
