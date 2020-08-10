import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

typedef OnTap = void Function();

class MapCenter extends StatefulWidget {
  final bool mapPanning;
  final bool enabled;
  final double bottomPosition;
  final double leftPosition;
  final OnTap onTap;

  MapCenter({
    this.mapPanning,
    this.enabled = true,
    this.bottomPosition = 10.0,
    this.leftPosition = 10.0,
    this.onTap,
  });

  @override
  _MapCenterState createState() => _MapCenterState();
}

class _MapCenterState extends State<MapCenter> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _mapOpacity;
  final _alphaTween = Tween(
    begin: 0.0,
    end: 1.0,
  );

  @override
  void initState() {
    super.initState();

    setState(() {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 150),
      );

      _mapOpacity = _alphaTween.animate(_animationController);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Positioned(
      left: widget.leftPosition,
      bottom: widget.bottomPosition,
      child: widget.enabled
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (
                BuildContext context,
                Widget _widget,
              ) {
                if (widget.mapPanning && !_animationController.isCompleted) {
                  _animationController.forward();
                } else if (!widget.mapPanning &&
                    _animationController.isCompleted) {
                  _animationController.reverse();
                }

                return FadeTransition(
                  opacity: _mapOpacity,
                  child: Stack(
                    children: [
                      Tooltip(
                        preferBelow: false,
                        message: 'Re-Center',
                        child: FlatButton(
                          color: AppTheme.primary,
                          splashColor: AppTheme.primaryAccent,
                          textColor: Colors.white,
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.center_focus_weak,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                              Text('Re-Center'),
                            ],
                          ),
                          shape: StadiumBorder(),
                          onPressed:
                              (widget.onTap == null) ? null : widget.onTap,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Container(),
    );
  }
}
