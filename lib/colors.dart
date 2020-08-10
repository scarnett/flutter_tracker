import 'package:flutter/material.dart';

class AppTheme {
  AppTheme();

  static Color background() => Colors.grey[900];
  static const Color primary = Colors.pink;
  static const Color primaryAccent = Colors.pinkAccent;
  static const Color secondary = Colors.cyan;
  static const Color secondaryAccent = Colors.cyanAccent;
  static Color text() => Colors.grey[700];
  static const Color hint = Colors.grey;
  static Color inactive() => Colors.grey[300];
  static Color light() => Colors.grey[50];
  static Color error() => Colors.red;
  static Color active() => Colors.blue;
  static Color activeAccent() => Colors.blueAccent;
  static Color still() => Colors.indigo;
  static Color stillAccent() => Colors.indigoAccent;
  static Color alert() => Colors.red;
  static Color alertAccent() => Colors.redAccent;
}

ThemeData appThemeData = ThemeData(
  brightness: Brightness.light,
  canvasColor: Colors.transparent,
  backgroundColor: Colors.transparent,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: AppTheme.background(),
  accentColor: AppTheme.primary,
  textSelectionColor: AppTheme.primary,
  textSelectionHandleColor: AppTheme.primaryAccent,
  cursorColor: AppTheme.primary,
  sliderTheme: SliderThemeData(
    thumbColor: AppTheme.primary,
    activeTrackColor: AppTheme.primaryAccent,
    overlayColor: AppTheme.primaryAccent.withOpacity(0.1),
    inactiveTrackColor: AppTheme.inactive(),
  ),
  fontFamily: 'Montserrat',
  appBarTheme: const AppBarTheme(
    brightness: Brightness.light,
    color: Colors.white,
    elevation: 1.0,
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    textTheme: Typography.blackCupertino,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    headline: const TextStyle(
      fontSize: 72.0,
      fontWeight: FontWeight.bold,
    ),
    title: const TextStyle(
      fontSize: 36.0,
      fontStyle: FontStyle.italic,
    ),
    body1: const TextStyle(
      fontSize: 14.0,
      fontFamily: 'Hind',
    ),
  ),
  tooltipTheme: TooltipThemeData(
    height: 18.0,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(4.0),
    ),
    padding: EdgeInsets.all(8.0),
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 12.0,
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);
