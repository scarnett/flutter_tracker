import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/utils/color_utils.dart';
import 'package:flutter_tracker/utils/icon_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';

class PageModel {
  final int sequence;
  final List<Color> colors;
  final Widget icon;
  final IconData iconData;
  final double iconSize;
  final double iconTopMargin;
  final Widget title;
  final String titleStr;
  final Widget body;
  final String bodyStr;
  final Widget footer;
  final String footerStr;

  PageModel({
    this.sequence,
    this.colors,
    this.icon,
    this.iconData,
    this.iconSize = 100.0,
    this.iconTopMargin: 120.0,
    this.title,
    this.titleStr,
    this.body,
    this.bodyStr,
    this.footer,
    this.footerStr,
  });

  factory PageModel.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return PageModel(
      sequence: json['sequence'],
      titleStr: json['title'],
      bodyStr: json['body'],
      footerStr: json['footer'],
      iconData: getMaterialIcon(json['icon']),
      iconSize: (json['iconSize'] == null) ? 0.0 : json['iconSize'].toDouble(),
      colors: getColors(json['colors']),
    );
  }

  factory PageModel.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    return PageModel(
      sequence: snapshot['sequence'],
      titleStr: snapshot['title'],
      bodyStr: snapshot['body'],
      footerStr: snapshot['footer'],
      iconData: getMaterialIcon(snapshot['icon']),
      iconSize: (snapshot['iconSize'] == null)
          ? 0.0
          : snapshot['iconSize'].toDouble(),
      colors: getColors(snapshot['colors']),
    );
  }
}

class Page extends StatelessWidget {
  final PageModel model;
  final double percentVisible;

  Page({
    this.model,
    this.percentVisible = 1.0,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.3, 0.9],
          colors: model.colors,
        ),
      ),
      child: Opacity(
        opacity: percentVisible,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                (50.0 * (1.0 - percentVisible)),
                0.0,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: model.iconTopMargin,
                  bottom: 20.0,
                ),
                child: (model.icon != null)
                    ? model.icon
                    : Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          model.iconData,
                          color: Colors.white,
                          size: model.iconSize,
                        ),
                      ),
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                (30.0 * (1.0 - percentVisible)),
                0.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: (model.title != null)
                    ? model.title
                    : Text(
                        model.titleStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 28.0,
                          shadows: commonTextShadow(),
                        ),
                      ),
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                (30.0 * (1.0 - percentVisible)),
                0.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                ),
                child: (model.body != null)
                    ? model.body
                    : Text(
                        model.bodyStr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          shadows: commonTextShadow(),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    (30.0 * (1.0 - percentVisible)),
                    0.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 70.0,
                    ),
                    child: (model.footer != null)
                        ? model.footer
                        : (model.footerStr == null)
                            ? Container()
                            : Text(
                                model.footerStr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  shadows: commonTextShadow(),
                                ),
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
