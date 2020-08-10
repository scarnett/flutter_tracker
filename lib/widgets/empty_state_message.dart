import 'package:flutter/material.dart';

class EmptyStateMessage extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final double size;
  final double padding;

  EmptyStateMessage({
    this.icon: Icons.sentiment_dissatisfied,
    this.title: 'Bummer!',
    this.message: 'We didn\'t find anything',
    this.size: 70.0,
    this.padding: 20.0,
  });

  @override
  _EmptyStateMessageState createState() => _EmptyStateMessageState();
}

class _EmptyStateMessageState extends State<EmptyStateMessage>
    with TickerProviderStateMixin {
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            bottom: 10.0,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: widget.size,
            ),
          ),
        ),
        (widget.title == null)
            ? Container()
            : Text(
                widget.title,
                style: TextStyle(
                  color: Colors.pink[200],
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
        Padding(
          padding: EdgeInsets.only(
            top: 4.0,
            bottom: widget.padding,
          ),
          child: (widget.message == null)
              ? Container()
              : Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
