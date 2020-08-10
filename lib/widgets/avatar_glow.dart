import 'dart:async';
import 'package:flutter/material.dart';

class AvatarGlow extends StatefulWidget {
  final bool repeat;
  final Duration duration;
  final double endRadius;
  final Duration repeatPauseDuration;
  final Widget child;
  final Color outerGlowColor;
  final Color innerGlowColor;
  final Duration startDelay;

  AvatarGlow({
    @required this.child,
    this.endRadius = 70.0,
    this.duration,
    this.repeat = true,
    this.repeatPauseDuration,
    this.outerGlowColor = Colors.blue,
    this.innerGlowColor = Colors.blueAccent,
    this.startDelay,
  });

  @override
  _AvatarGlowState createState() => _AvatarGlowState();
}

class _AvatarGlowState extends State<AvatarGlow>
    with SingleTickerProviderStateMixin {
  Animation<double> smallDiscAnimation;
  Animation<double> bigDiscAnimation;
  Animation<double> alphaAnimation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: widget.duration ?? Duration(milliseconds: 2000),
      vsync: this,
    );

    final Animation curve = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    smallDiscAnimation = Tween(
      begin: ((widget.endRadius * 2.0) / 6.0),
      end: ((widget.endRadius * 2.0) * (3.0 / 4.0)),
    ).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    bigDiscAnimation = Tween(
      begin: 0.0,
      end: (widget.endRadius * 2.0),
    ).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    alphaAnimation = Tween(
      begin: 0.30,
      end: 0.0,
    ).animate(controller);

    controller.addStatusListener((_) async {
      if (controller.status == AnimationStatus.completed) {
        await Future.delayed(
            widget.repeatPauseDuration ?? Duration(milliseconds: 100));

        if (mounted && widget.repeat) {
          controller.reset();
          controller.forward();
        }
      }
    });

    startAnimation();
  }

  void startAnimation() async {
    if (widget.startDelay != null) {
      await Future.delayed(widget.startDelay ?? Duration(milliseconds: 1000));

      if (mounted) {
        controller.forward();
      }
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: (widget.endRadius * 2.0),
      width: (widget.endRadius * 2.0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: bigDiscAnimation.value,
            width: bigDiscAnimation.value,
            child: SizedBox(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.outerGlowColor ?? Colors.white)
                  .withOpacity(alphaAnimation.value),
            ),
          ),
          Container(
            height: smallDiscAnimation.value,
            width: smallDiscAnimation.value,
            child: SizedBox(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.innerGlowColor.withOpacity(alphaAnimation.value),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
