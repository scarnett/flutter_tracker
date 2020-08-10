import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

const double DEFAULT_PANEL_ACTIVE_HEIGHT = 0.35;
const double DEFAULT_PANEL_FAB_OFFSET = 85.0;
const double DEFAULT_PANEL_MIN_HEIGHT_BOTTOM_BAR = 80.0;
const double DEFAULT_PANEL_MIN_HEIGHT = 35.0;

Widget buildMenuActions(
  List<Widget> children,
) {
  return Container(
    decoration: BoxDecoration(
      color: AppTheme.light(),
      border: Border(
        bottom: BorderSide(
          color: AppTheme.inactive().withOpacity(0.3),
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    ),
  );
}

Widget menuActionButton(
  String label,
  IconData icon,
  Color color,
  Function onTap, {
  bool showSpacer: false,
}) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.light(),
        border: Border(
          left: BorderSide(
            width: showSpacer ? 1.0 : 0.0,
            color: AppTheme.inactive().withOpacity(0.3),
          ),
        ),
      ),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    icon,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: commonBoxShadow(),
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
