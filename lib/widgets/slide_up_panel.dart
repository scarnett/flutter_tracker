import 'package:flutter/material.dart';

class SlideUpPanel extends StatefulWidget {
  final List<Widget> body;

  SlideUpPanel({
    this.body,
  });

  @override
  State createState() => SlideUpPanelState();
}

class SlideUpPanelState extends State<SlideUpPanel> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: Container(
                  width: 40.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ]..addAll(widget.body),
      ),
    );
  }
}
