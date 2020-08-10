import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/common_utils.dart';

Widget showScaffoldLoadingBackdrop({
  Color color = AppTheme.primary,
}) {
  return Scaffold(
    resizeToAvoidBottomPadding: false,
    // extendBody: true,
    body: Container(
      color: Colors.black,
      height: double.infinity,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    ),
  );
}

Widget showLoadingBackdrop(
  AnimationController animationController, {
  bool condition,
  double opacity = 0.8,
  Color backdropColor = Colors.black,
  Color spinnerColor = AppTheme.primary,
}) {
  List<Widget> children = [
    showBackdrop(
      animationController,
      condition: condition,
      opacity: opacity,
      color: backdropColor,
    ),
    showCircularProgress(
      animationController,
      condition: condition,
      opacity: opacity,
      color: spinnerColor,
    ),
  ];

  return Positioned.fill(
    child: Stack(
      children: filterNullWidgets(children),
    ),
  );
}

Widget showBackdrop(
  AnimationController animationController, {
  bool condition,
  double opacity = 0.9,
  Color color = Colors.black,
  GestureTapCallback onTap,
}) {
  if ((condition == null) || condition) {
    return FadeTransition(
      opacity: animationController.drive(CurveTween(curve: Curves.ease)),
      child: (onTap == null)
          ? barrier(opacity, color)
          : GestureDetector(
              onTap: onTap,
              child: barrier(opacity, color),
            ),
    );
  }

  return null;
}

Widget barrier(
  double opacity,
  Color color,
) {
  return Opacity(
    opacity: opacity,
    child: Container(
      color: color,
    ),
  );
}

Widget showCircularProgress(
  AnimationController animationController, {
  bool condition,
  double opacity = 0.8,
  Color color = AppTheme.primary,
}) {
  if ((condition == null) || condition) {
    return Center(
      child: FadeTransition(
        opacity: animationController.drive(CurveTween(curve: Curves.ease)),
        child: Opacity(
          opacity: opacity,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }

  return null;
}
